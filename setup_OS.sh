#!/bin/bash
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.


#set -x

SHOME="/root"

#INSTALL TLP PROCESS

installTPL ()
{

echo "INSTALL TPL"

echo "Please, choose your options for this Threat Protection for Linux:"
        echo "1) Install Install StandAlone and Ansible"
        echo "2) Install Install StandAlone, Ansible and Repo"
        read wcgmode
        if [ "$wcgmode" == "1" ]
         then
           echo "Installing...TPL and Ansible"
	 #CALL INSTALLER
        else
           echo "installing...TPL, Ansible & Repo"
	 #CALL INSTALLER
        fi
}







change_eth0 ()
{


echo -n "Enter IP address for eth0 [`ifconfig eth0 | egrep "inet addr" | grep Bcast | awk '{ print $2 }' | awk -F ":" '{ print $2 }'`]: "
        read ip
        if [ "$ip" == "" ]
        then
                ip=`ifconfig eth0 | egrep "inet addr" | grep Bcast | awk '{ print $2 }' | awk -F ":" '{ print $2 }'`
        fi

        echo -n "Enter netmask [`ifconfig eth0 | egrep "inet addr" | grep Bcast | awk '{ print $4 }' | awk -F ":" '{ print $2 }'`]: "
        read netmask
        if [ "$netmask" == "" ]
        then
                netmask=`ifconfig eth0 | egrep "inet addr" | grep Bcast | awk '{ print $4 }' | awk -F ":" '{ print $2 }'`
        fi
	
}

change_ethX ()
{

echo -n "Enter IP address for eth1 [`ifconfig eth1 | egrep "inet addr" | grep Bcast | awk '{ print $2 }' | awk -F ":" '{ print $2 }'`]: "
        read ipeth1
        if [ "$ipeth1" == "" ]
        then
                ipeth1=`ifconfig eth1 | egrep "inet addr" | grep Bcast | awk '{ print $2 }' | awk -F ":" '{ print $2 }'`
        fi

        echo -n "Enter netmask [`ifconfig eth1 | egrep "inet addr" | grep Bcast | awk '{ print $4 }' | awk -F ":" '{ print $2 }'`]: "
        read netmask1
        if [ "$netmask1" == "" ]
        then
                netmask1=`ifconfig eth1 | egrep "inet addr" | grep Bcast | awk '{ print $4 }' | awk -F ":" '{ print $2 }'`
        fi
}

enter_gateway ()
{


  echo -n "Enter default gateway [`netstat -rn | awk '{ print $2 }' | tac | head -1`]: "
        read gateway
        if [ "$gateway" == "" ]
        then
                gateway=`netstat -rn | awk '{ print $2 }' | tac | head -1`
        fi
}


enter_routes ()
{
    echo -e "Would you like to add aditional routes (y/n)?"
    read ynroutes
    if [ "$ynroutes" == "y" ] || [ "$ynroutes" == "Y" ]; then
        cd $SHOME/scripts
    	./addroutes.sh
	else
        exit 1
    fi		

}



acceptInput ()
{

        echo -n "Enter Domain name [`cat /etc/resolv.conf | grep "search " | awk '{ print $2 }'`]: "
        read domainname
        if [ "$domainname" == "" ]
        then
                domainname=`cat /etc/resolv.conf | grep "search " | awk '{ print $2 }'`
        fi

        echo -n "Enter DNS IP [`cat /etc/resolv.conf | grep -m 1 "nameserver " | awk '{ print $2 }'`]: "
        read domainip
        if [ "$domainip" == "" ]
        then
                domainip=`cat /etc/resolv.conf | grep -m 1 "nameserver "| awk '{ print $2 }'`
        fi

        echo -n "Enter the Fully qualified Name (FQDN) [`cat /etc/hosts | grep 127.0.0.1 | awk '{ print $2 }'`]: "
        read hostname
        if [ "$hostname" == "" ]
        then
                hostname=`cat /etc/hosts | grep 127.0.0.1 | awk '{ print $2 }'`
        fi

        echo -n "Enter the hostname ALIAS [`cat /etc/hosts | grep 127.0.0.1 | awk '{ print $3 }'`]: "
        read hostnameAlias
        if [ "$hostnameAlias" == "" ]
        then
                hostnameAlias=`cat /etc/hosts | grep 127.0.0.1 | awk '{ print $3 }'`
        fi

YN="y"
i=0
unset ntpip
while [ "$YN" == "y" ] || [ "$YN" == "Y" ]
do

       echo -n "Enter the NTP server [`cat /etc/ntp.conf | grep -m 1 "server " | awk '{ print $2 }'`]: "
	read myntp
	if [ "$myntp" == "" ]
        then
                myntp=`cat /etc/ntp.conf | grep -m 1 "server " | awk '{ print $2 }'`
        fi
 	ntpip+=($myntp)


	echo "Would you like to add another NTP server?: (y/n)"
	read YN

done



################SUMMARY###################################

        echo ""
        echo "You have entered following details"
        echo IP ETH0 = $ip
        echo NETMASK ETH0 = $netmask
        echo GATEWAY ETH0 = $gateway
        if [ "$ipeth1" != "" ] 
        then
		echo IP ETH1 = $ipeth1
		echo NETMASK ETH1 = $netmask1
	else
                rm -f /etc/sysconfig/network-scripts/ifcfg-eth1
	fi
        echo DOMAINNAME = $domainname
        echo DOMAINIP = $domainip
        echo HOSTNAME = $hostname
        echo HOSTNAME ALIAS = $hostnameAlias
	echo NTP SERVER =  
	printf '%s\n' "${ntpip[@]}"
        echo  ""
        echo -n "Is that right? [Y/N] : "
        read ans
}

