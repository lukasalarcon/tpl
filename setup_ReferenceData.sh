#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.

#DEBUG PROCESS
set -x
#END DEBUG

#GLOBAL VARS
#
VERSION=9
MYS=/etc/my.cnf
#PHPSC=$(ls -LR tmpp/secondlook-phpscripts*.tar.gz)
PHPSC=
SECLOOK=/usr/share/secondlook/
APA=/etc/httpd/conf/httpd.conf
#
#END GLOBAL VARS


function CentOS7_Install () {
#start CentOS7_Install


#find if packages are already installed
_apache=$(rpm -qa httpd)
_mysqlserver=$(rpm -qa mariadb-server)
_php=$(rpm -qa php)
_phpsql=$(rpm -qa php-mysql)
_mariadbv=$(rpm -qa mariadb)
_bc=$(rpm -qa bc)
#YUM?

#APACHE
if [[ "$_apache" == "httpd"* ]]
        then
                echo "Package APACHE		              [OK]"
        else
                echo "Proceed to Install APACHE"
                sudo yum -y install httpd


fi


#M DB SERVER 
if [[ "$_mysqlserver" == "mariadb-server"* ]]
        then
                echo "Package MARIADB SERVER              [OK]"
        else
                echo "Proceed to Install MARIADB SERVER"
                sudo yum -y install mariadb-server
fi




#MARIA DB
if [[ "$_mariadbv" == "mariadb"* ]]
        then
                echo "Package MARIADB DB              [OK]"
        else
                echo "Proceed to Install MARIADB DB"
                sudo yum -y install mariadb
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


#BC for Calculations
if [[ "$_bc" == "bc"* ]]
        then
                echo "Package BC                          [OK]"
        else
                echo "Proceed to Install Calculator"
                sudo yum -y install bc


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
# IT WILL LAUNCH A COSMETIC ERROR!!! A BUG FROM MARIADB
echo "A cosmetic error. Keep going"
sudo /usr/bin/mysql_secure_installation

}

function DataBaseSetting () {
#Double check if my.cfg exists

#WE EXPECT A MEDIUM LOAD SERVER
_MEDCFG=/usr/share/mysql/my-medium.cnf

if [ -f $MEDCFG ]
	then
		#WE ARE GOING TO COPY MEDIUM CONFIG TO FINAL CONFIG
		cp $_MEDCFG $MYS
	else
		echo "Unfortunately we cannot find MariaDb setting file. We need to stop. Sorry."
		exit 1	
fi


#check file for DataBase Settings again

	if [ -f $MYS  ]
		then
			echo "Found MySQL/MAriaDB"
			#CAPTURE TOTAL MEMORY
				TOMEM=$(free -k | head -2|cut -c10-20 | tail -1)
					#CALCULATE 75%
					PERC=$(( $TOMEM * 75 / 100))
					#CONVERT TO GB
					PERC=$(echo "scale=0; $PERC/1048576" | bc)					
					#WE NEED TO ROUND THE VALUE DOWN FOR BASH ISSUES
					PERC=${PERC%%.*}

					#MIMIMUM MEMORY SERVER PROTECTION: IF A SERVER HAS LESS THAN 1 GB, SET 1 GB (BETA EDITION ISSUE)
					if  [ "$PERC" -le "1" ]
 						then
        						PERC=1
					fi


						#INSERT LINES FOR MEMORY MANAGEMENT
							sed -i '/\[mysqld\]/a max_allowed_packet =16M' $MYS
							sed -i "/\[mysqld\]/a innodb_buffer_pool_size = ${PERC}G" $MYS
							sed -i '/\[mysqld\]/a innodb_file_per_table = 1' $MYS
						#SYSTEM RESTART
						sudo systemctl restart mariadb.service				
			
		else
			echo "We cannot find MySQL/MariaDB."
			exit 1
	fi
}
	

