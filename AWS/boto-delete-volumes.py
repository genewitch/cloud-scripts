import boto.ec2
import string

conn = boto.ec2.connect_to_region("eu-west-1",
    aws_access_key_id='',
    aws_secret_access_key='')

volumeList = conn.get_all_volumes()
"""print(len(volumeList))
print(volumeList)"""

for vol in volumeList:
    if vol.status == "in-use":
        continue
    if '2014-11' in str(vol.create_time):
        print(vol.status + ", create_time:" + vol.create_time)
