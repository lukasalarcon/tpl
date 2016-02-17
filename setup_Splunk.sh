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
				
			else
		fi
		;;

	2)	echo "Calling cloud assistance for Splunk Package"


		;;

	3)	echo "Thanks!"
		exit 1
		;; 





#End GetSplunk
}

function InstallSplunk () {

echo "Please, choose the following options"
echo "1) Install in a specific folder"
echo "2) Install in the default folder"
read myop

case $myop in 

	1) 
		echo "Please, enter the folder where you want to install:"
		read myfolder
	   	echo "You have choose the following folder: $myfolder. Is this c		orrect"
		if [ 
		
	;;
		
				


su chmod 744 $SPLUNKPN

su rpm -i $SPLUNKPN







}

