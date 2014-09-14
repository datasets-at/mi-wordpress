log "Creating Cache Web Monitoring"
cd /opt/local/www/wordpress
mkdir opcache
cd opcache
curl -kLO  https://raw.github.com/rlerdorf/opcache-status/master/opcache.php
chown -R www:www /opt/local/www/wordpress