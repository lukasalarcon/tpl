#!/bin/bash
#DEBUG
#set -x
# END DEBUG

#GLOBAL VARS
SPLUNKPN=
GLOXML=/usr/share/secondlook/splunk/dashboard.xml


#END GLOBAL VARS

function GetSplunk () {
#start GetSplunk

echo "Choose the best method for getting the Splunk Package:"
echo "1) From the disk"
echo "2) From the cloud"
echo "3) I will install by my own"
read num
 
case $num in

	1) 
		echo "Please, choose the path and package name where you custom splunk package is:"
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


		;;

	3)	echo "Thanks!"
		exit 1
		;; 
esac




#End GetSplunk
}




function Parameters () {
# check all parameters for splunk
splbin=$(find /opt -name splunk -type f -perm -u+x)

        if [ -f $splbin ]
                then
                        echo "Splunk Binary Detected"
                        $splbin start --accept-license
                else
                        echo "Splunk Binary Not detected"
                        $splbin enable boot-start

        fi

#firewall rule for Splunk Package

sudo firewall-cmd --zone=public --add-port=8000/tcp --permanent


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

function Parameters () {
# check all parameters for splunk
splbin=$(find /opt -name splunk -type f -perm -u+x)

	if [ -f $splbin ]
		then
			echo "Splunk Binary Detected"
			$splbin start --accept-license
			$splbin enable boot-start

		else
			echo "Splunk Binary Not detected"

	fi

#firewall rule

sudo firewall-cmd --zone=public --add-port=8000/tcp --permanent


#function Parameters ends
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
		mkdir /opt/splunk/etc/users/admin/search/local/data/ui/views/
		cp $GLOXML /opt/splunk/etc/users/admin/search/local/data/ui/views/
	else
		echo "DashBoad Not Found. You will need to add it manually"
		exit 1
	
fi





#Ends CreateInputs
}







#MAIN 
	GetSplunk
