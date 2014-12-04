import redis
import string

counter=0
left=0
toggle = 1
"""r = redis.StrictRedis('localhost')"""

#sockets are faster for doing transforms
r = redis.StrictRedis(unix_socket_path='/tmp/redis.sock')
#and pipes are faster yet
pipe = r.pipeline()

zkey = "ztest"

# this program outputs how many NEW members were added to sorted set
starting = r.zcard(zkey)

while toggle:

    left, right = r.scan(left, match="4:*")
    for word in right:
        score = r.get(word)
        pipe.zadd(zkey, float(score), word)
        counter = counter + 1

    if counter > 10000:
        #pipelining 10k responses seems to work ok
        pipe.execute()
        counter = 0

    if left == 0:
        #left starts at 0 and when it is 0 again zscan is complete
        toggle = 0

print(r.zcard(zkey)-starting)
