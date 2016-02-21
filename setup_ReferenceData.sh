#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.



#DEBUG PROCESS
set -x
#END DEBUG

#GLOBAL VARS
#

#
#END GLOBAL VARS


function CentOS7_Install (){
#start CentOS7_Install


#find if packages are already installed
_apache=$(rpm -a httpd)
_mysqlserver=$(rpm -a mariadb-server)
_php=$(rpm -qa php)
_phpsql=$(rpm -qa php-mysql)
#YUM?

#APACHE
if [[ "$_apache" == "httpd"* ]]
        then
                echo "Package APACHE              [OK]"
        else
                echo "Proceed to Install APACHE"
                sudo yum -y install httpd


fi


#M DB
if [[ "$_mysqlserver" == "mariadb-server"* ]]
        then
                echo "Package MARIADB SERVER              [OK]"
        else
                echo "Proceed to Install APACHE"
                sudo yum -y install mariadb-server


fi

}

#PHP
if [[ "$_php" == "php"* ]]
        then
                echo "Package PHP              [OK]"
        else
                echo "Proceed to Install PHP"
                sudo yum -y install php


fi


#PHMYSQL
if [[ "$_phpsql" == "php-sql"* ]]
        then
                echo "Package PHP-SQL              [OK]"
        else
                echo "Proceed to Install APACHE"
                sudo yum -y install php-sql 


fi


#end setup function
}


function StartServices () {


#ENABLE MARIADB
sudo systemctl enable mariadb.service

#ENABLE HTTP APACHE SERVICE
sudo systemctl enable httpd.service

#START MARIADB
sudo systemctl start mariadb.service

#START APACHE SERVICE
sudo systemctl start httpd.service

#START MYSQL SERVICES
sudo mysql_secure_installation




}

function DataBaseSetting () {


#check file for DataBase Settings

	if [ -f /etc/my.cnf ]
		then
			echo "Found MySQL/MAriaDB"
			#CAPTURE TOTAL MEMORY
			TOMEM=$(free | head -2|cut -c10-20 | tail -1)
			
			
		else
			echo "we cannot find MySQL/MariaDB"
	fi








}


