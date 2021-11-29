#!/bin/bash


apt-get update -y
apt-get install -yq locales wget gnupg2 lsb-release vim git screen
echo 'LC_ALL=en_US.UTF-8' >> /etc/default/locale
echo 'LANG=en_US.UTF-8' >> /etc/default/locale
echo 'LANGUAGE=en_US:en' >> /etc/default/locale

echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
source ~/.bashrc
locale

