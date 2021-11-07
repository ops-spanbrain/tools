#!/bin/bash

cd /usr/local/src

yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm epel-release
 
yum install -y alsa-lib-devel autoconf automake bison broadvoice-devel bzip2 curl-devel libdb4-devel e2fsprogs-devel erlang flite-devel g722_1-devel gcc-c++ gdbm-devel gnutls-devel ilbc2-devel ldns-devel libcodec2-devel libcurl-devel libedit-devel libidn-devel libjpeg-devel libmemcached-devel libogg-devel libsilk-devel libsndfile-devel libtheora-devel libtiff-devel libtool libuuid-devel libvorbis-devel libxml2-devel lua-devel lzo-devel mongo-c-driver-devel ncurses-devel net-snmp-devel openssl-devel opus-devel pcre-devel perl perl-ExtUtils-Embed pkgconfig portaudio-devel postgresql-devel python-devel python-devel soundtouch-devel speex-devel sqlite-devel unbound-devel unixODBC-devel wget which yasm zlib-devel libshout-devel libmpg123-devel lame-devel

yum install -y gcc-c++ alsa-lib-devel autoconf automake bison bzip2 curl-devel e2fsprogs-devel flite-devel gdbm-devel gnutls-devel ldns-devel libcurl-devel libedit-devel libidn-devel libjpeg-devel libmemcached-devel libogg-devel libsndfile-devel libtiff-devel libtheora-devel libtool libvorbis-devel libxml2-devel lua-devel lzo-devel mongo-c-driver-devel ncurses-devel net-snmp-devel openssl-devel opus-devel pcre-devel perl perl-ExtUtils-Embed pkgconfig portaudio-devel postgresql-devel python-devel soundtouch-devel speex-devel sqlite-devel unbound-devel unixODBC-devel libuuid-devel which yasm zlib-devel


git clone -b v1.6 https://github.com/signalwire/freeswitch.git freeswitch

chmod -R 777 /usr/local/src/freeswitch

cd /usr/local/src/freeswitch

./bootstrap.sh 

./configure

make 
make install
make cd-sounds-install
make cd-moh-install
ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/ 
ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/

echo "load server"

touch /usr/lib/systemd/system/freeswitch.service

tee /usr/lib/systemd/system/freeswitch.service <<-'EOF'

[Unit]
Description=FreeSWITCH
After=syslog.target network.target
After=mysqld.service

[Service]
User=root
EnvironmentFile=-/etc/sysconfig/freeswitch
WorkingDirectory=/usr/local/freeswitch
ExecStart=/usr/local/freeswitch/bin/freeswitch -nc -nf $FREESWITCH_PARAMS 
ExecReload=/usr/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target graphical.target

EOF

echo "load system service"

systemctl --system daemon-reload


cd /usr/local/src/freeswitch


#install xml curl
#sed -i 's/#applications\/mod_curl/applications\/mod_curl/g' /usr/local/src/freeswitch/modules.conf
sed -i 's/#xml_int\/mod_xml_curl/xml_int\/mod_xml_curl/g' /usr/local/src/freeswitch/modules.conf


#sed -i 's/#say\/mod_say_zh/say\/mod_say_zhl/g' /usr/local/src/freeswitch/modules.conf

#sed -i 's/#applications\/mod_callcenter/applications\/mod_callcenter/g' /usr/local/src/freeswitch/modules.conf


./configure

make mod_xml_curl-install

#make mod_callcenter-install
#make mod_say_zh-install

#install cdr

sed -i 's/#event_handlers\/mod_format_cdr/event_handlers\/mod_format_cdr/g' /usr/local/src/freeswitch/modules.conf

./configure

make mod_format_cdr-install

#install xml g729

cd /usr/local/src

git clone https://github.com/ghosts1995/mod_g729.git

cd mod_g729

make && make install

echo "install done"

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

rm -rf /etc/sysconfig/nfs

tee /etc/sysconfig/nfs <<-'EOF'
MOUNTD_PORT=6001　　
STATD_PORT=6002
LOCKD_TCPPORT=6003
LOCKD_UDPPORT=6003
RQUOTAD_PORT=6004
RPCNFSDARGS=""
RPCMOUNTDOPTS=""
STATDARG=""
SMNOTIFYARGS=""
RPCIDMAPDARGS=""
RPCGSSDARGS=""
GSS_USE_PROXY="yes"
BLKMAPDARGS=""
EOF


