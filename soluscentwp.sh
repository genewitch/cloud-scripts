#!/bin/bash
# chkconfig: 345 99 10
# description: This script is designed to run once and then never again.
#
##
# written for solusvm guest running centos but adaptable to any "initial install" environment
#


#we're gunna work in root for now
cd /root

#centos uses yum. equivalent on debian/ubuntu would be
#    apt update
#    apt install -y [...]
yum -y update
yum install -y mysql-server php php-mysql

# mysql server is installed make sure it starts (on centos:)
/sbin/chkconfig --levels 235 mysqld on 

#download wordpress tarball
wget https://wordpress.org/latest.tar.gz

#extract, gzip, verbose, file=latest.tar.gz
tar -xzvf latest.tar.gz

#actually start mysqld, which defaults to an initial DB that lets the next commands run
service mysqld start

#on slow machines this can take a bit, so we sleep
sleep 10

#these are both tricks to get random data. I use a .gov site to get a dynamic page
#   this is then sha1 summed and i cut the proper amount of bytes off the front that are characters
RPW=`curl --silent http://tgftp.nws.noaa.gov/tgstatus/ | sha1sum |  head -c${1:-40}`
#   this is an alternate way to get the proper amount of characters randomly using /dev/urandom
WPAPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`

# the next two lines are debugging, they echo the values so if you're watching you know they're random or broken.
echo $RPW
echo $WPAPW

# RPW bash variable above is now set to the mysql ROOT password, the one that the end user has no need to know.
#    after a lot of consideration, we decided no one actually needed it, as physical or virtual physical access to the
#    storage of the db could reset the password easily.
echo "mysqladmin password setting"
/usr/bin/mysqladmin -u root password "$RPW"

# all sleeps were tested on the crappiest server AWS provides.
sleep 1

echo "mysql wp db setup"

# if you go to wordpress and read the quick install guide, this is basically all the commands they use.
mysql -uroot -p${RPW} -e "CREATE DATABASE vps_wp;\
 GRANT ALL PRIVILEGES ON vps_wp.* TO 'wpadmin'@'localhost' \
 IDENTIFIED BY '${WPAPW}'; FLUSH PRIVILEGES;"

 
sleep 1

# this structure->    cat <<EOF>foo.txt [...] EOF    <-
# is shell script for "write this to foo.txt" 
# this is how you do stuff in /etc/config in a boot script, for instance.
#     the stuff in between is, again, taken from the "really fast install guide" for wordpress on their site.
cat <<EOF>wp-config.php
<?php
define('DB_NAME', 'vps_wp');
define('DB_USER', 'wpadmin');
define('DB_PASSWORD', '${WPAPW}');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');


EOF

# allegedly random salt, directly from the horse's saltlick
#    a salt is a prefix to a database entry that makes it harder to reverse what the database entry was without knowing the salt.
curl https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php


# this is another "write a file using a script" section
cat <<'EOF'>>wp-config.php

$table_prefix  = 'wp_';

define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');

EOF

#take the file we wrote in the extracted wp directory and
cp wp-config.php wordpress/

# this is an .htaccess file that apache uses to change somesite.com/garbage.php?actual_page_you_want into somesite.com/actual_page_you_want
#    the terminology in apache2 is "rewrite" and this is the correct .htacess for wordpress by default.
cat <<'EOF'>>.htaccess
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress

EOF

#copy the new file to
cp .htaccess wordpress/

#tell the filesystem to actually really totally flush this all to real storage:
sync
sleep 1

## take our newly formed wordpress root with all of the files and folders set up correctly and copy it EXACTLY
rsync -avz wordpress/ /var/www/html

# we're rebooting apache since we changed an .htaccess or something
service httpd stop
sleep 2
service httpd start

echo $RPW
echo $WPAPW


# TO RESET MYSQL ROOT PASSWORD
#Stop the mysqld server. Edit my.cnf or my.ini, \
#add skip-grant-tables under [mysqld]. Restart mysqld.
#Connect with mysql -u root and do FLUSH PRIVILEGES. \
#If 5.7+, do: ALTER USER 'root'@'localhost' IDENTIFIED BY
#'newPassword'; If 5.6 or earlier, do: \
#SET PASSWORD FOR 'root'@'localhost' = PASSWORD('newPassword'); \
#Remove the added line from my.cnf and restart mysqld.

#
# End of your custom one-time commands
##


##
# This script will run once
# If you would like to run it again.  run 'chkconfig run-once on' then reboot.
#
chkconfig run-once off
chkconfig --del run-once
