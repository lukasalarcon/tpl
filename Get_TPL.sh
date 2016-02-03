#!/bin/bash
set -x

#MAIN SOURCE PATCH _ NO NOT MODIFY
tmpp=tmpp;
mkdir $tmpp;
wget -O $tmpp/TPL.txt --content-disposition https://www.dropbox.com/s/i0ytkyd8t1awuky/TPL.txt -P tmpp


for line in $(cat tmpp/TPL.txt); 
 do
   echo "Found ""$line" ; 
   if  [[ $line == *#* ]]  
    then
     echo "Applying "$line;
     truktor=$line;
    else
     echo "Downloading....";
      wget --content-disposition $line -P $tmpp;
   fi
 done
#rm -fR $tmpp;