setIpHostname ()
{
        # set hosts file
	rm -f /etc/hosts
        echo "$ip  $hostname $hostnameAlias " > /etc/hosts
	echo "127.0.0.1	localhost localhost.localdomain" >> /etc/hosts
	hostname $hostname

        # set resolve.conf
        echo "search $domainname" > /etc/resolv.conf
        echo "nameserver $domainip" >> /etc/resolv.conf

        # set network file
        echo "NETWORKING=yes" > /etc/sysconfig/network
        echo "NETWORKING_IPV6=yes" >> /etc/sysconfig/network
        echo "HOSTNAME=$hostname" >> /etc/sysconfig/network
        echo "DOMAINNAME=$domainname" >> /etc/sysconfig/network

        # set ifcfg-eth0
        echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "HOSTNAME=$hostname" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "IPADDR=$ip" >>  /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "USERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "IPV6INIT=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "PEERDNS=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0

	#set ntp server

	#RMOVE OLD LINE NTP FOR ADDING NEW ENTRIES
	sed '$d' < /etc/ntp.conf > /etc/ntp.conf.new ; mv -f /etc/ntp.conf.new /etc/ntp.conf

	for var in "${ntpip[@]}"
	do
  	  echo server "${var}" >> /etc/ntp.conf
	done
}
#NIC DETECTION 

NicDetect()
{
echo -e "--------------------------------------------------------------\n"

printf "Starting NIC Detection Module\n"

file="/etc/udev/rules.d/70-persistent-net.rules"

if [ -f "$file" ]
then
	echo "$file Detected." 


	printf "NIC Detection on progress..\n."
        printf "\n"

	echo "(70-persitent-net.rules) MAC Address Detection:"

	cat $file | grep -vE "^#" | awk -F"," '{print $4 $7}'

	echo ""

	echo "Before continuing, please check ESX MAC Address assigment according to MAC address detected..."
	echo "Press Any key to continue"
	echo ""

	read hold

	found="0"
	for i in {0..3}
		do
    		LinK="$(ip a | grep -E  ": eth$i:.*state "| awk -F" " '{print $9}')"
        	if [ "$LinK" == "UP" ] || [ "$LinK" == "UNKNOWN" ]
         		then
             			interface="$(ip a | grep -E ": eth$i:.*state "| awk -F" " '{print $2}')"
             			printf "INTERFACE: $interface\n"
				printf "INTERFAFE MAC:"
				ip link show eth$i | awk '/ether/ {print $2}'

             			found="1"
        	fi

	done
        if [ "$found" == "1" ]
          then
             printf "At least one NIC detected. Script will continue...\n"
          else
             echo "No Link Interface Detected"
	     echo "No Luck. Please, activate one NIC and logon again VA to test"
	     exit		
        fi
else
	echo "$file not found.NIC Detection FAILED. Reboot for persistent rules create file"
	exit
	#shutdown -r now
fi


}

#END NIC DETECTION


installCron ()
{

crontab -l > file; echo '30 1 * * 0 /home/admin/scripts/./clean_cache.sh >> /opt/WCG/cache_clean.log 2>&1' >> file; crontab file

}

Patching ()
{

$SHOME/scripts/./patching.sh

}

main ()
{
clear
echo ""
echo "THREAT PROTECTION FOR LINUX EASY SETUP" 

echo ""

   




#echo "This script is used to set static hostname and IP address, press enter if you want to set default value"
printf "Press Any key to Continue\n"
read press


NicDetect

#acceptInput
ans="n"
while [ "$ans" == "N" -o "$ans" == "n" ]
do
        #clear
        echo ""
        echo "This script is used to set static hostname and IP address"
	echo "Please, enter the following options for management networking"
	echo "1) eth0 only"
	echo "2) eth0 and eth1"
	echo "3) skip network settings and start setup"
	echo "Enter your option:" 
        read Interth
        echo ""

        case "$Interth" in

	1) change_eth0 
	   enter_gateway
	   #enter_routes
	   setIpHostname
	   acceptInput
	   ;;
	2) 
           change_eth0
           change_ethX
	   enter_gateway
	   #enter_routes
	   setIpHostname
	   acceptInput
	   ;;
	3)
	   #CALL INSTALLING PROCESS	
	   installTPL		
	   ;;	
        esac 
done

if [ "$ans" == "Y" -o "$ans" == "y" ]
then

        # This VA so set it for every boot
        cp /etc/hosts $SHOME/backups
        cp /etc/resolv.conf $SHOME/backups
        cp /etc/sysconfig/network $SHOME/backups
        cp /etc/sysconfig/network-scripts/ifcfg-eth0 $SHOME/backups
	cp /etc/ntp.conf $SHOME/backups

	#setIpHostname


        #echo "OK DONE ...Restarting Networking Services"
	#service network restart
        #echo "----------------------------------------------"        

	
	#installCron

       # Patching


	echo "Congratulations, TPL is all set!!"
	echo "Do you like to harden your Operating System?:(y/n)"
	read hyn
	if [ "$hyn" == "y" ] || [ "$hyn" == "Y" ]
	 then
	  $SHOME/scripts/./hard_iptables.sh
         else
          	iptables -F
          	iptables -X
          	iptables -t nat -F
          	iptables -t nat -X
		iptables -t mangle -F
		iptables -t mangle -X
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
                rm -f /sysconfig/iptables
                service iptables stop
                chkconfig iptables off 

	fi
	service ntpd restart
	service iptables restart
	hostname $hostname
	enter_routes
         
fi
}

# Start of the program
main


