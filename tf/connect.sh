#!/bin/bash

IP=$( cat servers.yml  | grep public_ip | awk '{ print $2 }' )

ssh -o StrictHostKeyChecking=no ubuntu@${IP}
