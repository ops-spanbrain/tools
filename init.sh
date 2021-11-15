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


cd /usr/lcoal/src/
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl /usr/include/openssl.bak

wget -O https://www.openssl.org/source/openssl-1.1.1k.tar.gz

tar -zxvf openssl-1.1.1k.tar.gz

cd /usr/local/openssl-1.1.1k

./config --prefix=/usr/local/openssl
make && make install

ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v

openssl version



yum -y install ntp
systemctl enable ntpd 
systemctl start ntpd 
timedatectl set-timezone Asia/Singapore
timedatectl set-ntp yes
ntpq -p

date
