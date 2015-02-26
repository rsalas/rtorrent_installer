#Installation for rTorrent and ruTorrent in Debian Wheezy and Debian Jessie

This bash script ONLY works on Debian distributions and allow us the installation of the BitTorrent rTorrent client
which works in text mode. It also installs ruTorrent, a web interface to manage rTorrent with a look and feel that
resembles µTorrent WebUI.

The script add a init script to start rtorrent automatically with the user's session on reboots.

The init service for rTorrent is created:
/etc/init.d/rtorrent

It also installs the following 47 plug-ins for ruTorrent:
```
_getdir                  : This plugin provides the possibility of comfortable navigation on a host file system.
_noty                    : This plugin provides the notification functionality for other plugins.
_noty2                   : This plugin provides the notification functionality for other plugins.
_task                    : This plugin provides the possibility of running various scripts on the host system.
autotools                : This plugin provides some possibilities on automation.
chat                     : The plug-in allows users to communicate with other users on the same rutorrent.
check_port               : This plugin adds an incoming port status indicator to the bottom bar.
chunks                   : This plugin shows the download status of torrent chunks.
cookies                  : This plugin provides cookies information for authentication on trackers.
cpuload                  : This plugin adds a CPU Load indicator to the bottom bar.
create                   : This plugin allows for the creation of new .torrent files.
data                     : This plugin allows to copy torrent data files from the host to the local machine.
datadir                  : This plugin is intended for moving torrent data files.
diskspace                : This plugin adds an easy to read disk meter to the bottom bar.
edit                     : This plugin allows to edit the list of trackers and change the comment of the current torrent.
erasedata                : This plugin allows to delete torrent data along with .torrent file.
extrato                  : This plugin extends the functionality of the ratio plugin.
extsearch                : This plugin allows to search many popular torrent sites for content from within ruTorrent.
feets                    : This plugin is intended for making RSS feeds with information of torrents.
filedrop                 : This plugin allows users to drag multiple torrents from desktop to the browser (FF > 3.6 & Chrome only).
geoip                    : This plugin shows geolocation of peers for the selected torrent.
history                  : This plugin is designed to log a history of torrents.
httprpc                  : This plugin is a low-traffic replacement for the mod_scgi webserver module.
instantsearch            : searchresults appears instantly
ipad                     : This plugin allows ruTorrent to work properly on iPad-like devices.
loginmgr                 : This plugin is used to login to torrent sites in cases where cookies fail.
logoff                   : The plug-in allows users to logoff from rutorrent.
lookat                   : This plugin allows to search for torrent name in external sources.
mediainfo                : This plugin is intended to display media file information.
nfo                      : Displays the NFO of a torrent in a popup.
pausewebui               : Adds an button to pause the webui from updating
ratio                    : This plugin allows to manage ratio limits for groups of torrents.
retrackers               : This plugin appends specified trackers to the trackers list of all newly added torrents.
rpc                      : This plugin is a replacement for the mod_scgi webserver module.
rss                      : This plugin is designed to fetch torrents via rss download links.
rssurlrewrite            : This plugin extends the functionality of the RSS plugin.
rutracker_check          : This plugin checks the rutracker.org tracker for updated/deleted torrents.
scheduler                : This plugin allows to define any of six rTorrent behavior types at each particular hour of 168 week hours.
screenshot               : This plugin is intended to show screenshots from video files. (only wheezy)
seedingtime              : This plugin adds the columns 'Finished' and 'Added' to the torrents list.
show_peers_like_wtorrent : This plugin changes the format of values in columns 'Seeds' and 'Peers' in the torrents list.
source                   : This plugin allows to copy the source .torrent file from the host to the local machine.
theme                    : This plugin allows to change the UI theme to one of several provided themes.
throttle                 : This plugin gives a convenient control over speed limits for groups of torrents.
tracklabels              : This plugin adds tracker-based labels to the category panel.
trafic                   : This plugin allows to monitor rTorrent system wide and per-tracker traffic totals.
unpack                   : This plugin is designed to manually or automatically unrar/unzip torrent data.
```
#Installation:
```bash
wget 'https://github.com/rsalas/rtorrent_installer/raw/master/install.sh'
chmod +x install.sh
sudo ./install.sh
```
