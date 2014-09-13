
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

log "Installing Wordpress via wp_cli"

cd /opt/local/www/wordpress
/opt/local/bin/wp core download
/opt/local/bin/wp core config --dbname="wordpressdb" --dbuser="wordpressdba" --dbpass="$WP_PW" --dbprefix="_wpmy"
/opt/local/bin/wp core install --url="${WEBUI_ADDRESS}" --title="Wordpress Site" --admin_user="onyxadmin" --admin_password="onyxpass" --admin_email="mark@onyxit.com.au"
/opt/local/bin/wp plugin install wordpress-seo
/opt/local/bin/wp plugin install nginx-helper
/opt/local/bin/wp plugin activate wordpress-seo
/opt/local/bin/wp plugin activate nginx-helper

gsed -i "s/%WEBUI_ADDRESS%/${WEBUI_ADDRESS}/" /etc/motd
gsed -i "s/%WP_PW%/${WP_PW}/" /etc/motd