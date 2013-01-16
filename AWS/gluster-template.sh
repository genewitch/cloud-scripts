#!/bin/bash
#
# This will run when the cloud server comes online the first time, taking care of all initial setup.
# This is meant to bring up a new host in under 4 minutes.
#
# Edit    newhostnamedb1
HOSTNAME="SETME.aws.example.com"
DOMAINTAIL="aws.example.com"

# networkings
logger "Setting hostname to: ${HOSTNAME}"
hostname ${HOSTNAME}
sed -i s/HOSTNAME=localhost.localdomain/HOSTNAME=${HOSTNAME}/ /etc/sysconfig/network

logger "adding  $DOMAINTAIL to /etc/resolv.conf"
sed -i "s/search .*/`grep search /etc/resolv.conf |awk '{ print $1 " $DOMAINTAIL " $2 }'`/" /etc/resolv.conf

# add gluster.repo (this will go out of date quickly!)
logger "Adding gluster repository"
cat > /etc/yum.repos.d/gluster.repo <<KNOLL
[gluster]
name=gluster-repo epel6
baseurl=http://download.gluster.org/pub/gluster/glusterfs/3.3/3.3.1/EPEL.repo/epel-6/x86_64/
enabled=1
gpgcheck=0
KNOLL

# installings (remove puppet if you're not going to use it 
# ruby-shadow as well
yum -y update
yum -y install puppet                  \
ruby-shadow httpd php php-gd php-soap   \
php-devel glusterfs-server-3.3.1 php-pdo \
php-pecl-apc php-pecl-memcached php-xml   \
php-mysql php-mbstring php-pecl-xdebug     \
glusterfs-fuse-3.3.1 glusterfs-devel-3.3.1  \
glusterfs-3.3.1 php-imap php-mcrypt php-pear \
glusterfs-geo-replication screen telnet

# puppetings (Uncomment if you know what you're doing)
#logger "Starting puppet catalogue run"
#puppetd --test --verbose --debug 2>&1 > /dev/null

logger "initializing LVM"
umount /dev/xvdb
pvcreate /dev/xvdb
vgcreate gluster /dev/xvdb
lvcreate -l100%FREE gluster
mkfs.ext4 /dev/gluster/lvol0
mkdir /gluster
mount /dev/gluster/lvol0 /gluster
logger "completed LVM"

#finishings
logger "completed custom cloud-init"
#-------------------------------------------------
