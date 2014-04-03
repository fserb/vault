#!/usr/bin/python

import sys
import math
import bitstring

import Image
import ImageFont
import ImageDraw

first = " "
last = "~"
width = 6
height = 8
fontsize = 8
font = ImageFont.truetype(sys.argv[1], fontsize)

txt = ""
for i in range(ord(first), ord(last) + 1):
  txt += chr(i)

im = Image.new("RGB", (len(txt)*width, height))
draw = ImageDraw.Draw(im)

for i,c in enumerate(txt):
  s = font.getsize(c)
  x = 0
  draw.text((i*width + x,-3), c, font=font)

im.save("x.png")

print "Range: %d(%s) - %d(%s)" % (ord(first), first, ord(last), last)
print

print "FONTWIDTH = %d" % width
print "FONTHEIGHT = %d" % height
print "FONTDATA = ["
d = "  "

for i in range(ord(first), ord(last) + 1):
  seq = []
  idx = i - ord(first)

  for y in range(height):
    for x in range(idx*width, (idx+1)*width):
      v = False if im.getpixel((x, y)) == (0,0,0) else True
      seq.append(v)

  seq.extend([False]*(64 - len(seq)))

  bs = str(bitstring.BitArray(seq))[2:]
  f, s = bs[:8], bs[8:]
  # s += "0"*(8-len(s))
  ap = "0x%s, 0x%s, " % (f, s)

  if len(d) + len(ap) >= 80:
    print d
    d = "  "
  d += ap

print d
print "]"

