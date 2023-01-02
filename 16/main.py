from dataclasses import dataclass
from functools import lru_cache, partial
from itertools import permutations
from math import factorial
from multiprocessing import SimpleQueue
from queue import LifoQueue, PriorityQueue
from random import random
import re
from typing import List

@dataclass
class Valve:
    name: str
    flow: int
    to: ["Valve"]

    def __repr__(self):
        return f":{self.name}" # ({self.flow}) -> [{','.join(t.name for t in self.to)}]"
    def __hash__(self):
        return hash(self.name)
    def __eq__(self, other: object) -> bool:
        return self.name == other.name

def load(fname):
    valves = {}
    with open(fname) as f:
        for line in f:
            m = re.match("Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)", line.strip())
            name,flow,to = m.groups()
            valves[name] = Valve(name,int(flow),to.split(', '))
    for valve in valves.values():
        valve.to = [valves[t] for t in valve.to]
    return valves

@lru_cache
def min_distance(s,e):
    q = SimpleQueue() # BFS
    q.put([s]) 
    visited = set([])
    while not q.empty():
        p = q.get()
        n = p[-1]
        visited.add(n)
        #print(p)
        if n == e:
            return len(p)-1
        for v in n.to:
            if v not in visited:
                q.put(p+[v])


def compute_flow(nodes):
    nodes = list(nodes)
    time = 30
    rate = 0
    total = 0
    for prev, node in zip(nodes,nodes[1:]):
        dt = min_distance(prev,node)+1
        if dt > time:
            break
        total += dt*rate
        rate += node.flow
        time -= dt
        #print(node, dt, rate, total, time)
    
    total += time*rate
    return total

def find_max_reward_path(start):
    valves_with_flow = [v for v in valves.values() if v.flow > 0]
    best_flow = 0
    total = factorial(len(valves_with_flow))
    from tqdm import tqdm
    for rest in tqdm(permutations(valves_with_flow), total=total):
        p = [start, *rest]
        flow = compute_flow(p)
        if flow > best_flow:
            best_flow = flow
            print(best_flow, p)
    return best_flow        

    #return max(map(compute_flow,([start,*rest] for rest in permutations(valves_with_flow))))


valves = load("test")
print(find_max_reward_path(valves["AA"]))

#test_path = get_valves(c+c for c in "ADBJHEC")
#test_path_2 = get_valves(c+c for c in "ABJDHFEC")
#print(compute_flow(test_path))
