#!/bin/bash
set -euo pipefail

: "${TKL_TEST_RESULT:?TKL_TEST_RESULT must name the result file}"
: "${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS must contain the firstboot password}"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

require_contains() {
    local text=$1 expected=$2 context=$3
    [[ $text == *"$expected"* ]] || fail "$context did not contain: $expected"
}

if ! systemctl is-active --quiet clamav-freshclam; then
    systemctl restart clamav-freshclam \
        || fail "clamav-freshclam did not restart after runtime CA setup"
fi

for service in transmission-daemon apache2 smbd clamav-freshclam postfix; do
    systemctl is-active --quiet "$service" || fail "$service is not active"
done
systemctl is-enabled --quiet clamav-daemon.path \
    || fail "ClamAV database watcher is not enabled"
systemctl is-active --quiet clamav-daemon.path \
    || fail "ClamAV database watcher is not active"
for _ in $(seq 1 300); do
    systemctl is-active --quiet clamav-daemon && break
    sleep 1
done
systemctl is-active --quiet clamav-daemon \
    || fail "clamav-daemon did not start after the initial signature download"
apache2ctl configtest 2>&1 | grep -q 'Syntax OK' \
    || fail "Apache configuration is invalid"

installed_version=$(dpkg-query -W -f='${Version}' transmission-daemon)
[[ $installed_version == 4.* ]] || fail "Transmission is not on the Trixie 4.x series"
dpkg-query -W transmission-cli clamav-daemon clamav-freshclam samba >/dev/null

python3 - <<'PY'
import json
import os

with open('/etc/transmission-daemon/settings.json', encoding='utf-8') as source:
    settings = json.load(source)
expected = {
    'download-dir': '/srv/storage/download',
    'incomplete-dir': '/srv/storage/incoming',
    'incomplete-dir-enabled': True,
    'peer-port': 6882,
    'rpc-authentication-required': True,
    'rpc-bind-address': '127.0.0.1',
    'rpc-username': 'admin',
    'rpc-whitelist-enabled': True,
    'script-torrent-done-enabled': True,
    'script-torrent-done-filename': '/usr/local/bin/clamav-scan',
}
for key, value in expected.items():
    if settings.get(key) != value:
        raise SystemExit(f'unexpected Transmission setting {key}')
if settings.get('rpc-password') == os.environ['TKL_TEST_APP_PASS']:
    raise SystemExit('Transmission retained the firstboot password in plaintext')
PY

temporary=$(mktemp -d)
torrent_netrc=$temporary/transmission.netrc
samba_auth=$temporary/samba.auth
fixture_source=/srv/storage/incoming/turnkey-v19-fixture.txt
fixture_download=/srv/storage/download/turnkey-v19-fixture.txt
fixture_torrent=$temporary/turnkey-v19-fixture.torrent
fixture_copy=$temporary/samba-copy.txt
samba_name=turnkey-v19-samba-fixture.txt
torrent_hash=
start_policy_changed=0

cleanup() {
    local status=$?
    trap - EXIT HUP INT TERM
    if [ -n "$torrent_hash" ]; then
        transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
            --torrent "$torrent_hash" --remove >/dev/null 2>&1 || true
    fi
    if [ "$start_policy_changed" -eq 1 ]; then
        transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
            --no-start-paused >/dev/null 2>&1 || true
    fi
    smbclient //127.0.0.1/storage --authentication-file="$samba_auth" \
        --command="del $samba_name" >/dev/null 2>&1 || true
    rm -f "$fixture_source" "$fixture_download"
    rm -rf "$temporary"
    exit "$status"
}
trap cleanup EXIT HUP INT TERM

chmod 0700 "$temporary"
printf 'machine 127.0.0.1 login admin password %s\n' "$TKL_TEST_APP_PASS" \
    > "$torrent_netrc"
printf 'username = root\npassword = %s\n' "$TKL_TEST_APP_PASS" > "$samba_auth"
chmod 0600 "$torrent_netrc" "$samba_auth"

session_json=$(transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
    --json --session-info)
