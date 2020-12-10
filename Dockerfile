# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jll32 <jll32@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/10 17:04:26 by jll32             #+#    #+#              #
#    Updated: 2020/12/10 17:04:27 by jll32            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Pulling debian buster image from docker-hub to build upon it
FROM debian:buster

# Updating local package indexe
RUN apt update
# Updating local packages
RUN apt upgrade -y

### UTILITES
# Installing wget in order to download phpmyadmin and wordpress later on
RUN apt -y install wget


### Nginx
RUN apt -y install nginx
# adding our nginx configuration file
COPY srcs/mysite.conf /etc/nginx/sites-available/
# enabling the server by creating a symbolic link at sites-enabled/
RUN ln -s /etc/nginx/sites-available/mysite.conf /etc/nginx/sites-enabled/
# unlinking the default configuration
RUN unlink /etc/nginx/sites-enabled/default


### PHP
# Installing fastCGI process manager that generates dynamic content
# Intalling MySQL provider to allow PHP communicate with our database
RUN apt -y install php7.3-fpm php7.3-mysql php-mbstring


### MySQL
RUN apt-get -y install default-mysql-server


### WordPress
# Installing wordpress
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz
# Configuring wordpress
COPY srcs/wp-config.php wordpress/
COPY srcs/wordpress.sql wordpress/

### PhpMyAdmin
# installing PhpMyAdmin
WORKDIR /var/www/html/wordpress/
RUN wget \
https://files.phpmyadmin.net/phpMyAdmin/4.9.7/phpMyAdmin-4.9.7-english.tar.gz
RUN tar \
-xf phpMyAdmin-4.9.7-english.tar.gz && rm -rf phpMyAdmin-4.9.7-english.tar.gz
RUN mv phpMyAdmin-4.9.7-english phpMyAdmin
# configure PhpMyAdmin
COPY srcs/config.inc.php phpMyAdmin/
# remove error message concerning not having write access to tmp
RUN mkdir phpMyAdmin/tmp && chmod 777 phpMyAdmin/tmp


### SSL
# installing certutil which will be used by mkcert to create our SSL certificate
RUN apt-get -y install libnss3-tools
# copying the mkcert binary
COPY srcs/mkcert-v1.4.1-linux-amd64 /usr/local/bin/mkcert
RUN chmod +x /usr/local/bin/mkcert
# creating local CA with mkcert, which will create the SSL certificate
RUN mkcert -install
# generating the SSL_certificate and the SSL_certificate_key for the following
# domain names
RUN mkcert my-ssl-cert localhost 127.0.0.1
RUN mv my-ssl-cert+2.pem /etc/ssl/my-ssl-cert+2.pem
RUN mv my-ssl-cert+2-key.pem /etc/ssl/my-ssl-cert+2-key.pem


### DOCUMENTING EXPOSED PORTS
EXPOSE 80 443


### INITIATE SERVICES AND CONFIGURE DATABASE
COPY srcs/init.sh /usr/local/bin/init.sh
CMD bash /usr/local/bin/init.sh
