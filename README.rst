Torrent Server - File download and sharing server
=================================================

A file server with integrated multi-protocol file sharing that can be
used to handle all types of file downloads. Files can be added to the
download list using the `Torrent Server handler`_ extension for FireFox,
or through a simple web interface that allows you to manage the server
remotely. Especially useful for centralizing file sharing on a shared
network. Includes anti-virus scanning.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- SSL support out of the box.
- Includes popular compression support (zip, rar, bz2).
- Includes flip to convert text file endings between UNIX and DOS
  formats.
- E-mail download completion notification via Postfix MTA (bound to
  localhost).
- File sharing (`MLDonkey`_) configurations:
   
   - Anti-virus / malware scanning via `ClamAV`_.
      
      - Anti-virus signatures are auto-updated.
      - Automatically quarantines unsafe downloads.
      - Anti-virus logfile: */var/log/mldonkey/clamav.log*

   - Support `broadcatching`_ via helper tools (xmllint, xsltproc).
   - Enabled all file sharing protocols (e.g., HTTP/FTP, `BitTorrent`_,
     `eDonkey`_, `Direct Connect`_)

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

- Access your files securely from anywhere via `AjaXplorer`_:
   
   - Rich web GUI, with online previews for major formats and
     drag-n-drop support.
   - Dedicated `iOS`_ and `Android`_ apps for on-the-go access.
   - Pre-configured multi-authentication (Local and Samba).
   - Pre-configured repositories (storage, user home directory).

-  Default storage directory: */srv/storage*
-  Includes mldonkey-passwd script to change MLdonkey and
   AjaXplorer passwords::

       /usr/local/bin/mldonkey-passwd PASSWORD

-  Recommended Firefox plugin: `Torrent Server Handler`_

See the `Torrent Server Documentation`_ for more details, including
configuration details if behind a Firewall/Router/NAT

Known issues
------------

- mldonkey daemon will shutdown if free disk space reaches the
  threshold of approx. 50MB.
- mldonkey can take a while to fully load depending on the system
  hardware, see the log file for details: */var/log/mldonkey/mlnet.log*

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, Webshell, SSH, Samba: username **root**
-  MLdonkey: username **admin**
-  Web based file manager (AjaXplorer):
   
   -  username **admin** (Local)
   -  username **root** (Samba)


.. _Torrent Server handler: https://addons.mozilla.org/en-US/firefox/addon/14043
.. _TurnKey Core: http://www.turnkeylinux.org/core
.. _MLDonkey: http://en.wikipedia.org/wiki/MLDonkey
.. _ClamAV: http://www.clamav.net/
.. _broadcatching: http://en.wikipedia.org/wiki/Broadcatching
.. _BitTorrent: http://en.wikipedia.org/wiki/BitTorrent_(protocol)
.. _eDonkey: http://en.wikipedia.org/wiki/EDonkey_network
.. _Direct Connect: http://en.wikipedia.org/wiki/Direct_Connect_(file_sharing)
.. _Samba: http://www.samba.org/samba/what_is_samba.html
.. _AjaXplorer: http://ajaxplorer.info
.. _iOS: http://ajaxplorer.info/extensions/ios-client/
.. _Android: http://ajaxplorer.info/extensions/android/
.. _Torrent Server Handler: https://addons.mozilla.org/en-US/firefox/addon/14043
.. _Torrent Server Documentation: http://www.turnkeylinux.org/docs/torrentserver
