#!/usr/bin/env python
"""
ugl.games markdown
==================

"""

import markdown
from markdown.util import etree
import re

UG_RE = r'\[!uglgame:(?P<name>.+)\]'

COUNTER = 0

class UGLGamePattern(markdown.inlinepatterns.Pattern):
  def handleMatch(self, m):
    global COUNTER
    d = m.groupdict()
    path = "games/ugl/" + d.get('name') + ".swf"
    name = "uglgame_%d_swf" % COUNTER
    COUNTER += 1
    content = """
<div id="uglgame"></div>
<script>
var gameName = "%s";
</script>
<script src="//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
<script src="http://fserb.com/vault/static/ugl.js"></script>""" % (name)
    return etree.fromstring(content)

class UGLGameExtension(markdown.Extension):
  def extendMarkdown(self, md, md_globals):
    md.inlinePatterns['uglgame'] = UGLGamePattern(UG_RE, md)
    md.registerExtension(self)

if __name__ == "__main__":
  md = markdown.Markdown(extensions=[UGLGameExtension()])
  print(md.convert("hello"))
  print(md.convert("[!uglgame:Amaze]"))
  # print md.convert("&uglgame:Musician;")
