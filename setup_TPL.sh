#!/bin/bash

# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.



##INSTALL###

#DEBUG SCRIPT
#set -x
#

#
##GLOBAL VARIABLES
VERSION=10
REPODROP=tmpp
PACKAGE_FILENAME=
HOMEUSER=/home/secondlook
CRONITI=CronOptions.sh
DWL=Get_Splunk.sh
CREATETGS=CreateTargets.sh
APACHESETUP=setup_Apache.sh
SCLOOK=secondlook
# END GLOBAL VARIABLES ####

function PackagesNeed () {
#VALIDATES IF PACKAGES EXISTS
# yum
# ssh-agent
# sed
_yum=$(rpm -qa | grep yum| head -1)
_sed=$(rpm -qa | grep sed)
_sshk=$()

if [[ "$_yum" == "yum"* ]]
	then 
		echo "Packager YUM 		[OK]"
	else
		echo "Please, you need to install yum packager."
		exit 1
fi







#END PACKAGES
}






function AddUser (){


#CREATE SECONDLOOK USER SYSTEM USER
sudo adduser --system --shell /bin/bash --create-home secondlook

}

function AddRepo () {

#SETUP EPEL REPO
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#VERIFY EXTRAS PACKAGES



}

function DownloadP () {
#Download Splunk Source from DropBox

sh ./$DWL



}






function InstallRPM (){ 

#INSTALL PACKAGE FOR CENTOS MANUALLY
#ASK FOR SOURCE CODE



	echo "For installing TPL, you will need the source:"
	echo "Please, ask to your Forcepoint Representative for Keys and Sources"
	echo "Please, enter the path for the TPL server (rpm) package:"
	read PACKAGE_FILENAME
	
	if [ -f $PACKAGE_FILENAME ]
		then
			sudo yum install $PACKAGE_FILENAME
		else
		  	echo "We cannot find the package."
			echo "Would you like to try again?(y/n)"
			read GetA	
				if [ "$GetA" == "Y" -o "$GetA" == "y" ] 
					then
						InstallRPM
					else
						echo "GoodBye.!"
						exit 1
				fi 
			
			
	fi

}

function GenerateKey (){

#ADD A KEY GEN WITH NO PROMTPS
#CREATE SSH DIR INTO SECONDLOOK HOME
mkdir $HOMEUSER/.ssh
ssh-keygen -f $HOMEUSER/.ssh/id_rsa -t rsa -N ''

#DECLARE VAR FOR ssh_config
SCONFIG=/usr/share/secondlook/ssh_config

if [ -f $SCONFIG ]
	then
		#COPY KEYGEN KEY
		cp $SCONFIG $HOMEUSER/.ssh/config
		#REPOSITION VALUES TO SECONDLOOK USER
		chown $SCLOOK:$SCLOOK $HOMEUSER/.ssh/id_rsa 
		chown $SCLOOK:$SCLOOK $HOMEUSER/.ssh/id_rsa.pub 

		
	else
		echo "I cannot find $SCONFIG. Please, retry"
		exit 1
fi

#END GENERATEKEY

}


function AddKeyProduct() {

ans="n"
while [ "$ans" == "N" -o "$ans" == "n" ]
do
	echo "Please, enter your TPL key:"

		read MYKEY

			echo "Your current key is: " $MYKEY

				echo "Is that correct?(Y/N)"

			read ans

			if [ "$ans" == "Y" -o "$ans" == "y" ]
			then
				echo "KEY accepted"
				echo $MYKEY > $HOMEUSER/.secondlook_license
				ans="y"
			fi

done


}

#DISABLE RATE LIMITING
function RateLimiting (){


#ADJUST RATE LIMITING
 echo "\$imjournalRatelimitInterval 0" | sudo tee /etc/rsyslog.d/ratelimit.conf

#RESTART R SYSLOG
 sudo systemctl restart rsyslog.service

#CHANGE JOURNALING RATE LIMINTING
#WARNING VALIDATE SED BEFORE
 sed -i -- 's/#RateLimitInterval=30s/RateLimitInterval=0/' /etc/systemd/journald.conf

#RESTART JOURNAL SERVICE

 sudo systemctl restart systemd-journald.service

#END FUNCTION RateLimiting
}

function Cronitizate(){
# USE CRON OPTIONS FOR PROGRAMING TASKS


sh ./$CRONITI



#END Cronitizate 
}


function CreateTargets () {
#CREATE SCAN TARGETS FOR SECONDLOOK
#POSIBLE REPO FOR ANSIBLE TOO

	./$CREATETGS

#END CreateTargets
}


function ApacheSetup () {
# CALL APACHE SETUP SCRIPT

./$APACHESETUP




} 

function WarnMessage (){
#Warn Message

echo "######################################################"
echo "THREAT PROTECTION FOR LINUX"
echo "PLEASE,DO NOT INSTALL OVER PRODUCTIVE APACHE SERVERS"
echo "INSTALL ONLY IN FRESH NEW SERVERS. Press any key to continue"
echo "######################################################"
read o
#warn
}



#
#MAIN BODY

 WarnMessage
	PackagesNeed
		AddRepo
			
				InstallRPM 
					AddUser
					GenerateKey
					AddKeyProduct
				RateLimiting
			CreateTargets 
		Cronitizate
	ApacheSetup
#END FILE


