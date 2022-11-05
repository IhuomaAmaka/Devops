#!/bin/bash
#this script will list all AWS services managed by terraform in this account and also show details of  each resource on demand
b=2

echo to see all your services type "yes"

read option

echo loading services ...

aws servicediscovery list-services

sleep 3

echo task is completed. To view a specific resource type yes, if not type no

read option

case $option in
		          "no")
				  			                    echo "thanks and enjoy your day";;

									    					              "yes") sleep 1
																      							                        echo enter the resource address from the list above
																																				                  read resource
																																						  												                    echo you entered: `echo $resource`
																																																				    														                      echo loading ...
																																																																				      																                        terraform state show $resource;;
																																																																																																										 esac
																																																																																																										 																			 

