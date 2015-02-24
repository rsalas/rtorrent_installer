#!/bin/bash
clear

if [ -t 1 ]; then
    # see if it supports colors...
    colors=$(tput colors)

    if test -n "$colors" && test $colors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"

        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

# Check if user is root
id | grep "uid=0(" >/dev/null
if [ "$?" != "0" ]; then
    echo
    echo "${red}Fatal Error: The install script must be run as root${normal}"
    echo
    exit 1
fi

echo "This installation is only for ${red}${bold}Debian Wheezy${normal} and ${red}${bold}Debian Jessie${normal}"
echo
read -p "Press any key to continue" -n 1

if [ -f "/etc/.issue" ]; then
    etc_issue=$(cat /etc/.issue)
elif [ -f "/etc/issue" ]; then
    etc_issue=$(cat /etc/issue)
fi

ver=$(cat /etc/debian_version)
dist=0
if [[ "$etc_issue" == *"Debian"* ]]; then
    let dist=$dist+1
fi
if [ -n $ver ]; then
    let dist=$dist+1
    if [[ "$ver" =~ ^7\.[0-9]+ ]]; then
        ver="wheezy"
    elif [[ "$ver" =~ ^8\.[0-9]+ ]]; then
        ver="jessie"
    fi
fi
if [ $dist != "2" ]; then
    echo
    echo "${red}Fatal Error: The install script only run in ${yellow}Debian Wheezy${red} and ${yellow}Debian Jessie${normal}"
    echo
    exit 1
fi

# Request a user.
repeat=0
while [ $repeat -eq 0 ]; do
    echo
    echo -n "Please enter a valid USER for rTorrent: "
    echo
    read -e user
    echo

    if [ "$user" != "" ]; then
        uid=$(cat /etc/passwd | grep "$user": | cut -d: -f3)

        if [ "$(cat /etc/passwd | grep "$user":)" == "" ]; then
            echo "${red}The user does not exist!${normal}"

        elif [ "$uid" -lt "1000" ]; then
            echo "${red}The user is not valid!${normal}"

        elif [ "$user" == "nobody" ]; then
            echo "${red}You can't use 'nobody' as user!${normal}"
        else
            repeat=1
        fi
    fi
done

homedir=$(cat /etc/passwd | grep "$user": | cut -d: -f6)

# Installing required software
apt-get update
apt-get -y -f install openssl subversion apache2 apache2-utils build-essential libsigc++-2.0-dev libcurl4-openssl-dev \
curl automake unrar-free unzip screen libtool libssl-dev libcppunit-dev libncurses5-dev libapache2-mod-scgi \
php5 php5-curl php5-cli libapache2-mod-php5 libzen0 libmediainfo0 mediainfo php5-geoip
if [ "$ver" == "wheezy" ]; then
    apt-get -y -f install ffmpeg
fi

# Find temp directory
if [ "$TMPDIR" = "" ]; then
	TMPDIR=/tmp
fi
if [ "$tempdir" = "" ]; then
	tempdir=$TMPDIR/.rtorrent-$$
	if [ -e "$tempdir" ]; then
		rm -rf $tempdir
	fi
	mkdir $tempdir
fi

cd $tempdir

# Download software for compilation
wget https://raw.github.com/rsalas/rtorrent_installer/master/apps/xmlrpc-c.tar.gz
wget https://raw.github.com/rsalas/rtorrent_installer/master/apps/libtorrent-0.13.4.tar.gz
wget https://raw.github.com/rsalas/rtorrent_installer/master/apps/rtorrent-0.9.4.tar.gz
wget https://raw.github.com/rsalas/rtorrent_installer/master/apps/rutorrent-3.6.tar.gz
wget https://raw.github.com/rsalas/rtorrent_installer/master/plugins/plugins.tar.gz
tar -zxf xmlrpc-c.tar.gz
tar -zxf libtorrent-0.13.4.tar.gz
tar -zxf rtorrent-0.9.4.tar.gz
tar -zxf rutorrent-3.6.tar.gz
tar -zxf plugins.tar.gz

# Compiling xmlrpc-c
cd xmlrpc-c
./configure --disable-cplusplus
make
make install
cd ..

# Compiling libtorrent.
cd libtorrent-0.13.4
./autogen.sh
./configure
make
make install
cd ..

