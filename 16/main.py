from dataclasses import dataclass
from functools import lru_cache, partial
from itertools import combinations, permutations
from math import factorial
from multiprocessing import SimpleQueue
from queue import LifoQueue, PriorityQueue
from random import random
import re
from typing import List, Set

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


@lru_cache
def global_min_distance(nodes):
    if len(nodes) <= 1: return 0
    return min(min_distance(a,b) for a,b in combinations(nodes,2))

def compute_flow_upper_bound(nodes, time):
    nodes = sorted(nodes, key= lambda x: x.flow, reverse=True)
    dt = global_min_distance(tuple(nodes)) + 1

    total = 0
    for node in nodes:
        time = time-dt
        if time <= 0: break
        total = total + node.flow*time
    return total
    
    
def compute_flow_up_to(nodes):
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
    return total, time, rate

def compute_flow(nodes):
    total, time, rate = compute_flow_up_to(nodes)
    return total + time*rate

@dataclass
class State:
    pressure_relieved : int
    rate: int
    time_left: int
    current: Valve
    path: List[Valve]
    unseen : Set[Valve]

    def __post_init__(self) -> None:
        self._h = hash((self.pressure_relieved, self.rate, self.time_left, self.current,
        tuple(self.path),
        tuple(self.unseen)
        ))

        lower_bound = self.rate*self.time_left
        upper_bound = lower_bound + compute_flow_upper_bound(self.unseen, self.time_left)
       
        self.estimates = (self.pressure_relieved + lower_bound, self.pressure_relieved + upper_bound)
        
    def __hash__(self) -> int:        
        return self._h


def find_max_reward_path(start):
    valves_with_flow = set(v for v in valves.values() if v.flow > 0)
    best = 0
    
    q = LifoQueue() # DFS
    #q = PriorityQueue() 
    #q = LifoQueue() # BFS

    q.put(State(0, 0, 30, start, [], valves_with_flow))

    seen_paths = set()
    
    it = 0
    while not q.empty():
        it += 1
        s : State = q.get()
        
        if s.estimates[0] > best:
            best = s.estimates[0]
            print(it, q.qsize(), best)

        if s.time_left == 0:
            continue
        
        if s.estimates[1] <= best:
            continue
        
        for v in s.unseen:
            sn = next_state(s, v)
            if sn not in seen_paths:
                seen_paths.add(sn)
                q.put(sn)
    print("total iterations: ", it)
    return best

def next_state(state: State, node: Valve) -> State:
    dt = min_distance(state.current, node) + 1
    if dt > state.time_left:
        return State(state.pressure_relieved + state.time_left * state.rate,
                    state.rate,0, state.current , state.path,
                    state.unseen)
    else:
        return State(state.pressure_relieved + dt*state.rate,
                    state.rate + node.flow, state.time_left - dt,
                    node,state.path + [node], state.unseen - {node}) 


valves = load("input")
print(find_max_reward_path(valves["AA"]))

#test_path = get_valves(c+c for c in "ADBJHEC")
#test_path_2 = get_valves(c+c for c in "ABJDHFEC")
#print(compute_flow(test_path))
