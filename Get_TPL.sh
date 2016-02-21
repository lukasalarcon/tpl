#!/bin/bash
#set -x
#
# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.
#

function GetWget () {


_wget=$(rpm -qa wget)

#GETTING WGET
if [[ "$_wget" == "wget"* ]]
        then
                echo "Package WGET              [OK]"
        else
                echo "Proceed to Install wget"
                sudo yum -y install wget


fi

#END WGET
}

function GetTheSource () {

#GET THE SOURCE FROM DROPBOX

tmpp=tmpp;
mkdir $tmpp;
wget -O $tmpp/TPL.txt --content-disposition https://www.dropbox.com/s/i0ytkyd8t1awuky/TPL.txt -P tmpp


for line in $(cat tmpp/TPL.txt); 
 do
   echo "Found ""$line" ; 
   if  [[ $line == *#* ]]  
    then
     echo "Applying "$line;
     Dwn=$(echo $line| sed 's/#//');
    else
     echo "Downloading....";
      wget -O $tmpp/$Dwn --content-disposition $line -P $tmpp;
   fi
 done
#rm -fR $tmpp;

}


##MAIN

	GetWget
		 GetTheSource
#END MAIN
