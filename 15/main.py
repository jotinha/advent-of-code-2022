import re
from collections import namedtuple
from itertools import * 

PointXY = namedtuple("PointXY", "x y")
Area = namedtuple("Area", "x y d")

def parse(fname):
    for line in open(fname):
        x1,y1,x2,y2 = map(int,re.findall("-?[0-9]+",line))
        yield (PointXY(x1,y1),PointXY(x2,y2))

def dist(a,b): 
    return abs(b.x-a.x) + abs(b.y-a.y)

def makearea(pair):
    s,b = pair
    return Area(s.x,s.y,dist(s,b))

def facestouchw(a,b):
    w = a.x-a.y + a.d + 1
    if w == (b.x-b.y-b.d-1):
        assert w != 0
        return w 

def facestouchz(a,b):
    z = (a.x+a.y+a.d+1) 
    if z == (a.x+a.y-b.d-1):
        assert z != 0
        return z

def inside(p,a):
    return dist(p,PointXY(a.x,a.y))<=a.d

def outside(p,a):
    return not inside(p,a)

points = list(parse("input"))
  
areas = list(map(makearea,points))

linesw = []
linesz = []

for a in areas:
    linesz.append(a.x+a.y+a.d+1)
    linesz.append(a.x+a.y-a.d-1)
    linesw.append(a.x-a.y+a.d+1)
    linesw.append(a.x-a.y-a.d-1)

limit = 4_000_000

def calc_freq(p):
    return p.x*limit + p.y

ps = set()
for i,(z,w) in enumerate(product(linesz,linesw)):
    p = PointXY((z+w)//2,(z-w)//2)
    if p in ps:
        continue
    ps.add(p)
    if all(outside(p,a) for a in areas ) and \
       (0 <= p.x <= 4_000_000) and ( 0 <= p.y <= 4_000_000): 
       print(calc_freq(p))  

print("Done")    
