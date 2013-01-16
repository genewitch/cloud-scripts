#!/bin/bash
# get-vip-private-fqdn.sh
# use ELB as a middle tier vip interface for a pool.

#set region (us-east-1 SHORTREGION would be "east")
AWSREGION="eu-west-1"
SHORTREGION="west"

#set elb name
ELBNAME="SETME"


IDS=`elb-describe-instance-health --region eu-west-1 -lb $ELBNAME |awk '{print $2}'`
ec2-describe-instances --region $AWSREGION |grep $SHORTREGION > templist
for instance in $IDS; do
grep $instance templist |awk '{print $5,$10}'
done

#cleanup
rm templist
