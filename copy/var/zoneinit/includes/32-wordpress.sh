
log "generating ssl certs"
/opt/local/etc/nginx/sslgen.sh

log "enabling http services"
svcadm enable nginx
svcadm enable php-fpm
svcadm enable memcached


log "Creating Wordpress DB"

WP_PW=$(od -An -N4 -x /dev/random | head -1 | tr -d ' ');

echo "CREATE DATABASE wordpressdb;" >> /tmp/wp.sql
echo "grant all privileges  on wordpressdb.* to wordpressdba@localhost identified by '$WP_PW';" >> /tmp/wp.sql
echo "FLUSH PRIVILEGES;" >> /tmp/wp.sql

log "Injecting Wordpress SQL"
MYSQL_PW=$(/opt/local/bin/grep MySQL /etc/motd | /opt/local/bin/awk '{$1=""; print $6}');
/opt/local/bin/mysql -u root -p$MYSQL_PW < /tmp/wp.sql

log "determine the webui address for the motd"

WEBUI_ADDRESS=$PRIVATE_IP

if [[ ! -z $PUBLIC_IP ]]; then
        WEBUI_ADDRESS=$PUBLIC_IP
fi

log "mdata-get wordpress metadata"
WPSITE_URL=${WPSITE_URL:-$(mdata-get wpsite_url 2>/dev/null)} || \
WPSITE_URL=${WEBUI_ADDRESS};

WPHOME_URL=${WPHOME_URL:-$(mdata-get wphome_url 2>/dev/null)} || \
WPHOME_URL=${WEBUI_ADDRESS};

WPADMIN_USR=${WPADMIN_USR:-$(mdata-get wpadmin_usr 2>/dev/null)} || \
WPADMIN_USR=${wpadmin};

WPADMIN_PSW=${WPADMIN_PSW:-$(mdata-get wpadmin_psw 2>/dev/null)} || \
WPADMIN_PSW=${wppass};

WPADMIN_EMA=${WPADMIN_EMA:-$(mdata-get wpadmin_ema 2>/dev/null)} || \
WPADMIN_EMA=${admin@site.local};

log "Installing Wordpress via wp_cli"

cd /opt/local/www/wordpress
/opt/local/bin/wp core download
/opt/local/bin/wp core config --dbname="wordpressdb" --dbuser="wordpressdba" --dbpass="$WP_PW" --dbprefix="_wpmy"
/opt/local/bin/wp core install --url="${WPSITE_URL}" --title="Wordpress Site" --admin_user="${WPADMIN_USR}" --admin_password="${WPADMIN_PSW}" --admin_email="${WPADMIN_EMA}"
/opt/local/bin/wp plugin install wordpress-seo
/opt/local/bin/wp plugin install nginx-helper
/opt/local/bin/wp plugin activate wordpress-seo
/opt/local/bin/wp plugin activate nginx-helper
/opt/local/bin/wp rewrite structure '/%postname%/'

log "customizing wp-config.php"
gsed -i "37i define ('WP_POST_REVISIONS', 4);" /opt/local/www/wordpress/wp-config.php
gsed -i "38i define('DISALLOW_FILE_EDIT', true);" /opt/local/www/wordpress/wp-config.php
gsed -i "39i define('DISABLE_WP_CRON', true);" /opt/local/www/wordpress/wp-config.php

log "customizing cron"
crontab -l > /tmp/mycron
echo "45 * * * * /opt/local/bin/php /opt/local/www/wordpress/wp-cron.php >/dev/null 2>&1" >> /tmp/mycron
crontab /tmp/mycron

gsed -i "s/%WEBUI_ADDRESS%/${WEBUI_ADDRESS}/" /etc/motd
gsed -i "s/%WP_PW%/${WP_PW}/" /etc/motd
gsed -i "s/%WPSITE_URL%/${WPSITE_URL}/" /etc/motd
gsed -i "s/%WPADMIN_USR%/${WPADMIN_USR}/" /etc/motd
gsed -i "s/%WPADMIN_PSW%/${WPADMIN_PSW}/" /etc/motd
