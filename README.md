# tpl
Threat Protection For Linux (CENTOS7 installer)
Project needs to speed up the process of running a Threat Protection for Linux or SecondLook (Raytheon)

Inicial Steps:
Verify Operating System
Check for several Packages
Call Cloud Packages from DropBox
Create Crypto keys
Ask for TPL License Keys
Create Targets
Create user for TPL
Setup Apache
Setup SSL for Apache
Create Certificates for Apache SSL
Ansible setup 
Playbooks
Splunk Setup
Splunk TCP services setup
Splunk Dashboard setup 

##########################################################################

setup_OS.sh

Script will setup full operating system. Under developement for Centos7

##########################################################################

setup_TPL.sh

Script will setup Threat Protection for Linux from Cloud

#########################################################################

setup_Apache.sh

Script will setup Apache. A modified version for TPL and add SSL to the
server including certificate and password

#########################################################################

setup_Client.sh

Script will setup the TPL agent package and Ansible Playbook. Take into considdration some form of preparation for massive deployment

#########################################################################

 