function SqlScript () {

#START LOCAL SCRIPTS FOR REFERENCE LOOKSERVER



PASSWORD=

	

		echo "Please, enter the MARIADB/MYSQL password for database creation:"

		read PASSWORD




#CREATE DATABASE
_SCRIPTA="CREATE DATABASE pagehash;"

#CREATE READ ONLY USER
_SCRIPTB="CREATE USER 'secondlook_ro'@'localhost';\
 GRANT USAGE ON * . * TO 'secondlook_ro'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0;\
 GRANT SELECT ON \`pagehash\`. * TO 'secondlook_ro'@'localhost';"
#CREATE WRITE USER
_SCRIPTC="CREATE USER 'secondlook_rw'@'localhost';\
 GRANT USAGE ON * . * TO 'secondlook_rw'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0;\
 GRANT SELECT ON \`pagehash\` . * TO 'secondlook_rw'@'localhost' WITH GRANT OPTION ;"


#START THE DATABASE CREATION 
mysql -h "localhost" -u "root" -p$PASSWORD -Bse "$_SCRIPTA"

#check for database creation
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

while [ $YESNO == "n" || $YESNO == "N" ]
do  
   #VALIDATE PHPSCRIPTS 
   echo "Please, enter the Reference Data Source:(/path/to/secondlook-phpscripts.tar.gz):"
   echo "If you dont have access, please consult your ForcePoint Representative"
   read PHPSC

   echo "Is $PHPSC file correct?(y/n)?
   read YESNO
done






	if  [ ! -z $PHPSC ]
		then
			#UNTAR SOURCE CODE FROM TPL
			sudo tar xvf $PHPSC -C /
			

			#CHECK IF VAR/WWW EXISTS	
			if [ ! -d /var/www ]; then
  			# Control will enter here if /var/www doesn't exist.
			echo "Folder /var/www doesn't exist. Please, install Apache!!"
			exit 1				
			fi

			
                        if [ -f /usr/share/secondlook/ph_query.php && -f /usr/share/secondlook/phdb_config.php ]
			 then
			  #CREATE SOFT LINKS
			  sudo ln -s /usr/share/secondlook/ph_query.php /var/www/ph_query.php
			  sudo ln -s /usr/share/secondlook/phdb_config.php /var/www/phdb_config.php
			
			 else
			  echo "We cannot find secondlook scripts for Reference Data!!"
			  exit 1		
			fi

		else
			echo "We cannot find secondlook scripts!!! Try again!"
			exit 1	
	fi	



}

function SecondLookDetection () {
#Detects if it is a SecondLook Server


	if [ -d SECLOOK ]
		then

			echo "TPL for LINUX detected. Reference Data server aborted. You need a FRESH NEW SERVER"
			exit 1

		else

			echo "FRESH NEW SERVER DETECTED"

	fi 





}




function ModifyApacheServer () {
#MODIFY ROUTINES FOR APACHE REFERENCE 




	if [ -f $APA ]
		then


		#USING SED FOR APPEND LINES FOR APACHE  
		sed -i '/\/var\/www\/html/a \
        		AuthType Basic \
        		AuthName "Second Look Repository" \
        		AuthUserFile \/etc\/httpd\/conf.d\/.htpasswd \
        		Require valid-user' $APA
		#CHANGE THE REQUIRED ALL ACCESS TO COMMENT
		sed -i '/Require all granted/s/^/#/' $APA
		#RESTART APACHE SERVER

	        #RECONFIG APACHE CONF FILE?


		if [ -f /usr/sbin/a2enconf ]
		 then
			sudo /usr/sbin/a2enconf sl-auth	
			#RESTART APACHE SERVER
			sudo systemctl restart httpd.service
		 else
		 echo "We cannot find a2enconf. Program Aborted."
		 exit 1
		fi
		

		#CREATES USER AND PASSWORD WITH THE SAME KEY
		
		echo "Please, enter the TPL/SecondLook Key:"

		echo MYKEY

		sudo htpasswd -bc /etc/httpd/conf.d/.htpasswd $MYKEY $MYKEY

	
		else
		echo "We cannot find Apache config file"
		exit 1	
	fi

#END Modify Apache Server
}


















function SaveGuard () {
#ONLY FOR URGENCY SITUATIONS

echo ""
#mysql -h localhost -u root -p$PASSWORD -Bse "select host, user, password from mysql.user;"

#mysql -h localhost -u root -p$PASSWORD -Bse "DROP USER 'secondlook_ro'@'localhost'"



#EMERGENCY SITUATIONS
}


#MAIN

	CentOS7_Install 
		SecondLookDetection
			StartServices
		          DataBaseSetting
	                 SqlScript
	        ScriptsPhp
	 ModifyApacheServer