echo "/usr/local/freeswitch/recordings/$serverId $hostIp/32(ro,sync,no_root_squash,no_all_squash)" >> /etc/exports

exportfs -r

showmount -e localhost

curl -s "$serverAddr/init/$serverId/install"


systemctl restart nfs

systemctl enable freeswitch.service

systemctl start freeswitch.service

systemctl status freeswitch.service


echo "install done and start "

cd /usr/local/src

ipset create access hash:net hashsize 10000 maxelem 20000000

echo "access"

echo "philippines"
rm -f ph.zone
wget --no-check-certificate -O ph.zone https://www.ipdeny.com/ipblocks/data/countries/ph.zone
for i in `cat ph.zone`
do
    ipset add access $i 
done

echo "taiwan"

rm -f tw.zone
wget --no-check-certificate -O tw.zone https://www.ipdeny.com/ipblocks/data/countries/tw.zone
for i in `cat tw.zone`
do
    ipset add access $i 
done

echo "thai"

rm -f th.zone
wget --no-check-certificate -O th.zone https://www.ipdeny.com/ipblocks/data/countries/th.zone
for i in `cat th.zone`
do
    ipset add access $i 
done


echo "am"

rm -f am.zone
wget --no-check-certificate -O am.zone https://www.ipdeny.com/ipblocks/data/countries/am.zone
for i in `cat am.zone`
do
    ipset add access $i 
done


echo "ge"

rm -f ge.zone
wget --no-check-certificate -O ge.zone https://www.ipdeny.com/ipblocks/data/countries/ge.zone
for i in `cat ge.zone`
do
    ipset add access $i 
done


echo "ua"

rm -f ua.zone
wget --no-check-certificate -O ua.zone https://www.ipdeny.com/ipblocks/data/countries/ua.zone
for i in `cat ua.zone`
do
    ipset add access $i 
done

##add server ip
ipset add access $hostIp


rm -rf /etc/sysconfig/iptables

tee /etc/sysconfig/iptables <<-'EOF'
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
-A INPUT -m set --match-set access src -p udp -m udp --dport 26384:39768 -j ACCEPT
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

chmod +x /etc/sysconfig/iptables

systemctl start iptables
systemctl status iptables

iptables -L -n

echo "init auth start"

tee /etc/rc.d/init.d/access <<-'EOF'
#!/bin/bash
#chkconfig: - 85 15
#description: access is a World iptables server. It is used to serve

hostIp=$(sed -n 1p /var/log/voipIp.log)

echo "add access"

ipset create access hash:net hashsize 10000 maxelem 20000000

ipset add access $hostIp

echo "philippines"
rm -f ph.zone
wget --no-check-certificate -O ph.zone https://www.ipdeny.com/ipblocks/data/countries/ph.zone
for i in `cat ph.zone`
do
    ipset add access $i 
done

echo "taiwan"

rm -f tw.zone
wget --no-check-certificate -O tw.zone https://www.ipdeny.com/ipblocks/data/countries/tw.zone
for i in `cat tw.zone`
do
    ipset add access $i 
done

echo "thai"

rm -f th.zone
wget --no-check-certificate -O th.zone https://www.ipdeny.com/ipblocks/data/countries/th.zone
for i in `cat th.zone`
do
    ipset add access $i 
done


rm -f my.zone
wget --no-check-certificate -O my.zone https://www.ipdeny.com/ipblocks/data/countries/my.zone
for i in `cat my.zone`
do
    ipset add access $i 
done


echo "am"

rm -f am.zone
wget --no-check-certificate -O am.zone https://www.ipdeny.com/ipblocks/data/countries/am.zone
for i in `cat am.zone`
do
    ipset add access $i 
done


echo "ge"

rm -f ge.zone
wget --no-check-certificate -O ge.zone https://www.ipdeny.com/ipblocks/data/countries/ge.zone
for i in `cat ge.zone`
do
    ipset add access $i 
done


echo "ua"

rm -f ua.zone
wget --no-check-certificate -O ua.zone https://www.ipdeny.com/ipblocks/data/countries/ua.zone
for i in `cat ua.zone`
do
    ipset add access $i 
done

EOF

##/etc/rc.d/init.d

chmod +x /etc/rc.d/init.d/access

cd /etc/rc.d/init.d

chkconfig --add access
chkconfig access on