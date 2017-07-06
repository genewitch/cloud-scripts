from rdrand import RdRandom
import sys
r = RdRandom()
i=0

numstreams=256
numbits=1000000
bitsperfetch=10000

while i < numbits/bitsperfetch :
        i=i+1
        bytte = r.getrandbytes(numstreams*bitsperfetch)
        sys.stdout.write(bytte)
#       binpk = format(bytte,'c')
#       print(binpk),
#       binar = format(bytte,'b')
#       print(binar)
#       print(format(r.getrandbits(8),'c')),

sys.stdout.flush()
