#!/bin/bash -x
################################
#
# BY-NC-SA CC license version 2.0 or greater.
# 
# Fetches the "latest.zip" zipped list of IPs from s3 bucket (or other URI)
# Compares to last known list after unzipping contents and stripping the "ip_address" line.
# If the latest zip is newer than our data, run nmap scan style list, 
# input list latest, don't ping, and output to XML in webroot.
# 
###############################

# Fetch latest.zip.
## change URI to get from someplace else.
wget http://ccccraziness.s3-website-us-west-2.amazonaws.com/latest.zip -O latest.zip

# Save the name of the unzipped document so we can change it
# 
NEWFILE=`unzip -o -j latest.zip |grep inflating |awk '{ print $2 }'`

##############mv /root/$NEWFILE /root/latest
#strip ip_address from first line
sed "s/^ip_address*//" $NEWFILE > /root/latest

# compare latest (above) and last (local), count differences.
DF=`diff latest last |wc -l`
#echo $DF
#echo $NEWFILE

# if diff's output is 0, the files are the same, any other number means they're different.
if [ "$DF" -gt "0" ]
then echo ;
echo "diff changed, running nmap"

# nmap scan style list, input list latest, don't ping, and output to XML in webroot.
nmap -sL -iL latest -P0 -oX /var/www/html/nmapperout.xml

# last needs to be updated to current version
rm -rf last
mv latest last

else
echo "no change, deleting temp latest file"
# Deleting this file to prevent loops on consecutive runs
rm -rf latest

fi
