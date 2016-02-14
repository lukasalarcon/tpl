##INSTALL###

#DEBUG SCRIPT
set -x
#

#
##GLOBAL VARIABLES
REPODROP=tmpp
PACKAGE_FILENAME=secondlook-5.0.0_r56689-EL7.x86_64.rpm
HOMEUSER=/home/secondlook
CRONITI=CronOptions.sh
DWL=Get_TPL.sh
CREATETGS=CreateTargets.sh
APACHESETUP=setup_Apache.sh
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
#Download Sources from DropBox

sh ./$DWL



}






function InstallRPM (){ 

#INSTALL PACKAGE FOR CENTOS 
sudo yum install $REPODROP/$PACKAGE_FILENAME

}

function GenerateKey (){

#ADD A KEY GEN WITH NO PROMTPS
#CREATE SSH DIR INTO SECONDLOOK HOME
mkdir $HOMEUSER/.ssh
ssh-keygen -f $HOMEUSER/.ssh/id_rsa -t rsa -N ''

#COPY KEYGEN KEY
cp /usr/share/secondlook/ssh_config $HOMEUSER/.ssh/config


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





#
#MAIN BODY


	PackagesNeed
		#AddRepo
		#	DownloadP
			#	InstallRPM 
					AddUser
					GenerateKey
					AddKeyProduct
				RateLimiting
			CreateTargets 
		Cronitizate
	ApacheSetup
#END FILE


