#!/usr/bin/python
# Copyright (c) 2010 Alon Swartz <alon@turnkeylinux.org> - all rights reserved
# Updated 2016 by Anton Pyrogovskyi <anton@turnkeylinux.org>
"""Configure admin password for Transmission

Options:
    -p --pass=    if not provided, will ask interactively
"""

import sys
import getopt
from os import system
from time import sleep
import json

from dialog_wrapper import Dialog

def fatal(s):
    print >> sys.stderr, "Error:", s
    sys.exit(1)

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "hp:", ['help', 'pass='])
    except getopt.GetoptError, e:
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

    system('service transmission-daemon stop')
    with open('/etc/transmission-daemon/settings.json', 'r') as fob:
        settings = json.load(fob)
    settings['rpc-username'] = 'admin'
    settings['rpc-password'] = password
    with open('/etc/transmission-daemon/settings.json', 'wb') as fob:
        json.dump(settings, fob)
    system('service transmission-daemon start')

if __name__ == "__main__":
    main()

