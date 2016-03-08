#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.


#DEBUG
#set -x
#END DEBUG

#GLOBAL VARS
VERSION=
_SECONDLOOK=/usr/share/secondlook
_MYKEY=
HOMEUSER=/home/secondlook
TARGET_FILE=/etc/secondlook/targets
_MYPLAYBOOK=/etc/myplaybook

#

function ValidateKey () {
#Validates agent_ssh_authorized_keys

if [ -f $_SECONDLOOK/agent_ssh_authorized_keys ]
   then
	echo "Found agent_ssh_autorized_keys"
   else
	echo "We cannot find ssh_authorized keys"
	echo "Please, enter path to ssh_authorized_keys(/path/to/authorizedkeys):"
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

#CHANGE THE DEFAULT VALUE FOR THE KEY
#USING PARAMETER EXPANSION IN _MYKEY FOR ISSUES WITH BACKSLAHES
sed -i "/PUBLIC_KEY_GOES_HERE/s//${_MYKEY//\//\/}/" $_SECONDLOOK/agent_ssh_authorized_keys







}

function CentOS7_AnsibleInstalation () {
#START CENTOS ANSIBLE INSTALAION FUNCTION
_AnsInst=$(rpm -qa ansible)

#DETECT ANSIBLE PACKAGER
if [[ "$_AnsInst" == "ansible"* ]]
        then
                echo "Package ANSIBLE              [OK]"
        else
                echo "Proceed to Install ANSIBLE"
                sudo yum -y install ansible
fi





#CentOS7_Ansible End
}


function CreateAnsiblePlaybook () {
#Adjust parametes for Ansible Playbook


if [ -d $_MYPLAYBOOK ]
	then
		echo "Found myplaybook folder..."		
	else
		mkdir $_MYPLAYBOOK 
fi

if [ -f $_SECONDLOOK/ansible/agent_deploy.yaml ]
	then
		echo "Found original Playbook"
	else
		echo "We cannot find Agent Playbook"
		exit 1
fi	 

#COPY YAML TO MYPLAYBOOK
cp $_SECONDLOOK/ansible/agent_deploy.yaml $_MYPLAYBOOK 

#COPY KEYS TO MYPLAYBOOK
cp $_SECONDLOOK/agent_ssh_authorized_keys $_MYPLAYBOOK/ssh_authorized_keys


#CREATE A LIST FROM SL TARGETS
_TARGETS=$(cat $TARGET_FILE)



#CHECK FOR HOSTS FILE
if [ -f $_MYPLAYBOOK/hosts ]
then
	echo "File exists. Do you want to overwrite it?(y/n)"
		read myans
		if [ "$myans" == "y" -o "$myans" == "Y" ]
			then
			rm -f $_MYPLAYBOOK/hosts
			#WRITE A HEAD SL_TARGETS	
			echo "[SL_targets]" > $_MYPLAYBOOK/hosts
			echo -e "$_TARGETS" >> $_MYPLAYBOOK/hosts
		else	
			echo -e "$_TARGETS" >> $_MYPLAYBOOK/hosts
		fi
else
		echo "[SL_targets]" > $_MYPLAYBOOK/hosts
		#APPEND CONTENTS FROM TARGETS TO HOSTS TO PLAYBOOK	
		echo -e "$_TARGETS"  >> $_MYPLAYBOOK/hosts
fi





#Ansible Playbook End Function
}

function SpecialAccounts () {
#start Special Accounts
#use Special Accounts for particular accounts in hosts targets

while [ "$mysel" != 3 ]; do

echo "Please, choose the following options:"
echo "1) Batch Processing \
         Summary: It will allow a batch procesisn for a range by \
	  adding the same account to the regex you need"
echo "2) Single Processing \
	  Summary: It will allow single value to be modified"
echo "3) Exit"

read mysel

case $mysel in

	1) 
		echo "Please, enter the batch value: ( 10. or 10.0.0):"
		read MY_EXPRESS
		echo "Enter the remote user:"
		read RUSER
		#ASSIGN THE USER TO VARIABLE
		SCMO=" ansible_connection=ssh ansible_ssh_user=$RUSER"
		SCR=$(grep --only-matching --perl-regex "($MY_EXPRESS)" $_MYPLAYBOOK/hosts)
		echo "We have match:"
		echo $SCR | more
		echo "Is this matching OK?(y/n)"
		read yesno
		if [ "$yesno" == "y" -o "$yesno" == "Y" ]
			then
				echo "Modifying values"
				#START MODIFICATION
				#AVOID TO MODIFY VALUES INJECTED...ISSUE

				#/s/$/${SCMO}  replace keeping the data found	
				sed -i "/^${MY_EXPRESS}/s/$/${SCMO}/" $_MYPLAYBOOK/hosts

			else
				echo "Skipping modification. Try again"
		fi
		
	;;
	2)
		echo "Please, enter a single value: ( 10.0.0.1 or tpl.local)"
		read MY_EXPRESS
		#SETUP REGEX FOR SEARCHING FOR
		SC=$(grep --only-matching --perl-regex "($MY_EXPRESS\$)" $_MYPLAYBOOK/hosts)
		echo $SC
		#SETUP REMOTE USER FOR A SPECIFIC HOST
		echo "Please, enter the remote user for this host:"
		read RUSER
		#ADD VALUES TO HOSTS NOT PLAYBOOK!
		SCM="ansible_connection=ssh ansible_ssh_user=$RUSER"
		
		echo $SCM		
		#REPLACE THE FIRST OCCURRENCE
		sed -i "0,/${SC}/s//${SC} ${SCM}/" $_MYPLAYBOOK/hosts


	;;
	3) 	mysel=3
		;;	

esac	
#END LOOP
done




#end Special Accounts
}

function StartRemoteDeploy () {
#start Start RemoteDeploy allows start Ansible Process

echo "Would you like to start the remote deployment tasks?"
read yesno

if [ "$yesno" == "y" -o "$yesno" == "Y" ]  
	then
		sudo ansible-playbook -k -K -i $_MYPLAYBOOK/hosts -e hosts=SL_targets $_MYPLAYBOOK/agent_deploy.yaml
	else
		echo "Deploy not needed"
fi

#LEAVES A COPY OF SCRIPT FOR RUNNING IN CASE NEEDED
echo  echo "sudo ansible-playbook -k -K -i $_MYPLAYBOOK/hosts -e hosts=SL_targets $_MYPLAYBOOK/agent_deploy.yaml" >>  $_MYPLAYBOOK/start_deploy.sh




# stop RemoteDeploy function
}

function PrepareAgent () {
#start PrepareAgent

#check if package exists

echo "Please, enter the path and name of secondlook agent:(/path/to/second-agent.tar.gz)"
read SAGENT


if [ -f $SAGENT	 ]
	then
		echo "File Agent Found	[OK]"
		sudo tar -xzf $SAGENT -C $_MYPLAYBOOK/
	

	else
			echo "We cannot find the package."
                        echo "Would you like to try again?(y/n)"
                        read GetA
                                if [ "$GetA" == "Y" -o "$GetA" == "y" ]
                                        then
                                                PrepareAgent
                                        else
                                                        echo "GoodBye.!"
							exit 1
                                fi


fi


#PrepareAgent function ends here
}



#MAIN

	ValidateKey
		AddKey
			CentOS7_AnsibleInstalation
		CreateAnsiblePlaybook
		PrepareAgent
	SpecialAccounts
StartRemoteDeploy

#END MAIN
