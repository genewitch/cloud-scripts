#!/bin/bash
#installs and starts Up1 (https://github.com/Upload/Up1) on an AWS instance (including lightsail)

if [ ! -f /home/ubuntu/Up1/server/server.conf ]; then
        #uses tmpfs, change this if you want
        echo "tmpfs /mnt/knoxious      tmpfs   size=200M,mode=0755     0       0" > /etc/fstab
        mkdir /mnt/knoxious
        mount -a

        apt-get install nodejs npm
        cd /home/ubuntu
        git clone https://github.com/Upload/Up1

        cd Up1

        FOO=` curl --silent http://169.254.169.254/latest/dynamic/instance-identity/rsa2048 |sha512sum |cut -b1-32`
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/server/server.conf.example > /home/ubuntu/Up1/server/server.conf
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/client/config.js.example > /home/ubuntu/Up1/client/config.js

        cd server
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
cd /mnt/knoxious/server
nohup nodejs server.js &
