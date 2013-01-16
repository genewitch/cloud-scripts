#!/bin/bash
# Set region
AWSREGION="us-west-2"
for s in `ec2-describe-volumes --region $AWSREGION |awk '{ print $3 }' | grep -v \-`; do cur=$s+$cur; done; echo ${cur}"0" |bc -l
