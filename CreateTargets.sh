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
echo "4) Show Ranges"
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
	   #ENTER ONE IP 
	   echo "Enter a Single IP:"	
	   read SingleIP
	   GLOBALTARGETS="$GLOBALTARGETS\n$SingleIP"	
	;;
	2) 
	   #ENTER A NETWORK RANGE 
	   echo "Enter a CIRD:"	
	   read CIRD
	   _CIRD=$(./$CIDR_PROGRAM $CIRD)
	   #./$CIDR_PROGRAM $CIRD 
	   GLOBALTARGETS="$GLOBALTARGETS$_CIRD\n"
	;;
	3) 
 	   echo "Enter the path to file:"	
	   read _FILE
	   if [ -f $_FILE ]
           then			
            $GLOBALTARGETS=$(./$CIDR_PROGRAM -i $_FILE)
	   else
	    echo "File $_FILE does not exists!"
           fi		
	;;

	4) 
	   echo -e "$GLOBALTARGETS"
					
	;;
	5)
	   #APPEND
	   echo "Would you like to create a new file?(y/n):"
		read ANS
		if [ "$ANS" == "y" -o "$ANS" == "Y"  ]
                   then
		     echo "Creating a new Target File..."
		     rm -f $TARGET_FILE	
		     echo -e "$GLOBALTARGETS" > $TARGET_FILE
		   else
		     echo "Append content to existing target file..."	
		     echo -e "$GLOBALTARGETS" >> $TARGET_FILE
		fi
        ;;

	6)
	  exit 1	
    esac

done

	
