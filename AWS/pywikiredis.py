import xml.sax
import string
import redis
import re


def injectPipe(rInstance, textString):
        "increments redis object's key for each word in textString"
        templist = stripNonWhitespace(textString)
        for (word) in templist:
                rInstance.incr(namespaces + word)

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
                if name == 'text':
                        self.inTextContent = 0
                        self.textArea = normalize_whitespace(self.textArea)
                        #debug print
#                        print self.textArea.split(" ", 10)
                        #Actual output
                        injectPipe(pipe, self.textArea)
                        pipe.execute()

#main
namespaces = "m8oevj:"
r = redis.Redis("localhost", db=0)
pipe = r.pipeline()
parser = xml.sax.make_parser()
parser.setContentHandler(xHandler())
parser.parse(open("enwiki-20130204-pages-articles.xml","r"))
