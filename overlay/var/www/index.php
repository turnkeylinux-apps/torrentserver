<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta http-equiv="Content-Style-Type" content="text/css">
        <meta http-equiv="Content-Script-Type" content="text/javascript">

        <title>TurnKey Torrent Server</title>
        
        <link rel="stylesheet" href="css/ui.tabs.css" type="text/css" media="print, projection, screen">
        <link rel="stylesheet" href="css/base.css" type="text/css">

        <script src="js/jquery-1.2.6.js" type="text/javascript"></script>
        <script src="js/ui.core.js" type="text/javascript"></script>
        <script src="js/ui.tabs.js" type="text/javascript"></script>
        <script type="text/javascript">
            $(function() {
                $('#container-1 > ul').tabs({ fx: { opacity: 'toggle'} });
            });
        </script>
    </head>

    <body>
        <h1>TurnKey Torrent Server</h1>
        
        <div id="container-1">
            <ul>
                <li><a href="#cp"><span>Control Panel</span></a></li>
                <li><a href="#tips"><span>Tips</span></a></li>
            </ul>

            <div id="cp">
                <div class="fragment-content">
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12323"><img
                        src="images/download.png"/>Basic</a>
                    </div>
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12322"><img
                        src="images/download.png"/>Advanced</a>
                    </div>
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12320"><img
                        src="images/shell.png"/>Web Shell</a>
                    </div>
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12321"><img
                        src="images/webmin.png"/>Webmin</a>
                    </div>
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>/files"><img
                        src="images/filemanager.png"/>File Manager</a>
                    </div>

                    <h2>Resources and references</h2>
                    <ul>
                        <li>TurnKey Torrent Server <a href="http://www.turnkeylinux.org/torrentserver">release notes</a> and <a href="http://www.turnkeylinux.org/docs/torrentserver">documentation</a></li>
                        <li>Wikipedia: <a href="http://en.wikipedia.org/wiki/BitTorrent_(protocol)">BitTorrent</a>, <a href="http://en.wikipedia.org/wiki/EDonkey_network">EDonkey network</a>, <a href="http://en.wikipedia.org/wiki/Kademlia">Kademlia</a></li>
                        <li>MLDonkey <a href="http://mldonkey.sourceforge.net"> documentation</a></li>
                    </ul>

                </div>
            </div>

            <div id="tips">
                <div class="fragment-content">
                    <h2>Browser Extensions</h2>
                    <div class="icon">
                    <a href="http://www.turnkeylinux.org/docs/torrentserver/browserextensions/">
                    <img src="/images/tsh64.png"/></a>
                    </div>
                    <p>Installing a compatible extension in your browser
                    adds the capability to simply click on a download
                    link (torrent, ed2k, magnet, sigdat) or
                    <i>right-click -> Save with TorrentServer</i> any
                    download link and have it automatically submitted to
                    the Torrent Server for download.</p>
                    <a href="http://www.turnkeylinux.org/docs/torrentserver/browserextensions/">Get them here</a>

                    <h2>Router/Firewall configuration</h2>
                    <p>TurnKey Torrent Server listens on certain ports, and
                    requires that they are reachable from the internet.
                    As a quick reference the ports are specified below
                    (perform a <a href="https://<?php print
                    $_SERVER{'HTTP_HOST'}; ?>:12322/submit?q=porttest">
                    port test</a>, and refer to the 
                    <a href="http://www.turnkeylinux.org/docs/torrentserver">
                    documentation</a> for more information).
                    </p>
                    <ul>
                        <li>BitTorrent: 6881-6889/TCP</li>
                        <li>EDonkey: 2788/TCP, 2792/UDP</li>
                        <li>Kademlia: 18247/UDP</li>
                        <li>Overnet: 20883/TCP+UDP</li>
                        <li>Torrent Server Handler: 12322/TCP (optional)</li>
                    </ul>

                    <h2>Email notifications</h2>
                    <p>Configure your 
                    <a href="https://<?php print
                    $_SERVER{'HTTP_HOST'}; ?>:12322/submit?q=voo+6">
                    email address</a> to receive notifications when downloads
                    complete.</p>

                </div>
            </div>

        </div>
    </body>
</html>
