#!/bin/bash
#takes no input currently
#outputs an \n delimited list of private ipv4 addresses of healthy instances in the load balancer.

ELB_NAME="sitename-elb-1"
REGION="us-west-2"

INSTANCES=`aws elb describe-load-balancers  --load-balancer $ELB_NAME --region $REGION --output text |grep i-`
#echo $INSTANCES

aws ec2 describe-instances --region $REGION --output text > templist.dat

for id in $INSTANCES; do
INFO=`grep $id templist.dat`
SPOT=`echo $INFO |grep spot`
if [ "$SPOT" = "" ]
then
echo $INFO |awk '{print $8}'
else
echo $INFO |awk '{print $9}'
fi
done
