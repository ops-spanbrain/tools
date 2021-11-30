#!/bin/bash

cd /usr/local/src

wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add -

echo "deb http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
 
apt-get update -y
apt-get build-dep -y freeswitch

apt-get install -y gnupg2 wget autoconf lsb-release libtool libtool-bin libtiff-dev uuid-dev pkg-config openssl libssl-dev sqlite3 libsqlite3-dev libcurl4-openssl-dev libspeexdsp-dev libldns-dev libedit-dev yasm nasm ffmpeg libswscale-dev libavformat-dev lua5.4 liblua5.4-dev libopus-dev libpq-dev libmariadb-dev unixodbc unixodbc-dev libsndfile1-dev


git clone https://github.com/signalwire/freeswitch.git -b v1.10 freeswitch
cd freeswitch
git config pull.rebase true
./bootstrap.sh -j

echo "bootstrap done"

cd /usr/local/src/freeswitch

git clone https://github.com/freeswitch/spandsp.git

cd /usr/local/src/freeswitch/spandsp
./bootstrap.sh -j
./configure
make
make install
ldconfig

echo "spandsp done"
cd /usr/local/src/freeswitch

git clone https://github.com/freeswitch/sofia-sip.git
cd /usr/local/src/freeswitch/sofia-sip
./bootstrap.sh -j
./configure
make
make install
ldconfig
echo "sofia-sip done"

cd /usr/local/src/freeswitch

./configure
make && make install
make cd-sounds-install
make cd-moh-install

sed -i 's/#xml_int\/mod_xml_curl/xml_int\/mod_xml_curl/g' /usr/local/src/freeswitch/modules.conf
./configure
make mod_xml_curl-install

sed -i 's/#event_handlers\/mod_format_cdr/event_handlers\/mod_format_cdr/g' /usr/local/src/freeswitch/modules.conf
./configure
make mod_format_cdr-install

cd /usr/local/src

# install g729
apt-get -y install libfreeswitch-dev git autoconf automake libtool
git clone https://github.com/ops-spanbrain/mod_g729.git
cd mod_g729
make && make install

ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/ 
ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/

echo "load server"

#touch /etc/systemd/system/freeswitch.service

tee /etc/systemd/system/freeswitch.service <<-'EOF'
[Unit]
Description=FreeSWITCH
After=syslog.target network.target

[Service]
User=root
Group=daemon
EnvironmentFile=-/etc/default/freeswitch
WorkingDirectory=/usr/local/freeswitch
ExecStart=/usr/local/freeswitch/bin/freeswitch -nc -nf $FREESWITCH_PARAMS 
ExecReload=/usr/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target graphical.target
EOF

echo "load system service"

chmod ugo+x /etc/systemd/system/freeswitch.service

systemctl --system daemon-reload

cd /usr/local/src

# cd /usr/local
# useradd --system --home-dir /usr/local/freeswitch -G daemon freeswitch
# passwd -l freeswitch
# chown -R freeswitch:daemon /usr/local/freeswitch/ 
# chmod -R 770 /usr/local/freeswitch/
# chmod -R 750 /usr/local/freeswitch/bin/*
# mkdir /var/run/freeswitch
# chown -R freeswitch:daemon  /var/run/freeswitch
# ln -s /usr/local/freeswitch/bin/freeswitch /usr/bin/


serverId=$(sed -n 1p /var/log/voip.log)
serverAddr=$(sed -n 1p /var/log/voipAddr.log)
hostIp=$(sed -n 1p /var/log/voipIp.log)

echo $serverId
echo $serverAddr
echo $hostIp

FSCONFDIR="/usr/local/freeswitch/conf"

rm -rf $FSCONFDIR/vars.xml
curl -o $FSCONFDIR/vars.xml "$serverAddr/fs/init/$serverId/vars"

rm -rf $FSCONFDIR/autoload_configs/modules.conf.xml
curl -o $FSCONFDIR/autoload_configs/modules.conf.xml "$serverAddr/fs/init/$serverId/modules"

rm -rf $FSCONFDIR/autoload_configs/format_cdr.conf.xml
curl -o $FSCONFDIR/autoload_configs/format_cdr.conf.xml "$serverAddr/fs/init/$serverId/cdr"

rm -rf $FSCONFDIR/autoload_configs/xml_curl.conf.xml
curl -o $FSCONFDIR/autoload_configs/xml_curl.conf.xml "$serverAddr/fs/init/$serverId/curl"

rm -rf $FSCONFDIR/autoload_configs/event_socket.conf.xml
curl -o $FSCONFDIR/autoload_configs/event_socket.conf.xml "$serverAddr/fs/init/$serverId/es"

