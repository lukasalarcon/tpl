#!/bin/bash

# GNU GPL Software under the GPL may be run for all purposes, including commerci
#al purposes and even as a tool for creating proprietary software.
#GLOBAL VAR
VERSION=10

#ORCHESTASTE ALL LOCAL BASH


#INSTALL TPL SERVER

./setup_TPL.sh


#INSTALL CLIENT BINARIES 

./setup_Client.sh


#INSTALL SPLUNK

./setup_Splunk.sh

#REBOOT SERVER


reboot


