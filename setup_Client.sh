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

#CHANGE THE DEFAULT VALUE FOR THE KEY
sed -i '/PUBLIC_KEY_GOES_HERE/'$_MYKEY'/' $_SECONDLOOK/agent_ssh_authorized_keys 

}

function CentOS7_AnsibleInstalation () {

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







#Ansible Playbook End Function
}


