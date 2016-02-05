#!/bin/bash

#ADD CRONTAB ENTRIES FOR SECONDLOOK SCAN
echo "Choose from the following scanning options:"
echo "1)Each 5 minutes"
echo "2)Each 15 minutes"
echo "3)Each 30 minutes"
echo "4)Each 1 hour"
echo "5)Once a day"
echo "6)Random"
echo "Please, chooose what you prefer:"

read cropOp

case $cronOp in

	1) 
	 #EACH 5
	 
	 crontab -l > file; echo '5 * * * * /usr/bin/secondlook-scan' >> file; sudo crontab -u secondlook file
	;;

	2)
	 #EACH 15
	crontab -l > file; echo '15 * * * * /usr/bin/secondlook-scan' >> file; sudo crontab -u secondlook file

	;;
	
	3)
	#EACH 30 minutes
	crontab -l > file; echo '30 * * * * /usr/bin/secondlook-scan' >> file; sudo crontab -u secondlook file

	;;
	
	4)
	
	crontab -l > file; echo '5 * * * * /usr/bin/secondlook-scan' >> file; sudo crontab -u secondlook file

	;;
	
esac