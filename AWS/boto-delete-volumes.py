import boto.ec2
import string

conn = boto.ec2.connect_to_region("us-west-2",
    aws_access_key_id='AKIAIAJ2KOPEIAYBNV4A',
    aws_secret_access_key='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')

volumeList = conn.get_all_volumes()
"""print(len(volumeList))
print(volumeList)"""

for vol in volumeList:
    if vol.status == "in-use":
        continue
    print(vol.status)
    print(vol)
