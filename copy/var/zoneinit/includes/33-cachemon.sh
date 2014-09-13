log "Creating Cache Web Monitoring"
cd /opt/local/www/wordpress
mkdir memcached
cd memcached
curl -kLO  http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz
tar -xvzf phpMemcachedAdmin-1.2.2-r262.tar.gz
rm phpMemcachedAdmin-1.2.2-r262.tar.gz
cd /opt/local/www/wordpress
mkdir opcache
cd opcache
curl -kLO  https://raw.github.com/rlerdorf/opcache-status/master/opcache.php
chown -R www:www /opt/local/www/wordpress