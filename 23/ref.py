from collections import defaultdict
from itertools import islice
from tqdm import trange

elves = set()
for i,line in enumerate(open("input")):
   for j, c in enumerate(line):
      if c == '#':
         elves.add((i,j))
#print(elves)         

def neighbors(pos): 
   i,j = pos
   return [
      [(i-1, j-1), (i-1, j), (i-1, j+1)],
      [(i+1, j-1), (i+1, j), (i+1, j+1)],
      [(i-1, j-1), (i, j-1), (i+1, j-1)],
      [(i-1, j+1), (i, j+1), (i+1, j+1)],
   ]

def are_empty(positions, state):
   return not state.intersection(positions)

def next(state, order):
   candidates = defaultdict( lambda : []) # key is destination, value is list of origin points
   new_state = set()
   for i,j in state:
      dirs = n,s,w,e = neighbors((i,j))
      if are_empty(n + s + w + e, state):
         new_state.add((i,j)) # no move
      else:
         for o in order:
            d = dirs[o]
            if are_empty(d, state):
               candidates[d[1]].append((i,j))
               break
         else:
            new_state.add((i,j)) # no move
   
   for p, ps in candidates.items():
      if len(ps) == 1:
         new_state.add(p) # accept proposal
      else:
         for pp in ps: # reject proposal by putting back the originals
            new_state.add(pp)

   return new_state

def map_range(state):
   rows,cols = zip(*state)
   return range(min(rows), max(rows)+1), range(min(cols), max(cols)+1)

def draw(state):
   rows,cols = zip(*state)
   for i in range(min(rows)-1, max(rows)+2):
      for j in range(min(cols)-1, max(cols)+2):
         print("#" if (i, j) in state else '.', end="")
      print("")
   print("")

def score(state):
   ry,rx = map_range(state)
   return len(ry)*len(rx) - len(state)

def solve1():
   order = [0, 1, 2, 3]
   state = elves
   for _ in range(10):
      state = next(state, order)
      order.append(order.pop(0))
   return score(state)

def solve2():
   order = [0, 1, 2, 3]
   state = elves
   for i in trange(1000):
      new_state = next(state, order)
      if new_state == state:
         return i +1
      else:
         state = new_state
      order.append(order.pop(0))
   return "can't find answer before max iterations"

ans1 = solve1()
ans2 = solve2()
print(f"{ans1},{ans2}")   