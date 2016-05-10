#!/bin/bash
#CREATE A EASY WAY TO CALL REPOS FROM OTHER LINUX OPERATING SYSTEMS

#CALL EPEL REPOS



#





#


function PackagesNeed () {
# VALIDATES IF PACKAGES EXISTS
# yum
# fuse
# epel
 
_yum=$(rpm -qa | grep yum| head -1)
_sshfs=$(rpm -qa | grep sshfs)
-ep=$(rpm -qa epel*)
if [[ "$_yum" == "yum"* ]]
        then
                echo "Packager YUM              [OK]"
        else
                echo "Please, you need to install yum packager."
                exit 1
fi


if [[ "$_ep" == "epel"* ]]
        then
                echo "Packager EPEL             [OK]"
        else
                echo "Installing epel packager."
		sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  
                #ERROR CHECKING




fi 

#INSTALL sshfs after EPEL

if [[ "$_sshfs" == "sshfs"* ]]
        then
                echo "Packager SSHFS             [OK]"
        else
                echo "Please, you need to install sshfs packager."
                sudo yum install sshfs
                #ERROR CHECKING




fi

#END PACKAGES
}    


function CopyPhFromTPLServer(){
#start
#start a copy of binary if not detected on this server

	echo "Please, enter the TPL Server TPL Address:"
	read TPLs
	echo "Please, enter the local folder where to download file:"
	read DownloadF
	echo "Please, enter the user for the TPL Server for SSH:"
	read Usertpl

	#Start the remote copy
	scp $Usertpl@$TPLs:/usr/bin/secondlook-phgen $DownloadF



#End Function
}



function CreateRepo{
#start

	echo "Please, enter the local folder where to mount remote repo:"
	read localrepo
	echo "Please, enter the remote server ip address:"
	read remoteserver
	echo "Please, enter the remote user for connecting:"
	read userremo

	sshfs $userremo@$remoteserver:/ $localrepo	
	
	#CHECK ERROR	




#ends create repo
}
