#!/usr/bin/python3
# Copyright (c) 2010 Alon Swartz <alon@turnkeylinux.org> - all rights reserved
# Updated 2016 by Anton Pyrogovskyi <anton@turnkeylinux.org>
"""Configure admin password for Transmission

Options:
    -p --pass=    if not provided, will ask interactively
"""

import sys
import getopt
import subprocess
from time import sleep
import json

from libinithooks.dialog_wrapper import Dialog

def fatal(s):
    print("Error:", s, file=sys.stderr)
    sys.exit(1)

def usage(s=None):
    if s:
        print("Error:", s, file=sys.stderr)
    print("Syntax: %s [options]" % sys.argv[0], file=sys.stderr)
    print(__doc__, file=sys.stderr)
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "hp:", ['help', 'pass='])
    except getopt.GetoptError as e:
        usage(e)

    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt in ('-p', '--pass'):
            password = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Torrent Server Password",
            "Enter new admin password for Transmission.")

    subprocess.run(['service', 'transmission-daemon', 'stop'])
    with open('/etc/transmission-daemon/settings.json', 'r') as fob:
        settings = json.load(fob)
    settings['rpc-username'] = 'admin'
    settings['rpc-password'] = password
    with open('/etc/transmission-daemon/settings.json', 'w') as fob:
        json.dump(settings, fob)
    subprocess.run(['service', 'transmission-daemon', 'start'])

if __name__ == "__main__":
    main()

