# rdrand-tmpfs-writer.py :
#
#  this script, specifically, will write 256000000 characters to stdout. use:
#
#         ../rdrand-tmpfs-writer.py > /tmp/foo/rdrand.out 
#
#  or so.
#
# And if you're using NIST software, it's 1000000 bits per bitstream, 256 bitstreams. Assess that.
#
# Further, I'll unpatiently add, only works on python2 if you use easy_install on gentoo.

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
