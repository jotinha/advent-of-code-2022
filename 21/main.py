import operator as op
from pprint import pprint
from tqdm import tqdm
from functools import cache
from scipy import optimize as opt

def parse_line(line):
   name,rest = line.split(':')
   
   match rest.strip().split():
      case [str(num)]: rest = [int(num)]
      case [str(a), '+', str(b)]: rest = [op.add, a,b]
      case [str(a), '-', str(b)]: rest = [op.sub, a,b]
      case [str(a), '/', str(b)]: rest = [op.truediv, a,b]
      case [str(a), '*', str(b)]: rest = [op.mul, a,b]
      case _: raise ValueError()
   return name, rest

def parse_all(fname):
   with open(fname) as f:
      return dict(map(parse_line, f))

d = parse_all("input")
#dc = {}

#pprint(d)

@cache
def depends_on_human(word):
   match d[word]:
      case [_]: return False
      case [_, a, b]: return depends_on_human(a) or depends_on_human(b)

def execute_cached(word):
   if word in dc:
      return dc[word]

   res = execute(word)
   if not depends_on_human(word):
      dc[word] = res
   return res

def execute(word):
   match d[word]:
      case [n]: return n
      case [f, str(a), str(b)]: return f(execute(a), execute(b))

ans1 = execute("root")

d["root"][0] = op.sub

def eval2(n):
   d["humn"] = [n]
   return execute("root")

res = opt.root_scalar(eval2, x0=0, x1=10_000)
assert res.converged
ans2 = res.root
print(f"{ans1},{ans2}")      
