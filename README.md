mi-wordpress
============
Please refer to [joyent/mibe](https://github.com/joyent/mibe) to create a provisionable image using this repo.
Wordpress with FastCGI + Nginx + opcache

## Overview
A Wordpress MIBE repo that builds a very fast Wordpress dedicated vps environment. Compiled with Nginx 1.7.4, FastCGI Cache Purge and Geoip support. Configured with MySQL Percona and php-fpm using opcache. Will auto-tune my.cnf in relation to zone memory size at the time of provisioning. 

All pages are statically cached and purged from the cache when a page/post is changed or updated. Extremely efficient - configured to serve hundreds of concurrent Wordpress requests at blazing speeds with minimal CPU or Database Load.

Unique Passwords are generated for MySQL root user as well as wordpress database. All information is passed into /etc/motd after zone init.

## metadata support
Certain metadata passed to the JSON payload file at creation time will dictate how the new wordpress instance is configured. Currently Supported Metadata:

    wpsite_url - wordpress site url
    wphome_url - wordpress home url
    wpadmin_usr - wordpress admin user
    wpadmin_psw - wordpress admin password
    wpadmin_ema - wordpress admin password
If no metadata is passed then default username and password will be used for wordpress admin user:
      
      Admin User: wpadmin
      Admin Password: wppass
      Admin Email: admin@site.local
example:  [Project FiFo Metadata in use](http://abn.me/mdata "metadata screenshot")
result:  [Custom Machine Provisioned](http://abn.me/mdresu "metadata result screenshot")
## ssl support
An auto generated self signed certificate is created at zone init and there is a ready to go nginx conf file that just has to be enabled in: 

    /opt/local/etc/nginx/sites-available/wordpress-ssl.conf
Please note in order for selective cache purge to work with SSL you will need to install a valid SSL Certificate for your site or figure out how to make "curl" ignore SSL validation.

## 0.1.1 Changelog
* Compiles Nginx 1.7.4 with FastCGI Cache purge Module, Geoip and HTTPS SPDY support
* Generates unique self-signed SSL certs on zoneinit /var/db/ssl/certs/
* Nginx configured to store FastCGI cache in /var/run/nginx-cache
* Configures php 5.5 with php-fpm configured to use opcache
* Mdata-get zoneinit support for "wpsite_url" "wphome_url" "wpadmin_usr" "wpadmin_psw" "wpadmin_ema"
* If mdata-get metadata is not supplied it will fall-back to defaults
* Generates unique mysql root password
* Generates unique wordpress db password
* All custom information displayed in /etc/motd
* At zone init - installs and configures LATEST version of Wordpress via wp-cli
* At zone init - installs/activates LATEST "Yoast wordpess SEO" and "nginx cache plugin" via wp-cli
* At optimal wp-config.php settings for efficiency
* Will auto purge wordpress page/post from the cache on edit or change
* Configured to serve hundreds of concurrent requests at blazing speeds with minimal cpu or db load
* Enables system cron entry for wp-cron
* Auto tunes MySQL Percona my.cnf based on memory provisioning size
* Includes optional wordpress-ssl.conf to be used should you want ssl site
* Installs https://github.com/rlerdorf/opcache-status in webroot/opcache/opcache.php only accessible from specified ip range in nginx wordpress.conf - currently 10.1.1.0/24 for Cache Monitoring

