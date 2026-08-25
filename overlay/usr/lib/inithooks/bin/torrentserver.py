#!/usr/bin/python3
# Copyright (c) 2010 Alon Swartz <alon@turnkeylinux.org> - all rights reserved
# Updated 2016 by Anton Pyrogovskyi <anton@turnkeylinux.org>
"""Configure the Transmission administrator password."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from libinithooks.dialog_wrapper import Dialog

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group()
    source.add_argument('-p', '--pass', dest='password', help=argparse.SUPPRESS)
    source.add_argument('--pass-stdin', action='store_true',
                        help='read the password from standard input')
    args = parser.parse_args()

    if args.pass_stdin:
        password = sys.stdin.read()
    elif args.password is not None:
        password = args.password
    else:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Torrent Server Password",
            "Enter new admin password for Transmission.")

    if not password:
        parser.error('password must not be empty')

    settings_path = Path('/etc/transmission-daemon/settings.json')
    subprocess.run(['service', 'transmission-daemon', 'stop'], check=True)
    try:
        with settings_path.open(encoding='utf-8') as settings_file:
            settings = json.load(settings_file)
        settings['rpc-authentication-required'] = True
        settings['rpc-username'] = 'admin'
        settings['rpc-password'] = password

        original = settings_path.stat()
        descriptor, temporary_name = tempfile.mkstemp(
            dir=settings_path.parent,
            prefix='.settings.json.',
        )
        try:
            os.fchmod(descriptor, original.st_mode & 0o777)
            os.fchown(descriptor, original.st_uid, original.st_gid)
            with os.fdopen(descriptor, 'w', encoding='utf-8') as settings_file:
                json.dump(settings, settings_file, indent=4, sort_keys=True)
                settings_file.write('\n')
                settings_file.flush()
                os.fsync(settings_file.fileno())
            os.replace(temporary_name, settings_path)
        except BaseException:
            try:
                os.unlink(temporary_name)
            except FileNotFoundError:
                pass
            raise
    finally:
        subprocess.run(['service', 'transmission-daemon', 'start'], check=True)

if __name__ == "__main__":
    main()
