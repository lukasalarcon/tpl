#!/bin/bash
#DEBUG
set -x
#END DEBUG

#GLOBAL VARS
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

#CHANGE THE DEFAULT VALUE FOR THE KEY
sed -i "s/PUBLIC_KEY_GOES_HERE/${_MYKEY}/g" $_SECONDLOOK/agent_ssh_authorized_keys 

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
cp $_SECONDLOOK/agent_ssh_authorized_keys $_MYPLAYBOOK


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
		grep --only-matching --perl-regex "($MY_EXPRESS)" $_MYPLAYBOOK/hosts
		
	;;
	2)
		echo "Please, enter a single value: ( 10.0.0.1 or tpl.local)"
		read MY_EXPRESS
		#SETUP REGEX FOR SEARCHING FOR
		SC=$(grep --only-matching --perl-regex "($MY_EXPRESS\$)" $_MYPLAYBOOK/hosts)
		#SETUP REMOTE USER FOR A SPECIFIC HOST
		echo "Please, enter the remote user for this host:"
		read RUSER
		SCM="$SC ansible_connection=ssh ansible_user=$RUSER"
		echo $SCM		
	;;

esac	





#end Special Accounts
}

function StartRemoteDeploy () {
#start Start RemoteDeploy allows start Ansible Process


sudo ansible-playbook -k -K -i hosts -e hosts=SL_targets $_MYPLAYBOOK/agent_deploy.yaml







# stop RemoteDeploy function
}





#MAIN

#	ValidateKey
#		AddKey
#			CentOS7_AnsibleInstalation
#			CreateAnsiblePlaybook
			SpecialAccounts
