#!/bin/bash

#SCRIPT ONLY FOR DEVELOPER 




rpm -e mariadb-server
rpm -e mariadb





rm -rf /var/lib/mysql
rm -rf /etc/mysql*
rm -rf /etc/my.cfg


rpm -i mariadb-5.5.44-2.el7.centos.x86_64.rpm
rpm -i mariadb-server-5.5.44-2.el7.centos.x86_64.rpm


