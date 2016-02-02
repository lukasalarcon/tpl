##INSTALL###


#CREATE SECONDLOOK USER SYSTEM USER
sudo adduser --system --shell /bin/bash --create-home secondlook

#SETUP EPEL REPO
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#VERIFY EXTRAS PACKAGES

#INSTALL PACKAGE


#CHANGE TO SECONDLOOK
sudo su - secondlook

cd /home/secondlook

#ADD A KEY GEN WITH NO PROMTPS
#CREATE SSH DIR INTO SECONDLOOK HOME
mkdir .ssh
sh-keygen -f .ssh/id_rsa -t rsa -N ''

cp /usr/share/secondlook/ssh_config .ssh/config