require_contains "$session_json" '"result":"success"' "Transmission RPC session"
require_contains "$session_json" '"peer-port":6882' "Transmission RPC session"
require_contains "$session_json" '"start-added-torrents":true' "Transmission RPC session"

web_ui=$(curl --insecure --fail --silent --show-error --location \
    --netrc-file "$torrent_netrc" --max-time 30 \
    https://127.0.0.1:12322/transmission/web/)
require_contains "$web_ui" "Transmission" "Transmission HTTPS web UI"

control_panel=$(curl --fail --silent --show-error --location --max-time 30 \
    http://127.0.0.1/)
require_contains "$control_panel" "TurnKey Torrent Server" "torrent control panel"

printf 'TurnKey Torrentserver v19 local lifecycle fixture\n' > "$fixture_source"
cp "$fixture_source" "$fixture_download"
chown debian-transmission:users "$fixture_source" "$fixture_download"
transmission-create --anonymize --outfile "$fixture_torrent" "$fixture_source" \
    >/dev/null

start_policy_changed=1
add_json=$(transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
    --json --start-paused --download-dir /srv/storage/download \
    --add "$fixture_torrent")
transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
    --no-start-paused >/dev/null
start_policy_changed=0
torrent_hash=$(python3 -c '
import json, sys
for line in sys.stdin:
    data = json.loads(line)
    added = data.get("arguments", {}).get("torrent-added")
    if added:
        print(added["hashString"])
' <<< "$add_json")
[[ $torrent_hash =~ ^[0-9a-f]{40}$ ]] || fail "Transmission did not add the fixture"

transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
    --torrent "$torrent_hash" --verify >/dev/null
for _ in $(seq 1 20); do
    info_json=$(transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
        --json --torrent "$torrent_hash" --info)
    lifecycle=$(python3 -c '
import json, sys
torrent = json.load(sys.stdin)["arguments"]["torrents"][0]
print("|".join(str(torrent[key]) for key in
      ("name", "haveValid", "totalSize", "leftUntilDone", "downloadDir")))
' <<< "$info_json")
    if [[ $lifecycle = "turnkey-v19-fixture.txt|50|50|0|/srv/storage/download" ]]; then
        break
    fi
    sleep 1
done
[[ $lifecycle = "turnkey-v19-fixture.txt|50|50|0|/srv/storage/download" ]] \
    || fail "Transmission did not verify and read the local fixture"

transmission-remote 127.0.0.1:9091 --netrc "$torrent_netrc" \
    --torrent "$torrent_hash" --remove >/dev/null
torrent_hash=

smbclient //127.0.0.1/storage --authentication-file="$samba_auth" \
    --command="put $fixture_source $samba_name; get $samba_name $fixture_copy; del $samba_name" \
    >/dev/null
cmp "$fixture_source" "$fixture_copy" || fail "Samba file round trip changed content"

apt-get update >/dev/null
policy=$(apt-cache policy transmission-daemon)
candidate=$(awk '/Candidate:/ {print $2}' <<< "$policy")
[[ -n $candidate && $candidate != '(none)' ]] || fail "APT has no Transmission candidate"
require_contains "$policy" "trixie" "Transmission APT policy"
apt-get --simulate --only-upgrade install \
    transmission-daemon transmission-common transmission-cli >/dev/null

echo "PASS: Transmission RPC lifecycle, HTTPS web UI, Samba, ClamAV hook and services"
cat > "$TKL_TEST_RESULT" <<EOF
package_source=Debian Trixie transmission packages
installed_version=transmission-daemon $installed_version
runtime_checks=authenticated RPC local torrent create add verify read remove, HTTPS web UI, Samba file round trip, storage, ClamAV hook and service supervision passed
updater_command=apt-get update; apt-cache policy transmission-daemon; apt-get --simulate --only-upgrade install transmission-daemon transmission-common transmission-cli
updater_result=APT authenticated current metadata, selected candidate $candidate, and the non-mutating upgrade simulation passed
updater_channel=Debian Trixie signed package repositories
integrity_evidence=installed dpkg state and APT policy bind Transmission to signed Debian Trixie metadata
EOF
