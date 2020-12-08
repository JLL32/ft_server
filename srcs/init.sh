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

# calling the shell since it's interactive so that the container doesn't close
# once the previous services/commands were done
bash
