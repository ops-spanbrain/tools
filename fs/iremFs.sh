#!/bin/bash

cd /usr/local/src

yum -y install iptables iptables-services
yum -y install rpcbind nfs
yum -y install iftop nload
yum -y install ipset

systemctl enable rpcbind
systemctl enable nfs
systemctl enable iptables

wget -qO- https://raw.githubusercontent.com/ops-spanbrain/tools/main/igit.sh | bash && source /etc/bashrc && git --version


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
 yum -y install screen 
fi

cd /usr/local/src

screen_name=$"log"
screen -dmS $screen_name

cmd=$"curl -s https://raw.githubusercontent.com/ops-spanbrain/tools/main/fs/ifs1.6.sh | bash"

screen -x -S $screen_name -p 0 -X stuff "$cmd"
screen -x -S $screen_name -p 0 -X stuff $'\n'

echo $(sed -n 1p /var/log/voip.log)
echo $(sed -n 1p /var/log/voipAddr.log)
echo $(sed -n 1p /var/log/voipIp.log)

echo "done"