#!/bin/bash
# chkconfig: 345 99 10
# description: This script is designed to run once and then never again.
#
##
# Beginning of your custom one-time commands
#

#install remi and epel, update, install nagios
# then make sure they come up after boot
# and start both services
cd /root
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum -y update
service httpd stop
#yum -y install nagios nagios-plugins-all nagios-plugins-nrpe nrpe php httpd mutt
yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip mutt
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.1.tar.gz
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz

useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagios,nagcmd apache

tar zxvf nagios-4.3.1.tar.gz
tar xzvf nagios-plugins-2.2.1.tar.gz
cd nagios-4.3.1

./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config 
make install-commandmode 
make install-webconf 

cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

/etc/init.d/nagios start
/etc/init.d/httpd start

NAPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
htpasswd –cb /usr/local/nagios/etc/htpasswd.users nagiosadmin 
PUBLICIP=`ifconfig venet0:0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" |head -1`

cd /root
cd nagios-plugins-2.2.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install 

chkconfig --add nagios
chkconfig --level 35 nagios on
chkconfig --add httpd
chkconfig --level 35 httpd on


cd /root
cat <<EOF>email.txt
Hello, 

Your Nagios server on Cloudmain.com has completed setup! You may now log in at: http://${PUBLICIP}/nagios
with the username: "nagiosadmin"
and the password : "${NAPW}"

Thank you!

--the server

EOF

mutt -s "Welcome to Nagios, Hosted by Cloudmain" genewitch@gmail.com < email.txt

