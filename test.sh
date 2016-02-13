#_MYKEY=$(more /home/secondlook/.ssh/id_rsa.pub)

#_SECONDLOOK=/usr/share/secondlook


#sed s'/PUBLIC_KEY_GOES_HERE/'"$_MYKEY"'/' $_SECONDLOOK/agent_ssh_authorized_keys
read variable
var="$(grep -F -m 1 '$variable =' /etc/myplaybook/hosts)"
echo "Nueva Var:"
echo $var