# Compiling rTorrent.
cd rtorrent-0.9.4
./autogen.sh
./configure --with-xmlrpc-c
make
make install
cd ../..

ldconfig

# Creating user directories
if [ ! -d "$homedir"/.session ]; then
        mkdir "$homedir"/.session
fi
if [ ! -d "$homedir"/Downloads ]; then
        mkdir "$homedir"/Downloads
fi

chown "$user"."$user" "$homedir"/.session
chown "$user"."$user" "$homedir"/Downloads

# Downloading rtorrent.rc file
wget -O $homedir/.rtorrent.rc https://raw.github.com/rsalas/rtorrent_installer/master/configs/rtorrent.rc

chown "$user"."$user" $homedir/.rtorrent.rc
sed -i "s@USERNAME@$user@g" $homedir/.rtorrent.rc

# Creating symlink for scgi.load
if [ ! -h /etc/apache2/mods-enabled/scgi.load ]; then
    a2enmod scgi
fi

DIR_RUTORRENT="/var/www/rutorrent/"
# Clean ruTorrent installation
if [ -d $DIR_RUTORRENT ]; then
    rm -r $DIR_RUTORRENT
fi
mv -f $tempdir/rutorrent/ $DIR_RUTORRENT

# Installing Plugins
plugindir=$DIR_RUTORRENT"plugins/"

mv -f $tempdir"/plugins/" $DIR_RUTORRENT

# Delete unnecessary files
rm -r $tempdir

# Changing permissions for rutorrent and plugins.
chown -R www-data.www-data $DIR_RUTORRENT
chmod -R 775 $DIR_RUTORRENT

# Get port number
port=$(grep "^Listen" /etc/apache2/ports.conf | cut -d" " -f2)

# Enable site in Apache
if [ ! -f /etc/apache2/sites-available/rutorrent ]; then
    wget -O /etc/apache2/sites-available/rutorrent https://raw.github.com/rsalas/rtorrent_installer/master/configs/apache-rutorrent
    if [ "$ver" == "jessie" ]; then
        mv /etc/apache2/sites-available/rutorrent /etc/apache2/sites-available/rutorrent.conf
    fi
    a2ensite rutorrent
fi

# Install rTorrent init script
wget -O /etc/init.d/rtorrent https://raw.github.com/rsalas/rtorrent_installer/master/configs/init-rtorrent
chmod +x /etc/init.d/rtorrent
sed -i "s/USERNAME/$user/g" /etc/init.d/rtorrent

update-rc.d rtorrent defaults

# Create login for ruTorrent
echo -n "Please enter the username for the Web access ruTorrent: "
read -e htuser

repeat=0
while [ $repeat -eq 0 ]; do
    htpasswd -c $DIR_RUTORRENT.htpasswd "$htuser"
    if [ $? = 0 ]; then
        repeat=1
    fi
done

# Answer for access password
repeat=0
while [ $repeat -eq 0 ]; do
    echo
    echo -n "Do you want to enable Web access password? (y/n):"
    read -n 1 enableWA
    echo
    if [ "$enableWA" != "" ]; then
        if [ "$enableWA" == "y" ] || [ "$enableWA" == "Y" ]; then
            rm -r "$plugindir"{httprpc,rpc}
            repeat=1
        fi
        if [ "$enableWA" == "n" ] || [ "$enableWA" == "N" ]; then
            repeat=1
        fi
    fi
done
if [ "$ver" == "jessie" ]; then
    rm -r "$plugindir"screenshots
fi

/etc/init.d/apache2 restart
/etc/init.d/rtorrent start

echo "${green}Installation is complete.${normal}"
echo
echo "The download directory is stored in: ${yellow}$homedir/Downloads${normal}"
echo "The session data is stored in:       ${yellow}$homedir/.session${normal}"
echo "The configuration file is in:        ${yellow}$homedir/.rtorrent.rc${normal}"
if [ "$enableWA" == "n" ] || [ "$enableWA" == "N" ]; then
    echo
    echo "For enable login Web access password execute: ${yellow}sudo rm -r "$plugindir"{httprpc,rpc}${normal}"
fi
echo

# Get actual IP
ip=$(ip addr | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -v "127." | head -n 1)
if [ $ip ]; then
        echo "Visit ruTorrent at http://$ip:$port/rutorrent"
fi
