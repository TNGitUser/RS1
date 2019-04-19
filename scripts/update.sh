#!/bin/sh
sleep 10
apt-get update -y > /var/log/update_script.log
apt-get upgrade -y >> /var/log/update_script.log
