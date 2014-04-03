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
    content = """<div class="swf">
<div id="%s">
<b>Need flash to run this :(</b>
</div>
<script>
swfobject.embedSWF("%s", "%s", 480, 480, "11.8");
</script>
</div>""" % (name, path, name)
    return etree.fromstring(content)

class UGLGameExtension(markdown.Extension):
  def extendMarkdown(self, md, md_globals):
    md.inlinePatterns['uglgame'] = UGLGamePattern(UG_RE, md)
    md.registerExtension(self)

if __name__ == "__main__":
  md = markdown.Markdown(extensions=[UGLGameExtension()])
  print md.convert("hello")
  print md.convert("[!uglgame:Amaze]")
  # print md.convert("&uglgame:Musician;")

