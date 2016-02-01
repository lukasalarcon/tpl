#!/bin/bash
set -x

#create a secondlook user

#sudo adduser --system --shell /bin/bash --create-home secondlook


#install the epel repositories

#sudo yum install https://dl.fedoraproject.org/pub/epel/epel.release.latest.7.noarch.rpm


#REV=$(sh ./OP_Detection.sh | head -n 1)
REV=${args[0]}

if [[  "$REV" == *"6."* ]]
	then
		#FOLLOW 6.x INSTRUCTIONS
		echo "6.x"
		else
			#FOLLOW 7.x INSTRUCTIONS
			echo "7.x"


fi


