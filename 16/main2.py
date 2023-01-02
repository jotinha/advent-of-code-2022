from collections import defaultdict, deque
from functools import lru_cache
from itertools import combinations
from queue import SimpleQueue
import re

def load(fname):
    conns = {}
    rates = {}
    with open(fname) as f:
        for line in f:
            m = re.match("Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)", line.strip())
            name,flow,to = m.groups()
            flow = int(flow)
            to = to.split(', ')
            
            conns[name] = to
            if flow > 0:
                rates[name] = flow
    return conns, rates

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
        for v in conns[n]:
            if v not in visited:
                q.put(p+[v])

def compute_min_distances(nodes):
    dists = defaultdict(dict)
    for a,b in combinations(nodes,2):
        dists[a][b] = dists[b][a] = min_distance(a,b)
    return dists

def upper_bound_0(*args):
    return 1e10

def upper_bound_1(valve, closed, rates, time):
    return sum(rates[c] for c in closed)*time

def upper_bound_2(valve, closed, rates, time):
    return sum(sorted((rates[c] for c in closed), reverse=True)[:time//2])*time

def upper_bound_3(valve, closed, rates, time):
    rates = sorted([rates[c] for c in closed], reverse=True)
    total = 0
    dt = 2
    for r in rates:
        time = time-dt
        if time <= 0: break
        total = total + r*time
    return total
    

upper_bound = upper_bound_3

def compute_solutions(dists,flow_rates, time):
    # solutions is a dictionary {set of open valves: greatest pressure achievable}
    solutions = defaultdict(int)
    # node = position, time left, open valves, pressure
    valves = frozenset(flow_rates.keys())
    
    start = "AA", time, frozenset(),0
    
    todo = deque([start])
    # {(position, open valves) : pressure}
    visited = defaultdict(int)

    it = 0
    while todo:
        it += 1
        valve, time, open, pressure = todo.pop()

        # store even if not finished because in part2 will need non intersecting solutions
        # which wouldn't be considered otherwise
        solutions[open] = max(solutions[open], pressure)

        # move to every possible other valve and open it
        # closed = valves - open
        for new_valve in dists[valve]:
            if new_valve in open:
                continue
            new_open = open | {new_valve}
            new_time = time - dists[valve][new_valve] - 1
            new_pressure = pressure + new_time * flow_rates[new_valve]
            # computing upper bound makes it use less iterations but it's actually slower
            # ub = new_pressure + upper_bound(new_valve, closed - {new_valve}, rates, new_time) 
            
            # discard if no time left or state already visited with higher pressure
            # where state is current valve and set of open valves
            if new_time > 0 and new_pressure > visited[(new := (new_valve, new_open))]:# and ub > solutions[new_open]:
                visited[new] = new_pressure
                todo.append((new_valve, new_time, new_open, new_pressure))
    print(it, "iterations")
    return solutions

def solve2(dists, rates):
    # basically the two agents are independent because they open different valves.
    # Compute solution for single agent with 26 minutes then just take the max
    # possible sum of the two pressures achieved independently by the agents
    solutions = compute_solutions(dists, rates, 26)
    return max(solutions[s1] + solutions[s2]
        for s1,s2 in combinations(solutions, 2)
            if s1.isdisjoint(s2)
    )
    
    

conns, rates = load("input")
dists = compute_min_distances(list(rates.keys()))
dists['AA'] = {k:min_distance('AA',k) for k in rates.keys()}
solutions = compute_solutions(dists,rates, 30)
print(solutions)
ans1 = max(solutions.values())
ans2 = solve2(dists, rates)
print(ans1,',',ans2)