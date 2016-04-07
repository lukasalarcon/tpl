#!/bin/bash
set -x

#GLOBAL VARS
VERSION=10
HFILE=/etc/secondlook/targets
CMD=`ping -q -c 1 ` 

#################################################
#CHECK IF TARGETS FILE EXISTS
	if [ -e $HFILE  ]
	 then
		echo "$HFILE exists. Continue..."
		
	 else
			echo "$HFILE does not exists. Please, install TPL"
			exit 1
	fi
#################################################
#CHECK IF FILE HAS SOME DATA

	if [[ -s $HFILE ]] ; then
		echo "$HFILE has data.Continue..."
	  else
		echo "$HFILE is empty.Please add targets before continue..."
		exit 1	
	fi ;








##################################################
#DO A LOOP IN THE TARGET FILE

	while read target
	do
    		echo "$target"

		#TEST PING CONNECTIVITY

		ping -q -c1 $target
		if [ "$?" -eq 0 ];
		 then
		    echo "$target reacheable."
		    ssh-keyscan -H $target >> /root/.ssh/known_hosts 			
		 else
		    echo "$target not reacheable."
		fi
 	

	done < $HFILE


  






