#!/bin/bash
#installs and starts Up1 (https://github.com/Upload/Up1) on an AWS instance (including lightsail)
# add following to /etc/systemd/system/start-up1.sh, chmod 664 that file, and chmod +x this script in /home/ubuntu/up1.sh
# [Unit]
# After=network.target
#
# [Service]
# ExecStart=/home/ubuntu/up1.sh
# Environment=SYSTEMD_LOG_LEVEL=debug
#
# [Install]
# WantedBy=default.target

#start of up1.sh
if [ ! -f /home/ubuntu/Up1/server/server.conf ]; then
        #uses tmpfs, change this if you want
        echo "tmpfs /mnt/knoxious      tmpfs   size=200M,mode=0755     0       0" >> /etc/fstab
        mkdir /mnt/knoxious
        mount -a
        
        #apt won't instsall stuff without an update
        apt-get update
        apt-get install -y nodejs npm
        cd /home/ubuntu
        git clone https://github.com/Upload/Up1

        cd /home/ubuntu/Up1

        FOO=` curl --silent http://169.254.169.254/latest/dynamic/instance-identity/rsa2048 |sha512sum |cut -b1-32`
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/server/server.conf.example > /home/ubuntu/Up1/server/server.conf
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/client/config.js.example > /home/ubuntu/Up1/client/config.js

        cd /home/ubuntu/Up1/server
        #this sometimes fails, if your server doesn't come up, make sure that /mnt/knoxious/server has a "node_modules" folder
        npm install
else
        FOO=` curl --silent http://169.254.169.254/latest/dynamic/instance-identity/rsa2048 |sha512sum |cut -b1-32`
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/server/server.conf.example > /home/ubuntu/Up1/server/server.conf
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/client/config.js.example > /home/ubuntu/Up1/client/config.js
fi


rsync -avz /home/ubuntu/Up1/ /mnt/knoxious
#Again, uses tmpfs, change   ^^^^this^^^^   to your desired directory
echo "starting nodejs"
cd /mnt/knoxious/server
/usr/bin/nodejs /mnt/knoxious/server/server.js
#if you're not using systemd, you might need something like 
# nohup nodejs server.js & 
# otherwise your system will hang on boot.
