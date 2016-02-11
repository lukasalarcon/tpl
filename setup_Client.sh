#!/bin/bash
#DEBUG
#set -x
#END DEBUG

#GLOBAL VARS
_SECONDLOOK=/usr/share/secondlook
_MYKEY=
HOMEUSER=/home/secondlook
#

function ValidateKey () {
#Validates agent_ssh_authorized_keys

if [ -b $_SECONDLOOK/agent_ssh_authorized_keys ]
   then
	echo "Found agent_ssh_autorized_keys"
   else
	echo "We cannot find ssh_authorized keys"
	echo "Please, enter path to ssh_authorized_keys(/path/to/authorizedkeys"
        read PathKey
	#EXIT IF CANNOT FIND
	 if [ -f $Pathkey/agent_ssh_authorized_keys  ]
		then
		   echo "Found keys"
		   _SECONDLOOK=$PathKey
		else
		   echo "Sorry, we cannot find keys!"
			exit 1		
	fi
fi

# END ValidateKey
}

function AddKey () {
#COPY KEY TO 
_MYKEY=$(more $HOMEUSER/.ssh/id_rsa.pub)

sed -i '/PUBLIC_KEY_GOES_HERE/'$_MYKEY'/' $_SECONDLOOK/agent_ssh_authorized_keys 

}
