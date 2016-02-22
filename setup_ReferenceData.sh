#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.

#DEBUG PROCESS
set -x
#END DEBUG

#GLOBAL VARS
#
MYS=/etc/my.cnf
#
#END GLOBAL VARS


function CentOS7_Install () {
#start CentOS7_Install


#find if packages are already installed
_apache=$(rpm -qa httpd)
_mysqlserver=$(rpm -qa mariadb-server)
_php=$(rpm -qa php)
_phpsql=$(rpm -qa php-mysql)
#YUM?

#APACHE
if [[ "$_apache" == "httpd"* ]]
        then
                echo "Package APACHE		              [OK]"
        else
                echo "Proceed to Install APACHE"
                sudo yum -y install httpd


fi


#M DB
if [[ "$_mysqlserver" == "mariadb-server"* ]]
        then
                echo "Package MARIADB SERVER              [OK]"
        else
                echo "Proceed to Install MARIADB SERVER"
                sudo yum -y install mariadb-server
fi


#PHP
if [[ "$_php" == "php"* ]]
        then
                echo "Package PHP              [OK]"
        else
                echo "Proceed to Install PHP"
                sudo yum -y install php


fi


#PHMYSQL
if [[ "$_phpsql" == "php-mysql"* ]]
        then
                echo "Package PHP-SQL              [OK]"
        else
                echo "Proceed to Install PHP-SQL"
                sudo yum -y install php-mysql 
fi


#end setup function
}


function StartServices () {


#ENABLE MARIADB
sudo systemctl enable mariadb.service

#ENABLE HTTP APACHE SERVICE
sudo systemctl enable httpd.service

#START MARIADB
sudo systemctl start mariadb.service

#START APACHE SERVICE
sudo systemctl start httpd.service

#START MYSQL SERVICES
sudo mysql_secure_installation

}

function DataBaseSetting () {


#check file for DataBase Settings

	if [ -f $MYS  ]
		then
			echo "Found MySQL/MAriaDB"
			#CAPTURE TOTAL MEMORY
				TOMEM=$(free | head -2|cut -c10-20 | tail -1)
					#CALCULATE 75%
					PERC=$(( $TOMEM * 75 / 100))
					#CONVERT TO GB
					PERC=$(($PERC / 1024))					
						#INSERT LINES FOR MEMORY MANAGEMENT
							sed -i '/\[mysqld\]/a max_allowed_packet = 16M' $MYS
							sed -i "/\[mysqld\]/a innodb_buffer_pool_size = ${PERC}G" $MYS
							sed -i '/\[mysqld\]/a innodb_file_per_table   = 1' $MYS
						#SYSTEM RESTART
						sudo systemctl restart mariadb.service				
			
		else
			echo "We cannot find MySQL/MariaDB"
			exit 1
	fi
}


function SqlScript () {

_SCRIPTA="CREATE USER 'secondlook_ro'@'localhost'\
	GRANT USAGE ON * . * TO 'secondlook_ro'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0\
	GRANT SELECT ON `pagehash` . * TO 'secondlook_ro'@'localhost';"

_SCRIPTB="CREATE USER 'secondlook_rw'@'localhost'\
        GRANT USAGE ON * . * TO 'secondlook_rw'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0\
        GRANT SELECT ON `pagehash` . * TO 'secondlook_rw'@'localhost'; WITH GRANT OPTION ;"


mysql mydb -e $_SCRIPTA

mysql mydb -e $_SCRIPTB

}





#MAIN

	CentOS7_Install 
		StartServices
		DataBaseSetting
