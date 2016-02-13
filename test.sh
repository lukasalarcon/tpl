_MYKEY=$(more /home/secondlook/.ssh/id_rsa.pub)

_SECONDLOOK=/usr/share/secondlook


sed s'/PUBLIC_KEY_GOES_HERE/'"$_MYKEY"'/' $_SECONDLOOK/agent_ssh_authorized_keys
