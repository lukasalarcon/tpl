#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.


#DEBUG
#set -x
# END DEBUG

#GLOBAL VARS
VERSION=10
SPLUNKPN=
GLOXML=/usr/share/secondlook/splunk/dashboard.xml
SPLUNKCLOUD=Get_Splunk.sh

#END GLOBAL VARS

function GetSplunk () {
#start GetSplunk

echo "Choose the best method for getting the Splunk Package:"
echo "1) From the disk"
echo "2) From the cloud "
echo "3) I will install by my own"
read num
 
case $num in

	1) 
		echo "Please, choose the path and package name (RPM package) where you custom splunk package is:"
		read splunkFol
		if [ -f $splunkFol ]
			then
				echo "Package Found"							
			SPLUNKPN=$splunkFol
			#CALL THE INSTALLER
			InstallSplunk

			else

				echo "Package not found. Exiting"
				exit 1
		fi
		;;

	2)	echo "Calling cloud assistance for Splunk Package"
			
			./$SPLUNKCLOUD
			SPLUNKPN=$(find tmpp/ -name "splunk*.rpm")
			#CALL THE INSTALLER
			InstallSplunk
		;;

	3)	echo "Thanks!"
		exit 1
		;; 
esac




#End GetSplunk
}




function Parameters () {
# check all parameters for splunk

if [ "$myfolder" != ""	]
	then
		splbin=$(find $myfolder -name splunk -type f -perm -u+x)
	else
		splbin=$(find /opt -name splunk -type f -perm -u+x)

fi

        if [ -f $splbin ]
                then
                        echo "Splunk Binary Detected"
                        $splbin start --accept-license
			$splbin enable boot-start
			#firewall rule for Splunk Package
			sudo firewall-cmd --zone=public --add-port=8000/tcp --permanent

                else
                        echo "Splunk Binary Not detected"

        fi




#function Parameters ends
}



function JoinFunctions () {
#UNIFY functions only

                Parameters
			 CreateInputs



#end JoinFunctions
}


function InstallSplunk () {


myop=0

while [	"$myop" != 3 ]; do

echo "Please, choose the following options"
echo "1) Install in a specific folder"
echo "2) Install in the default folder"
echo "3) Exit Install Process"
read myop

	case "$myop" in 

		1) 
			echo "Please, enter the folder where you want to install:"
			read myfolder
	   		echo "You have choose the following folder: $myfolder. Is this correct(y/n)?"
			read ans
			if [  "$ans" == "y" -o "$ans" == "Y" ]
				then
					echo "New Folder: $myfolder "
					sudo chmod 744 $SPLUNKPN
					sudo rpm -i --prefix=$myfolder $SPLUNKPN
					JoinFunctions
					myop=3
			fi
		
			;;
		2)	 		echo "Default Folder"
                                	sudo chmod 744 $SPLUNKPN
                                	rpm -i $SPLUNKPN
					JoinFunctions
					myop=3
			;;
		3)	echo "Exiting..."
			exit 1
			;;


		esac	
done

#installsplunk ends

}


function CreateInputs () {
#CREATE INPUTS

#CREATE A UDP PORT WITH DEFAULT PASSWORD

  $splbin add udp 514 -sourcetype syslog -auth admin:changeme

#PASSWORD

if [ -f $GLOXML ]
	then
		echo "DashBoard Found"
		#COPY DASHBOARD TO A LOCAL SPLUNK REPO
		#CHECK IF USER HAS CHOOSEN A DIFFERENT FOLDER
		if [ ! -z "$myfolder"  ]
			then
				mkdir -p $myfolder/etc/users/admin/search/local/data/ui/views/
				cp $GLOXML $myfolder/etc/users/admin/search/local/data/ui/views/

			else
				mkdir -p /opt/splunk/etc/users/admin/search/local/data/ui/views/
				cp $GLOXML /opt/splunk/etc/users/admin/search/local/data/ui/views/


		fi
	else
		echo "DashBoad Not Found. You will need to add it manually"
		exit 1
	
fi


#RESTART SERVICES FOR GET THE DASHBOARD READY
$splbin stop
$splbin start 




#Ends CreateInputs
}


function ModifyLogLinux () {
#Modify Linux Forward to Send info to Splunk
#
IPSPLUNK=$(hostname -I)



	echo "we have detected the following ip address: $IPSPLUNK"
	echo "Is this IP, the Splunk IP?(y/n)"
	read yesno
	if [ "$yesno" == "y" -o "$yesno" == "Y" ]
		then
			echo "local2.*	@$IPSPLUNK" >> /etc/rsyslog.conf
		else
			echo "Please, enter the SPLUNK IP"
			read IPSPLUNK
			echo "local2.*  @$IPSPLUNK" >> /etc/rsyslog.conf

	fi

	#RESTART RSYSLOG FOR APPLYING CHANGES
	echo "RESTART RSYSLOG FOR APPLYING CHANGES"
	systemctl restart rsyslog
	



}





#MAIN 
	GetSplunk
		ModifyLogLinux
