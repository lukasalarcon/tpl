#!/bin/bash

# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.

#DEBUG
#set -x
#

##GLOBAL VARs
WSGI=/usr/share/secondlook/wsgi/slweb.conf
APA=/etc/httpd/conf.d/
CERTS=/etc/httpd/ssl

#
#END GLOBAL VARS

function CentOS7Packages (){
#
#Query Packages for Apache, Mod SSL, firewalld, wgi, 

_apache=$(rpm -qa httpd)
_openssl=$(rpm -qa openssl)
_fw=$(rpm -qa firewalld)
_wsgi=$(rpm -qa mod_wsgi)
_mod_ssl=$(rpm -qa mod_ssl)



#DETECTING APACHE
if [[ "$_apache" == "httpd"* ]]
        then
                echo "Package APACHE              [OK]"
        else
                echo "Proceed to Install APACHE"
 		sudo yum -y install httpd

                
fi

#DETECTING MOD SSL

if [[ "$_mod_ssl" == "mod_ssl"* ]]
        then
                echo "Package MOD SSL              [OK]"
        else
                echo "Proceed to Install MOD_SSL"
                sudo yum -y install mod_ssl


fi

#DETECTING OPENSSL

#OPENSSL DETECTION


if [[ "$_openssl" == "openssl"* ]]
        then
                echo "Package OPENSSL              [OK]"
        else
                echo "Proceed to Install OPENSSL"
                sudo yum -y install openssl

fi

#FIREWALL DETECTION
if [[ "$_fw" == "firewalld"* ]]
        then
                echo "Package FIREWALLD              [OK]"
        else
                echo "Proceed to Install FIREWALLD"
                sudo yum -y install firewalld

fi

#WSGI MODULE FOR APACHE DETECTION
if [[ "$_wsgi" == "mod_wsgi"* ]]
        then
                echo "Package MOD_WSGI              [OK]"
        else
                echo "Proceed to Install Module"
                sudo yum -y install mod_wsgi 


fi











#END CentOS7Packages
}

function CentOS7EnableApachePorts () {



#ENABLE FIREWALLD
sudo systemctl enable firewalld

#START FIREWALLD
sudo systemctl start firewalld


#ADD PERMANENT PORT TO APACHE 80
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent


#ADD PERMANENT PORT TO 443
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent

#RELOAD RULES
sudo firewall-cmd --reload


#END Enable Apache Ports
}



function CentOS7Start () {
#start function
#ROUTINES FOR START 

#enable on BOOT Apache
sudo systemctl enable httpd.service


#start apache

sudo systemctl start httpd


#END CentOS7start
}


function CentOS7Setting (){

#check SELinux
#we need to check SELINUX!!!!



#Command when SELinux is Enabled
sudo setsebool -P httpd_read_user_content 1
#copy to Apache
sudo cp $WSGI $APA. 



}

function CentOS7SSL () {


#CREATE FOLDER FOR TEMPORAL STORAGE

_TMP=/etc/httpd/ssl


if [ -d "$_TMP" ]
then
	echo "$_TMP exists"
else
	sudo mkdir $_TMP
fi
 

#CREATE CERTIFICATE

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $_TMP/apache_sl.key -out $_TMP/apache_sl.crt

#SAVE ORIGINAL CERTS FROM APACHE REPOSITORY
#CREATE VARS 
_CAPA_TMP=/etc/pki/tls/certs
_KAPA_TMP=/etc/pki/tls/private
#BACKUPS CERTS
cp $_CAPA_TMP/localhost.crt $_TMP 
cp $_KAPA_TMP/localhost.key $_TMP 


#COPY CERTS TO APACHE SSL FOLDER
cp $CERTS/apache_sl.key $_KAPA_TMP/ 
cp $CERTS/apache_sl.crt $_CAPA_TMP/ 

#comment SSLCertificateKeyFile in ssl.conf

sed -i '/SSLCertificateKeyFile/s/^/#/' "$APA"ssl.conf

# APPEND NEW CERTIFICATE LINES AFTER SSLCertificateKeyFile
sed -i '/#SSLCertificateKeyFile/a \
        SSLCertificateKeyFile \/etc\/pki\/tls\/private\/apache_sl.key \
        ' "$APA"ssl.conf


#comment SSLCertificateFile in ssl.conf
sed -i '/SSLCertificateFile/s/^/#/' "$APA"ssl.conf

sed -i '/#SSLCertificateFile/a \
        SSLCertificateFile \/etc\/pki\/tls\/certs\/apache_sl.crt \
        ' "$APA"ssl.conf



}

function ModifyApacheServer () {
#MODIFY ROUTEINES FOR APACHE
#USING SED FOR APPEND LINES FOR APACHE TO SLWEB
sed -i '/Require all granted/a \
	AuthType Basic \
	AuthName "Restricted Content" \
	AuthUserFile \/etc\/httpd\/conf.d\/.htpasswd \
	Require valid-user' "$APA"slweb.conf


#CHANGE THE REQUIRED ALL ACCESS TO COMMENT
sed -i '/Require all granted/s/^/#/' "$APA"slweb.conf

#END Modify Apache Server
}

function CreateApacheUser () {
#CREATE AN APACHE USER FOR SECURITY

echo "Please, enter a user for the Apache Server:"
read auser
#SET USER, PASSWORD WILL BE PROMPTED
htpasswd -c $APA.htpasswd $auser


#END APACHE USER
}


## MAIN 



CentOS7Packages
	CentOS7Start
			CentOS7Setting
				CentOS7SSL 
			ModifyApacheServer
		CreateApacheUser
CentOS7EnableApachePorts
