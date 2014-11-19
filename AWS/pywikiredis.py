import xml.sax
import string
import redis
import re


def injectPipe(rInstance, textString):
        "increments redis object's key for each word in textString"
        global counter
        templist = stripNonWhitespace(textString)
        for (word) in templist:
                rInstance.incr(namespaces + word)
                counter = counter + 1

def stringToList(string):
        "makes a list of words from a string"
        return string.split(" ")

def stripNonWhitespace(tString):
        "Added to stop redis from crashing from OOM. KEYS() works now, too."
        " \w was not working as i intended so trying to fix now"
        return re.findall("[A-Za-z]+", tString)

def normalize_whitespace(text):
        "Remove redundant whitespace from a string"
        return ' '.join(text.split())

class xHandler(xml.sax.ContentHandler):
        def __init__(self):
                self.inTextContent = 0
        def startElement(self, name, attrs):
                if name == 'page':
                        title = normalize_whitespace(attrs.get('title', ""))
                        self.this_title = title
                elif name == 'text':
                        self.inTextContent = 1
                        self.textArea = ""

        def characters(self, ch):
                if self.inTextContent:
                        self.textArea = self.textArea + ch

        def endElement(self, name):
                global r
                global counter
                if name == 'text':
                        self.inTextContent = 0
                        self.textArea = normalize_whitespace(self.textArea)
                        #debug print
#                        print self.textArea.split(" ", 10)
                        #Actual output
                        injectPipe(pipe, self.textArea)
                        """counter = counter + 1"""
                        if counter > 10000:

                                """print("Executing pipe")"""
                                pipe.execute()
                                counter = 0

#main
counter = 0
namespaces = "2:"
r = redis.Redis("localhost", db=0)
"""r = redis.Redis('/tmp/redis.sock')"""
pipe = r.pipeline()
parser = xml.sax.make_parser()
parser.setContentHandler(xHandler())
parser.parse(open("enwiki-20130204-pages-articles.xml","r"))
