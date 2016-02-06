#!/bin/bash

#GLOBAL PARAM
GLOBALTARGETS=
C_PROGRAM=



function Menu (){
#PRESENT MENU OPTIONS
echo "Please, enter Scan Targets"
echo "1) Enter Single IPv4 Address (10.0.0.1)"
echo "2) Enter CIRD v4 (10.0.0.0/16)"
echo "3) Enter File with CIDR Ranges"
echo "4) Exit Scan Targets"

#END MENU
}



ScanOp=0

while [ $ScanOp != 4 ]
do

  Menu
		
  read ScanOp

   case $ScanOp in

	1) read SingleIp
	   $GLOBALTARGETS=$SingleIP	

	2) read CD
	   $CD=$(./$C_PROGRAM $CD)
	   $GLOBALTARGETS=$GLOBALTARGETS+$CD

	3) read _FILE		
           $GLOBALTARGETS=$(./$C_PROGRAM $_FILE)			


end


	
