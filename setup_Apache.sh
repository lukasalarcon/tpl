#!/bin/bash
#DEBUG
set -x
#

##GLOBAL VARs
WSGI=/usr/share/secondlook/wsgi/slweb.conf
APA=/etc/httpd/conf.d/
CERTS=/etc/httpd/ssl

#
#END GLOBAL VARS

function CentOS7Packages (){

_apache=$(rpm -qa | grep httpd| head -1)
_openssl=$(rpm -qa openssl)
_fw=$(rpm -qa firewalld)

if [[ "$_apache" == "httpd"* ]]
        then
                echo "Package APACHE              [OK]"
        else
                echo "Proceed to Install APACHE"
 		sudo yum -y install httpd
		sudo yum -y install mod_ssl

                
fi

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



#END CentOS7Packages
}

function EnableApachePorts () {


#CHECK IPTABLES 
sudo systemctl status iptables

#ENABLE FIREWALLD
sudo systemctl enable firewalld

#START FIREWALLD
sudo systemctl start firewalld

#START IPTABLES
sudo systemctl start iptables


#ADD PERMANENT PORT TO APACHE 80
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent

#ADD PERMANENT PORT TO 443
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent

#RELOAD RULES
sudo firewall-cmd --reload






#END Enable Apache POrts
}









function CentOS7Start () {
#start function
#ROUTINES FOR START 

#start apache
sudo systemctl start httpd
#enable on BOOT
sudo systemctl enable httpd.service

}

function CentOS7Addons () {


#install module wsgi over apache
sudo yum install mod_wsgi


}

function CentOS7Setting (){

#check SELinux

#Command when SELinux is Enabled
sudo setsebool -P httpd_read_user_content 1
#copy to Apache
sudo cp $WSGI $APA. 



}

function CentOS7SSL () {


#CREATE FOLDER

sudo mkdir /etc/httpd/ssl

#CREATE CERTIFICATE

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/apache_sl.key -out /etc/httpd/ssl/apache_sl.crt

#REWRITE CERTS TO APACHE SSL
yes | cp -rf $CERTS/apache_sl.key /etc/pki/tls/certs/localhost.crt
yes | cp -rf $CERTS/apache_sl.crt /etc/pki/tls/private/localhost.key





}

#function ModifyApacheServer () {
#MODIFY ROUTEINES FOR APACHE
#USING SED FOR APPEND LINES FOR APACHE TO SLWEB
sed -i '/Require all granted/a \
	AuthType Basic \
	AuthName "Restricted Content" \
	AuthUserFile \/etc\/httpd\/conf.d\/.htpasswd \
	Require valid-user' slwebtest.conf


#CHANGE THE REQUIRED ALL ACCESS TO COMMENT
sed -i '/Required all granted/#Required all granted/' slwebtest.conf


#}




## MAIN 




###

CentOS7Packages
	CentOS7Start
		CentOS7Addons 
		CentOS7Setting
	#CentOS7SSL 
EnableApachePorts
