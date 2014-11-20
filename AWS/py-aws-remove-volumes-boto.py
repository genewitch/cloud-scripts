#e.g. 2014-11-19 or 2014 or 2014-10
datearg = sys.argv[1]
#e.g. get_all_volumes() in boto.ec2
for vol in volumeList:
    if vol.status == "in-use":
        continue
    if datearg in str(vol.create_time):
        print("+++++++++++++++++++")
        print(vol)
        print(vol.status + ", create_time:" + vol.create_time)
        if (vol.delete()):
            print("==============================================")
        else:
            print("failed deletion failed on", vol, "\n****************")
