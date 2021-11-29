#!/bin/bash

touch /var/log/voip.log
touch /var/log/voipAddr.log
touch /var/log/voipIp.log

serverId=$1
echo $serverId > /var/log/voip.log

serverAddr=$2
echo $serverAddr > /var/log/voipAddr.log

hostIp=$3
echo $hostIp > /var/log/voipIp.log

file="/usr/bin/screen"

if [ ! -f $file ]; then
 apt-get -y install screen 
fi

apt-get update -y
apt-get install -yq gnupg2 lsb-release vim git screen


cd /usr/local/src

apt-get -y install ipset nfs-kernel-server 
apt-get -y install snapd
snap install --classic certbot

curl -s https://raw.githubusercontent.com/ops-spanbrain/tools/main/debian/nginx.sh | bash

screen_name=$"log"
screen -dmS $screen_name

cmd=$"curl -s https://raw.githubusercontent.com/ops-spanbrain/tools/main/debian/fs.sh | bash"

screen -x -S $screen_name -p 0 -X stuff "$cmd"
screen -x -S $screen_name -p 0 -X stuff $'\n'

echo $(sed -n 1p /var/log/voip.log)
echo $(sed -n 1p /var/log/voipAddr.log)
echo $(sed -n 1p /var/log/voipIp.log)

echo "done"