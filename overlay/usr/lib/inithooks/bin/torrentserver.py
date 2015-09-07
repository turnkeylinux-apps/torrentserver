#!/usr/bin/python
# Copyright (c) 2010 Alon Swartz <alon@turnkeylinux.org> - all rights reserved
"""Configure admin password for ruTorrent

Options:
    -p --pass=    if not provided, will ask interactively
"""

import sys
import getopt
import subprocess
from subprocess import PIPE

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
            "Enter new admin password for ruTorrent.")

    command = ['openssl', 'passwd', '-apr1', password]

    with open('/etc/nginx/htpasswd', 'w') as of:
        of.write('admin:')
        of.flush()
        subprocess.call(command, stdin=PIPE, stdout=of, shell=False)

if __name__ == "__main__":
    main()

