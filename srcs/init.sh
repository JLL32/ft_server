# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    init.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jll32 <jll32@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/10 17:01:05 by jll32             #+#    #+#              #
#    Updated: 2020/12/10 17:01:06 by jll32            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

### start services
service nginx start
service mysql start
service php7.3-fpm start
service php7.3-fpm status

### setting up database
echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password
mysql -u root --skip-password wordpress < wordpress.sql

# keeps logging from null device so the container can keep alive
tail -f /dev/null
