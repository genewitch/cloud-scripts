import xml.sax
import string
import redis



def injectRedis(rInstance, textString):
        "increments redis object's key for each word in textString"
        for (word) in stringToList(textString):
                rInstance.incr(word)

def stringToList(string):
        "makes a list of words from a string"
        return string.split(" ")

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
                        injectRedis(r, self.textArea)

#main
r = redis.Redis("localhost")
parser = xml.sax.make_parser()
parser.setContentHandler(xHandler())
parser.parse(open("enwiki-latest-pages-articles.xml","r"))

