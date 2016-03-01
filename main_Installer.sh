#!/bin/bash

# GNU GPL Software under the GPL may be run for all purposes, including commerci
#al purposes and even as a tool for creating proprietary software.


#ORCHESTASTE ALL LOCAL BASH


#INSTALL TPL SERVER

./setup_TPL.sh


#INSTALL APACHE FOR TPL

./setup_Apache.sh


#INSTALL ANSIBLE AND AGENT

./setup_Client.sh


#INSTALL SPLUNK

./setup_Splunk.sh


