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
yum -y install nagios nagios-plugins-all nagios-plugins-nrpe nrpe php httpd
chkconfig httpd on && chkconfig nagios on
service httpd start && service nagios start

# Some swap (2GB)
dd if=/dev/zero of=/swap bs=1024 count=2097152
mkswap /swap && chown root. /swap && chmod 0600 /swap && swapon /swap
echo /swap swap swap defaults 0 0 >> /etc/fstab
echo vm.swappiness = 0 >> /etc/sysctl.conf && sysctl -p
