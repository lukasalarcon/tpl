##INSTALL###
#
##GLOBAL VARIABLES
REPODROP=tmpp
PACKAGE_FILENAME=secondlook-5.0.0_r56689-EL7.x86_64.rpm
# END GLOBAL VARIABLES ####





#CREATE SECONDLOOK USER SYSTEM USER
sudo adduser --system --shell /bin/bash --create-home secondlook

#SETUP EPEL REPO
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#VERIFY EXTRAS PACKAGES

#INSTALL PACKAGE
sudo yum install $REPODROP/$PACKAGE_FILENAME

#CHANGE TO SECONDLOOK
sudo su - secondlook

cd /home/secondlook

#ADD A KEY GEN WITH NO PROMTPS
#CREATE SSH DIR INTO SECONDLOOK HOME
mkdir .ssh
sh-keygen -f .ssh/id_rsa -t rsa -N ''

#COPY KEYGEN KEY
cp /usr/share/secondlook/ssh_config .ssh/config

echo "Please, enter your TPL key:"

read MYKEY

echo "Your current key is: " $MYKEY

echo "Is that correct?(Y/N)"

read ANS

if [ "$ANS" == "Y" ]
then
   echo "KEY accepted"
fi

echo $MYKEY > /home/secondlook/.secondlook_license

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






#END Cronitizate 
}

#END FILE


