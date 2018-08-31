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
- File sharing (`Transmission`_) configurations:
   
   - Anti-virus / malware scanning via `ClamAV`_.
      
      - Anti-virus signatures are auto-updated.
      - Automatically quarantines unsafe downloads.
      - Anti-virus logfile: */var/log/rtorrent/clamav.log*

- File server (`Samba`_) configurations:
   
   - Preconfigured wordgroup: WORKGROUP
   - Preconfigured netbios name: TORRENTSERVER
   - Configured root as administrative samba user.
   - Configured shares:
      
      - Users home directory.
      - Public storage.
      - CD-ROM with automount and umount hooks (/media/cdrom).

    - NOTE: Due to the removal of libpam-smbpass (see `issue #1188`_), new Samba
      users must have their passwords explictly set separately when created.
      However, if you create a Samba user using smbpasswd, then a new Linux user
      of the same name, with the same password is automatically created
      (including home directory). E.g.::

        # smbpasswd -a new_user
        New SMB password:
        Retype new SMB password:
        Added user new_user.
        # ls /home/
        new_user

- Access your files securely from anywhere via `WebDAV CGI`_:
   
   - DAV service running via HTTPS.
   - Pre-configured repositories (storage, user home directory).

- Default storage directory: */srv/storage*
- Accessing file server via samba on the command line::

    smbclient //1.0.0.61/storage -Uroot
        mount -t cifs //1.0.0.61/storage /mnt -o username=root,password=PASSWORD

See the `Torrent Server Documentation`_ for more details, including
configuration details if behind a Firewall/Router/NAT

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, Webshell, SSH, Samba: username **root**
-  Transmission: username **admin**
-  Web based file manager (WebDAV CGI):
   -  username **root** (or Samba users)

.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Transmission: https://en.wikipedia.org/wiki/Transmission_(BitTorrent_client)
.. _WebDAV CGI: https://github.com/DanRohde/webdavcgi
.. _ClamAV: https://www.clamav.net/
.. _BitTorrent: https://en.wikipedia.org/wiki/BitTorrent_(protocol)
.. _Samba: https://www.samba.org/samba/what_is_samba.html
.. _issue #1188: https://github.com/turnkeylinux/tracker/issues/1188
.. _Torrent Server Documentation: https://www.turnkeylinux.org/docs/torrentserver
