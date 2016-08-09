import urllib2
from BeautifulSoup import BeautifulSoup
from sys import argv

opener = urllib2.build_opener()
opener.addheaders = [('User-agent', 'Mozilla/5.0')] #wikipedia needs this
#url = str(argv[1])
url = "https://apollo-community.org/wiki/index.php?title=Example_Paperwork"
resource = opener.open(url)
data = resource.read()
resource.close()
soup = BeautifulSoup(data)
data = soup.find('div',id="mw-content-text")

#Some preprocessing becuase byond is crap with html chars
data_string = str(data)
data_lines = list(data_string.splitlines(True))
i = 0
while i < len(data_lines):
    if '<div class="mw-collapsible-content"><pre>' in data_lines[i]:
        data_lines[i] = "\n--start--\n"

    if "</pre></div></div>" in data_lines[i]:
        data_lines[i] = "\n--stop--"
        
    if "<" in data_lines[i] or ">" in data_lines[i]:
        data_lines[i] = ""
        
    i += 1

data_string = str(" ".join(str(x) for x in data_lines))
text_file = open("scripts/wikiForms.txt", "w")
text_file.write(data_string)
text_file.close()
exit()
