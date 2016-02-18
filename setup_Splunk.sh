#!/bin/bash
#DEBUG

# END DEBUG

#GLOBAL VARS
SPLUNKPN=


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
		echo "Please, choose the folder where you custom splunk package is:"
		read splunkFol
		if [ -f $splunkFol ]
			then
				echo "Package Found"							
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

function InstallSplunk () {

echo "Please, choose the following options"
echo "1) Install in a specific folder"
echo "2) Install in the default folder"
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
			else
				echo "Default Folder"
				sudo chmod 744 $SPLUNKPN
				rpm -i $SPLUNKPN
		fi
		
	;;
esac	
#installsplunk ends
}

function Parameters () {
# check all parameters for splunk
splbin=$(find / -name splunk -type f -perm -u+x)

	if [ -f $splbin ]
		then
			echo "Splunk Binary Detected"
			./$splbin start --accept-license
		else
			echo "Splunk Binary Not detected"
			./$splbin enable boot-start

	fi

#firewall rule

sudo firewall-cmd --zone=public --add-port=8000/tcp --permanent


#function Parameters ends
}



#MAIN 
	GetSplunk
		InstallSplunk
			Parameters

