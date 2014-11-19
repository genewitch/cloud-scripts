import redis
import string

counter=0
left=0
toggle = 1
"""r = redis.StrictRedis('localhost')"""
r = redis.StrictRedis(unix_socket_path='/tmp/redis.sock')
pipe = r.pipeline()
zkey = "ztest"
while toggle:

    left, right = r.scan(left, match="4:*")
    for word in right:
        score = r.get(word)
        pipe.zadd(zkey, float(score), word)
        counter = counter + 1

    if counter > 10000:
        pipe.execute()
        counter = 0

    if left == 0:
        toggle = 0
