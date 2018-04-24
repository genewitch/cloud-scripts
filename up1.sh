#!/bin/bash
if [ ! -f /home/ubuntu/Up1/server/server.conf ]; then
        echo "tmpfs /mnt/knoxious      tmpfs   size=200M,mode=0755     0       0" > /etc/f
stab
        mkdir /mnt/knoxious
        mount -a

        apt-get install nodejs npm
        git clone https://github.com/Upload/Up1

        cd Up1

        FOO=` curl --silent http://169.254.169.254/latest/dynamic/instance-identity/rsa204
8 |sha512sum |cut -b1-32`
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/server/server.conf.example > /home/ubuntu/Up1/server/server.conf
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/client/config.js.example > /home/ubuntu/Up1/client/config.js

        cd server
        npm install
else
        FOO=` curl --silent http://169.254.169.254/latest/dynamic/instance-identity/rsa204
8 |sha512sum |cut -b1-32`
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/server/server.conf.example > /home/ubuntu/Up1/server/server.conf
        sed -e 's/c61540b5ceecd05092799f936e27755f/'"$FOO"'/' \
        /home/ubuntu/Up1/client/config.js.example > /home/ubuntu/Up1/client/config.js
fi


rsync -avz /home/ubuntu/Up1/ /mnt/knoxious
#chown -R www-data.www-data /mnt/knoxious/
#service nginx restart
cd /mnt/knoxious/server
nohup nodejs server.js &
