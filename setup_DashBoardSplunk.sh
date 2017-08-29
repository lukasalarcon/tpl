#!/bin/bash



function NewDashBoard () {

echo "Give me a minute to find Splunk Binaries...\n"
getSplunkbin=$(find / -name splunk | grep bin/splunk)


#Ask for user and Password
echo "Please, enter admin user for Splunk Platform:\n"
read user
echo "Please, enter password for Splunk Platform:\n"
read pass

#Shows a Summary for 

echo "User: " $user "\n"
echo "Password: " $pass "\n"
echo "The following step will require to download Splunk App from Forcepoint Portal: forcepoint-threat-protection-for-linux-second-look-app-for-splunk_142.tgz"
echo "Please, enter the full route for Splunk App\n"
read PACKAGE_FILENAME

        if [ -f $PACKAGE_FILENAME ]
                then
			$getSplunkbin install app $PACKAGE_FILENAME -auth $user:$pass
                else
                        echo "We cannot find the package."
                        echo "Would you like to try again?(y/n)"
                        read GetA
                                if [ "$GetA" == "Y" -o "$GetA" == "y" ]
                                        then
						NewDashBoard				
                                        else
                                                echo "GoodBye.!"
                                                exit 1
                                fi


        fi

}

#MAIN 

	NewDashBoard
