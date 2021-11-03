#!/bin/bash

yum -y install epel-release 
yum -y update
yum -y install jwhois bind-utils tmux screen mtr traceroute tcpdump tshark

rm -rf /etc/profile.d/locale.sh

echo "export LC_CTYPE=en_US.UTF-8" >> /etc/profile.d/locale.sh
echo "export LC_ALL=en_US.UTF-8" >> /etc/profile.d/locale.sh

rm -rf /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf


rm -rf  /etc/sysconfig/i18n
echo "LANG=en_US.UTF-8" >> /etc/sysconfig/i18n

rm -rf /etc/environment
echo "LANG=en_US.UTF-8" >> /etc/environment
echo "LC_ALL=en_US.UTF-8" >> /etc/environment


yum -y install ntp
systemctl enable ntpd 
systemctl start ntpd 
timedatectl set-timezone Asia/Singapore
timedatectl set-ntp yes
ntpq -p

date
