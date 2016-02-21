#!/bin/bash

# GNU GPL Software under the GPL may be run for all purposes, including commercial purposes and even as a tool for creating proprietary software.

wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Online"
    else
        echo "Offline"
	fi
