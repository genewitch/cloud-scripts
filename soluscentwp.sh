#!/bin/bash
# chkconfig: 345 99 10
# description: This script is designed to run once and then never again.
#
##
# Beginning of your custom one-time commands
#

cd /root
yum -y update
yum install -y mysql-server php php-mysql
/sbin/chkconfig --levels 235 mysqld on 
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

service mysqld start
sleep 10

RPW=`curl --silent http://tgftp.nws.noaa.gov/tgstatus/ | sha1sum |  head -c${1:-40}`
WPAPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`

echo $RPW
echo $WPAPW

echo "mysqladmin password setting"
/usr/bin/mysqladmin -u root password "$RPW"

sleep 1

echo "mysql wp db setup"

mysql -uroot -p${RPW} -e "CREATE DATABASE vps_wp;\
 GRANT ALL PRIVILEGES ON vps_wp.* TO 'wpadmin'@'localhost' \
 IDENTIFIED BY '${WPAPW}'; FLUSH PRIVILEGES;"

sleep 1

cat <<EOF>wp-config.php
<?php
define('DB_NAME', 'vps_wp');
define('DB_USER', 'wpadmin');
define('DB_PASSWORD', '${WPAPW}');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');


EOF

curl https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php

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


cp wp-config.php wordpress/

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

cp .htaccess wordpress/
sync
sleep 1

rsync -avz wordpress/ /var/www/html
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
