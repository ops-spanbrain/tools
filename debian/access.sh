#!/bin/bash

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


echo "rs"

rm -f rs.zone
wget --no-check-certificate -O rs.zone https://www.ipdeny.com/ipblocks/data/countries/rs.zone
for i in `cat rs.zone`
do
    ipset add access $i 
done


hostIp=$(sed -n 1p /var/log/voipIp.log)
echo $hostIp
##add server ip
ipset add access $hostIp
ipset add access 188.166.247.11