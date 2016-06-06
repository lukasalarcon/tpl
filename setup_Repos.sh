#!/bin/bash
#CREATE A EASY WAY TO CALL REPOS FROM OTHER LINUX OPERATING SYSTEMS
######GLOBAL VARS
se_look_ph=/etc/secondlook/secondlook-phgen
se_look=/etc/secondlook
VERSION=12
################

function PackagesNeed () {
# VALIDATES IF PACKAGES EXISTS
# yum
# fuse
# epel

echo "Preparing Operating System for Remote Repositories...wait a minute..."
 
_yum=$(rpm -qa | grep yum| head -1)
_sshfs=$(rpm -qa | grep fuse-sshfs)
_ep=$(rpm -qa epel*)
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
		if [ $? -ne 0 ]; then
                             echo "error with $1" >&2
                             echo "Please, execute again"
                             exit 1
                fi	




fi 

#INSTALL sshfs after EPEL

if [[ "$_sshfs" == "fuse-sshfs"* ]]
        then
                echo "Packager SSHFS             [OK]"
        else
                echo "Please, you need to install sshfs packager."
                sudo yum install sshfs
                #ERROR CHECKING
		if [ $? -ne 0 ]; then
                             echo "error with $1" >&2
                             echo "Please, execute again"
                             exit 1
                fi	



fi

#END PACKAGES
}    


function CopyPhFromTPLServer(){
#start
#start a copy of binary if not detected on this server

	echo "Do you want to copy the php binary?(y/n):"
	read yesno
	
	if [ $yesno == "Y" ] || [ $yesno == "y" ]
		then

	echo "Please, enter the TPL Server TPL Address:"
	read TPLs
	#echo "Please, enter the local folder where to download file:"
	#read DownloadF
	echo "Please, enter the user for the TPL Server for SSH:"
	read Usertpl

	#SUMMARY
		echo "The Following are the summary"
		echo "Threat Protection for Linux IP:" $TPLs
		echo "Local Folder to copy:" $se_look 
		echo "User for the SSH connection:" $Usertpl
		#Start the remote copy
		scp $Usertpl@$TPLs:/usr/bin/secondlook-phgen $se_look
		#ERROR CHECKING
		if [ $? -ne 0 ]; then
                             echo "error with $1" >&2
                             echo "Please, execute script again..."
                             exit 1
                fi		 
	
	fi


#End Function
}



function CreateRepo(){
#start


	echo "Please, enter the local folder where to mount remote repo:"
	read localrepo
	echo "Please, enter the remote server ip address:"
	read remoteserver
	echo "Please, enter the remote user for connecting:"
	read userremo



	if [  -d $localrepo/$remoteserver ]
	then 
	   #EP LOCAL REPO
           localrepori=$localrepo
	   mkdir $localrepo/$remoteserver
	   sshfs $userremo@$remoteserver:/ $localrepo/$remoteserver	
	else
		echo "We cannot mount on folder it does not exist"
		echo "Do you want to create it?(y/n)"
		read yesno
		
		if [ $yesno == "Y" ] || [ $yesno == "y" ]; then	
		mkdir $localrepo/$remoteserver
		 if [ $? -ne 0 ]; then
        	  	echo "error with $1" >&2
			echo "Please, execute again"
			exit 1	
    		 fi
		#MOUNT THE UNIT
		sshfs $userremo@$remoteserver:/ $localrepo/$remoteserver
		if [ $? -ne 0 ]; then
                        echo "error with $1" >&2
                        echo "Please, execute again"
                        exit 1
                 fi
		
		

		fi 	
		
	fi


	#CHECK ERROR	




#ends create repo
}


function InsertHashes(){

	#MAKE A TEMPORAL FOLDER FOR HASHING	
	if [ ! -d tmpprep ]; then
		mkdir tmpprep
	else
		rm -fR tmpprep
		mkdir tmpprep
	fi


	#VALIDATE FILE TO EXIST

	if [ -z "$se_look_ph" ]
	 then
		echo "We cannot find secondlook-phgen file. Execute Again..."
		UmountDrives
		exit 1	
	fi 


	while :
		do

			echo "Please, choose the Executables/ELF/Scripts:"
			#ACCEPT SOME SPECIFIC FOLDER				
			echo "Do you want search in a specific folder inside the repo?(y/n):"	
			read yesno

			if [ $yesno == "y" ] || [ $yesno == "Y" ]
				 then

			
				echo "Examples: /mnt/ or /etc/network"
				echo "Enter the folder:"
					#READ FOLDER INFO	
					read myfolder

					#ONE VAR FOR LOCAL REPO AND FOLDER	
					localrepo=$localrepo/$remoteserver$myfolder	
			fi		
					echo "Working with $localrepo"
					echo "Choose the options:"
					echo "1) ELF Searcher"
					echo "2) Manual Input ( *.sh or mybash.sh)"

					#READ FILES							
					read myop 

					case "$myop" in
						1)
							echo "Searching ELF...wait"
							searcher=$(find $localrepo -exec file {} \;| grep -i elf| awk -F: '{print $1;next}')
							;;	
						2) 	
							echo "Please, enter your manual entry:(*.sh)"
							read inputs
							echo "Searching Scripts...wait"
							searcher=$(find $localrepo -name "$inputs")
							;;
					esac

			
			
			if [ -z "$searcher" ]
			 then
   	 			echo "Possibly empty string"
				echo "Try again..."
			else

				#INGEST INFO
				echo "Ingesting: $searcher"

					echo "Do you agree with the found files to be ingested?(y/n):"
					read yesno
					if [ $yesno == "y" ] || [ $yesno == "Y" ]; then
 						#CALL phgen for ingesting	
							#INPUT CREATION
							echo "$searcher" >> input.txt
							$se_look/./secondlook-phgen -d -t tmpprep -i input.txt -o output.sql		
								#ADD INFO TO DATABASE
	
								cat output.sql | mysql -usecondlook_rw pagehash
							#REMOVING INPUT FILE
							rm -fR input.txt
							#REMOVING THE OUTPUT FILE
							rm -fR output.sql

					fi
			
			fi
			
			echo "Do you want to continue adding files?(y/n)"
			read yesno
			
			if [ $yesno == "N" ] || [ $yesno == "n" ]; then
				break
			fi

		done

#REMOVE THE TEMP FOLDER
rm -fR tmpprep 	 	


}

function UmountDrives(){


#Unmount the drives with lazy option kernerl 2.4 as minimum

umount -l $localrepori 




}




#MAIN


			PackagesNeed
				CopyPhFromTPLServer
					CreateRepo
				InsertHashes
			UmountDrives