rm -rf $FSCONFDIR/autoload_configs/acl.conf.xml
curl -o $FSCONFDIR/autoload_configs/acl.conf.xml "$serverAddr/fs/init/$serverId/acl"

rm -rf $FSCONFDIR/autoload_configs/switch.conf.xml
curl -o $FSCONFDIR/autoload_configs/switch.conf.xml "$serverAddr/fs/init/$serverId/switch"

rm -rf $FSCONFDIR/directory/default.xml
curl -o $FSCONFDIR/directory/default.xml "$serverAddr/fs/init/$serverId/directoryDefault"

rm -rf $FSCONFDIR/sip_profiles/external.xml
curl -o $FSCONFDIR/sip_profiles/external.xml "$serverAddr/fs/init/$serverId/sipExternal"

rm -rf $FSCONFDIR/sip_profiles/internal.xml
curl -o $FSCONFDIR/sip_profiles/internal.xml "$serverAddr/fs/init/$serverId/sipInternal"

echo "mkdir recordings"

mkdir -p /usr/local/freeswitch/recordings/$serverId

echo "/usr/local/freeswitch/recordings/$serverId $hostIp/32(ro,sync,no_root_squash,no_all_squash)" >> /etc/exports

exportfs -r

showmount -e localhost

curl -s "$serverAddr/fs/init/$serverId/install"

cd /etc/nginx/conf

wget --no-check-certificate -O rtc.conf "$serverAddr/fs/init/$serverId/nginx"

echo "install done"

echo "set network"

mkdir -p /usr/local/brain

cd /usr/local/brain

wget --no-check-certificate -O access.sh https://raw.githubusercontent.com/ops-spanbrain/tools/main/debian/access.sh

chmod +x /usr/local/brain/access.sh

/usr/bin/bash /usr/local/brain/access.sh

tee /usr/local/brain/iptables.rules <<-'EOF'
# Generated by iptables-save v1.8.0 
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -m set --match-set access src -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 22 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 80 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 443 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 9998 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 9066 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 9443 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 9905 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 9908 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 5081 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 5061 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 8099 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 5002 -j ACCEPT
-A INPUT -m set --match-set access src -p udp --dport 5003 -j ACCEPT
-A INPUT -m set --match-set access src -p udp --dport 9905 -j ACCEPT
-A INPUT -m set --match-set access src -p udp --dport 9908 -j ACCEPT
-A INPUT -p udp --dport 3478 -j ACCEPT
-A INPUT -p udp --dport 3479 -j ACCEPT
-A INPUT -m set --match-set access src -p udp -m udp --dport 16384:32768 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 111 -j ACCEPT
-A INPUT -p udp -m udp --dport 111 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT
-A INPUT -p udp -m udp --dport 2049 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 6001:6004 -j ACCEPT
-A INPUT -p udp -m udp --dport 6001:6004 -j ACCEPT
-A INPUT -m set --match-set access src -p tcp --dport 8080 -j ACCEPT
-A INPUT -m set --match-set access src -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
COMMIT
EOF

chmod +x /usr/local/brain/iptables.rules

tee /etc/network/if-pre-up.d/iptables <<-'EOF'
#!/bin/sh
/usr/bin/bash /usr/local/brain/access.sh
/sbin/iptables-restore < /usr/local/brain/iptables.rules
/usr/bin/fsclient start
EOF

chmod +x /etc/network/if-pre-up.d/iptables

/sbin/iptables-restore < /usr/local/brain/iptables.rules

echo "all start server"

systemctl restart nfs-kernel-server
systemctl enable nfs-kernel-server

systemctl start freeswitch.service
systemctl enable freeswitch.service

iptables -L -n

echo "init auth start"

mkdir -p /usr/local/ops
cd /usr/local/ops
git clone https://github.com/ops-spanbrain/ctx.git

chown -R www-data /usr/local/ops/ctx

cd /usr/local/brain

wget --no-check-certificate -O fsclient https://github.com/ops-spanbrain/tools/raw/main/dow/fsclient

mv fsclient /usr/bin

chmod +x /usr/bin/fsclient

/usr/bin/fsclient start

mkdir -p /usr/local/freeswitch/voice

cd /usr/local/freeswitch/voice

wget --no-check-certificate -O NumberDoesNotExist.wav https://github.com/ops-spanbrain/tools/raw/main/dow/voice/NumberDoesNotExist.wav
wget --no-check-certificate -O insufficientBalance.wav https://github.com/ops-spanbrain/tools/raw/main/dow/voice/insufficientBalance.wav
wget --no-check-certificate -O sipCrowded.wav https://github.com/ops-spanbrain/tools/raw/main/dow/voice/sipCrowded.wav
