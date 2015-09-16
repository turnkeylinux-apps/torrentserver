Torrent Server - File download and sharing server
=================================================

A file server with integrated multi-protocol file sharing that can be
used to handle all types of file downloads. Files can be added to the
download list through a simple web interface that allows you to manage
the server remotely. Especially useful for centralizing file sharing on
a shared network. Includes anti-virus scanning.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- SSL support out of the box.
- Includes popular compression support (zip, rar, bz2).
- Includes flip to convert text file endings between UNIX and DOS
  formats.
- E-mail download completion notification via Postfix MTA (bound to
  localhost).
- File sharing (`rTorrent`_) configurations:
   
   - Anti-virus / malware scanning via `ClamAV`_.
      
      - Anti-virus signatures are auto-updated.
      - Automatically quarantines unsafe downloads.
      - Anti-virus logfile: */var/log/rtorrent/clamav.log*

- File server (`Samba`_) configurations:
   
   - Preconfigured wordgroup: WORKGROUP
   - Preconfigured netbios name: TORRENTSERVER
   - Configured Samba and UNIX users/groups synchronization (CLI and
     Webmin).
   - Configured root as administrative samba user.
   - Configured shares:
      
      - Users home directory.
      - Public storage.
      - CD-ROM with automount and umount hooks (/media/cdrom).

- Access your files securely from anywhere via `SambaDAV`_:
   
   - DAV service running via HTTPS.
   - Pre-configured repositories (storage, user home directory).

-  Default storage directory: */srv/storage*

See the `Torrent Server Documentation`_ for more details, including
configuration details if behind a Firewall/Router/NAT

Known issues
------------

- rTorrent will shut down if free disk space reaches the threshold of
  100MB

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, Webshell, SSH, Samba: username **root**
-  rTorrent: username **admin**
-  Web based file manager (SambaDAV):
   -  username **root** (Samba)

.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _rTorrent: https://en.wikipedia.org/wiki/RTorrent
.. _SambaDAV: https://github.com/1afa/sambadav
.. _ClamAV: http://www.clamav.net/
.. _BitTorrent: http://en.wikipedia.org/wiki/BitTorrent_(protocol)
.. _Samba: http://www.samba.org/samba/what_is_samba.html
.. _Torrent Server Documentation: https://www.turnkeylinux.org/docs/torrentserver
