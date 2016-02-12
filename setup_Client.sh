#!/bin/bash
#DEBUG
set -x
#END DEBUG

#GLOBAL VARS
_SECONDLOOK=/usr/share/secondlook
_MYKEY=
HOMEUSER=/home/secondlook
TARGET_FILE=/etc/secondlook/targets
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
sed -i '/PUBLIC_KEY_GOES_HERE/'$_MYKEY'/' $_SECONDLOOK/agent_ssh_authorized_keys 

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

_MYPLAYBOOK=/etc/myplaybook

mkdir $_MYPLAYBOOK 


if [ -f $_SECONDLOOK/ansible/agent_deploy.yaml ]
	then
		echo "Found original Plabook"
	else
		echo "We cannot find Agent Playbook"
		exit 1
fi	 

#COPY YAML TO MYPLAYBOOK
cp $_SECONDLOOK/ansible/agent_deploy.yaml $_MYPLAYBOOK 

#COPY KEYS TO MYPLAYBOOK
cp $_SECONDLOOK/agent_ssh_authorized_keys $_MYPLAYBOOK

#CHECK FOR HOSTS FILE
if [ -f $_MYPLAYBOOK/hosts ]
then
	echo "File exists. Do you want to overwrite it?(y/n)"
		if [ "$myans" == "y" -o "$myans" == "Y"]
			then
			rm -f $_MYPLAYBOOK/hosts
			#WRITE A HEAD SL_TARGETS	
			echo "[SL_targets]" > $_MYPLAYBOOK/hosts
		else	
			echo "[SL_targets]" > $_MYPLAYBOOK/hosts
		fi
else
		echo "[SL_targets]" > $_MYPLAYBOOK/hosts
		#APPEND CONTENTS FROM TARGETS TO HOSTS TO PLAYBOOK	
		cat $TARGET_FILE  >> $_MYPLAYBOOK/hosts
fi





#Ansible Playbook End Function
}

#MAIN

	ValidateKey
		AddKey
			CentOS7_AnsibleInstalation
			CreateAnsiblePlaybook

