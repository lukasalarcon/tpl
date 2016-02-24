#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.

#DEBUG PROCESS
set -x
#END DEBUG

#GLOBAL VARS
#
VERSION=
MYS=/etc/my.cnf
PHPSC=$(ls -LR tmpp/secondlook-phpscripts*.tar.gz)
SECLOOK=/usr/share/secondlook/
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

#START LOCAL SCRIPTS FOR REFERENCE LOOKSERVER



PASSWORD=

	

		echo "Please, enter the MARIADB/MYSQL password for database creation:"

		read PASSWORD





#_SCRIPTA="CREATE DATABASE pagehash"

_SCRIPTB="CREATE USER 'secondlook_ro'@'localhost';\
 GRANT USAGE ON * . * TO 'secondlook_ro'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0;\
 GRANT SELECT ON \`pagehash\`. * TO 'secondlook_ro'@'localhost';"

_SCRIPTC="CREATE USER 'secondlook_rw'@'localhost';\
 GRANT USAGE ON * . * TO 'secondlook_rw'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0;\
 GRANT SELECT ON \`pagehash\` . * TO 'secondlook_rw'@'localhost' WITH GRANT OPTION ;"

#mysql -h "localhost" -u "root" -p$PASSWORD -Bse "CREATE DATABASE pagehash;"

#visual for database creation
PAGEH=$(mysql -h "localhost" -u "root" -p$PASSWORD  -Bse "show DATABASES;"| grep pagehash)

	if [ -z $PAGEH ]
		then
			echo "DATABASE NOT CREATED"
			exit 1
		else
			echo "DATABASE CREATED"
			
			#START THE FIRST SCRIPT FOR SECONDLOOK

				mysql -h localhost -u "root" -p$PASSWORD -Bse "$_SCRIPTB"

			#CHECK FOR ERROR IN THE EXECUTION

			if [ $? -eq 0 ]; then
				echo "OK. SCRIPTB SUCCESSFULLY EXECUTED."
				else
				echo "FAILED. SCRIPTB NOT EXECUTED."
				
			fi

			#START THE SECOND SCRIPT

				mysql -h localhost -u "root" -p$PASSWORD -Bse "$_SCRIPTC"

			
			#CHECK FOR ERROR IN THE EXECUTION
					
			if [ $? -eq 0 ]; then
                                echo "OK. SCRIPTC SUCCESSFULLY EXECUTED."
                                else
                                echo "FAILED. SCRIPTC NOT EXECUTED."

                        fi




	fi	


}

function ScriptsPhp() {


#VALIDATE PHPSCRIPTS 

	if  [ ! -z $PHPSC ]
		then
			#UNTAR SOURCE CODE FROM TPL
			sudo tar xvf $PHPSC -C /
			
			#CREATE SOFT LINKS
			sudo ln -s /usr/share/secondlook/ph_query.php /var/www/ph_query.php
			sudo ln -s /usr/share/secondlook/phdb_config.php /var/www/phdb_config.php
			

		else
			echo "We cannot find scripts!!! Try again!"
			exit 1	
	fi	



}

function SecondLookDetection () {
#Detects if it is a SecondLook Server


	if [ -d SECLOOK ]
		then

			echo "TPL for LINUX detected. Reference Data server aborted. You need a FRESH NEW SERVER"

		else

			echo "FRESH NEW SERVER DETECTED"

	fi 





}


#MAIN

#	CentOS7_Install 
#		StartServices
	#	DataBaseSetting
	SqlScript
