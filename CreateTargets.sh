#!/bin/bash

#GLOBAL PARAM
GLOBALTARGETS=""
TARGET_FILE=/etc/secondlook/targets
CIDR_PROGRAM=CIDRtoIP.sh
# END GLOBAL PARAMS


function Menu (){
#PRESENT MENU OPTIONS
echo "Please, enter Scan Targets"
echo "1) Enter Single IPv4 Address (10.0.0.1)"
echo "2) Enter CIRD v4 (10.0.0.0/16)"
echo "3) Enter File with CIDR Ranges"
echo "4) Print Ranges"
echo "5) Apply Ranges to Scan Targets"
echo "6) Exit Scan Targets"

#END MENU
}



ScanOp=0

while [ $ScanOp != 6 ]
do

  Menu
		
  read ScanOp

   case $ScanOp in

	1) 
	   echo "Enter a Single IP:"	
	   read SingleIP
	   GLOBALTARGETS="$GLOBALTARGETS\n$SingleIP"	
	;;
	2) 
	   echo "Enter a CIRD:"	
	   read CIRD
	   _CIRD=$(./$CIRD_PROGRAM $CIRD)
	   $GLOBALTARGETS=$GLOBALTARGETS$CIRD
	;;
	3) read _FILE		
           $GLOBALTARGETS=$(./$CIRD_PROGRAM $_FILE)
	;;

	4) 
	   echo -e "$GLOBALTARGETS"
					
	;;
	5)
	   #APPEND
		echo -e "$GLOBALTARGETS" >> targets.txt

        ;;

	6)
	  exit 1	
    esac

done

	
