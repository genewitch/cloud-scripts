#e.g. 2014-11-19 or 2014 or 2014-10
datearg = sys.argv[1]

#e.g. get_all_volumes() in boto.ec2
for vol in volumeList:
    if vol.status == "in-use":
        sleep(10)
        print("Awake")
        continue
    if datearg in str(vol.create_time):
        print("+++++++++++++++++++\n" + vol)
        print(vol.status + ", create_time:" + vol.create_time)
        if (vol.delete()):
            print("==============================================")
        print("failed deletion failed on " + vol + "\n ***********)
        
