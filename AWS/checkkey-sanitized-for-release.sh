#!/bin/bash
# how to use:
# allow this to run as a cgi.
# you call it like this
# logger `curl http://example.domain.com/cgi-bin/checkkey.cgi?key=MY_PRESHARED_KEY`
# it will output either access declined if the key is wrong,
# or the output of the ec2-authorize command for each port/range, as well as "completed" when it finishes.
# it is useful for cloud-init scripts to call to your IAM Role enabled box to allow ingress for puppet, for example.
# the host this CGI runs on must have the ec2 CLI tools installed:
EC2_HOME=/opt/aws/apitools/ec2

#set java depending on version, please ensure the proper section is uncommented:
#64bit
#JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/jre

#32bit
JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/jre

#set your region here
AWSREGION="us-east-1"

# space delimited set of ports. you can also use ranges:
# PORTLIST="80-81 443 2000-2200"
PORTLIST="80 443 8000 8080"

# The SGID parameter is name or ID of the group to grant this permission to.
# SGID="sg-12837ac2"
SGID="Puppet"


echo Content-type: text/plain
echo ""

# cgi handler section
saveIFS=$IFS
IFS="=&"
param=($QUERY_STRING)
IFS=$saveIFS

declare -A parameter
for ((i=0; i<${#param[@]}; i+=2))
do
    parameter[${param[i]}]=${param[i+1]}
done

# Please set your pre-shared key in quotes where indicated below
if [[ ${parameter["key"]} != "SET_ME_TO_A_PRE-SHARED_KEY!!!!!" ]]; then
	echo "ACCESS DECLINED"
	exit
fi

# Actually authorize.
for ports in $PORTLIST; do
EC2_HOME=$EC2_HOME JAVA_HOME=$JAVA_HOME /opt/aws/bin/ec2-authorize --region $AWSREGION $SGID -P tcp -p $ports -s $REMOTE_ADDR/32
done

echo "Completed"

