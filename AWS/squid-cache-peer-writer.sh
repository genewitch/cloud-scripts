#!/bin/bash
#requires script aws-cli-elb-get-private-ips.sh availabile from 
#https://github.com/genewitch/cloud-scripts
#Outputs a squid config compatible list of servers available in the pool
# of healthy servers.
#This can be run as a cron, and output to /etc/squid/cache_peers.conf, which 
# in turn can be included in /etc/squid/squid.conf

IPLIST=`./aws-cli-elb-get-private-ips.sh`
for ipaddr in $IPLIST; do

echo $ipaddr | sed -e "s/^/cache_peer /g" | sed -e "s/$/ parent 80 0 no-query originserver round-robin login=PASS/g"
done

