import { readFileSync } from 'fs';

interface Valve {
    name: string;
    flow: number;
    to: string[];
}

interface State {
    valve: string;
    time: number;
    open: number, 
    pressure: number;
}

interface VisitedState {
    open: number; 
    current: string;
}


//n must be between 1 and 31 
let tobit = (n : number) => 1 << n;
let set_from = (xs: number[]) : number => xs.reduce(set_add, 0);
let set_add = (s: number, n: number) => s | tobit(n);
let set_has = (s: number, n: number) => (s & tobit(n)) != 0;
let set_isdisjoint = (a: number, b:number) => (a & b) == 0;

(function test_sets() {
    let s = set_from([1,2,3,31]); 
    if (
        set_has(s,2) && 
        set_has(s,31) && 
        !set_has(s, 5) && 
        set_has(set_add(s,10),10) &&
        !set_has(s,10)
    ) return;
    throw "tests failed";
})();

let parseLine = function(line: string): Valve {
    const re = /Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)/
    let [_, name, flow, to, ...rest] = re.exec(line)!;
    return {name, flow: +flow, to: to.split(', ')}
} 

let min_distance = function() {
    
    let cache : {[k:string]:number} = {}; 
 
    let compute = function(s: string, e: string) : number {
        let q = [[s]]; 
        let visited : Set<string> = new Set();

        while (q.length > 0) {
            let p = q.shift()!; // BFS, it only gives shortest path for unweighted graphs
            let n = p[p.length -1];
            visited.add(n);
            if (n === e) { 
                return p.length -1;
            }
            neighbors(n).filter(v => !visited.has(v)).forEach(v => q.push(p.concat(v)));
        }
        return -1;
    }
    return function(s: string, e: string) : number {
        let key = s>e ? e+s : s+e 
        return cache[key] ?? (cache[key] = compute(s,e));
    } 
}();

let neighbors = function(s: string): string[] {
    return valves[s].to
}

let union = function<T>(a: Set<T>, b: Set<T>) : Set<T> { return new Set([...a,...b]) };

let find_max_rewards = function(time: number) : Map<number,number> {
     
    let valves_with_flow = Object.entries(valves).filter(([k,v]) => v.flow > 0).map(([k,v]) => k)   
    let ids = Object.fromEntries(valves_with_flow.map((v,i) => [v,i+1])) // maps name to unique code
    let start : State = {valve: "AA", time, open: 0, pressure:0}
    let q = [start];
    
    //solutions is a map of open nodes to the pressure they can release for time iterations

    let solutions : Map<number,number> = new Map(); 

    let visited : Map<string,number> = new Map(); 
    let it = 0;
    
    while (q.length > 0) {
        it += 1
        //if (it % 10_000 == 0) 
        //    console.log(it, solutions.size, Math.max(...solutions.values()));
   
        let s = q.pop()!;
        
        if (s.pressure > (solutions.get(s.open) ?? 0))
            solutions.set(s.open, s.pressure);
        
        valves_with_flow.forEach(v => {
            if (set_has(s.open,ids[v])) return;
            //if (valves[v].flow == 0) return;
            let d = min_distance(s.valve, v);
            let new_time = s.time - d - 1;
            
            if (new_time < 0) return;

            let sn : State = {
                valve: v,
                time: new_time,
                pressure: s.pressure + new_time * valves[v].flow,
                open: set_add(s.open, ids[v]!) 
            };
           
            //creates a key for the visited map that is the stringification of the set open and
            //the current valve name (e.g. 63AA)
            let vs = sn.open + sn.valve; 
            if (sn.pressure > (visited.get(vs) ?? 0)) {
                visited.set(vs, sn.pressure);
                q.push(sn);
            }
        })
        //throw "die";
    } 
    //console.log(it, "iterations");
    //console.log(solutions.size, "solutions");
    return solutions;
}

let solve1 = function(): number {
    let solutions = find_max_rewards(30);
    return Math.max(...solutions.values());
}

let solve2 = function(): number {
    let solutions = find_max_rewards(26);
    let pressure = 0;
    for (let [s1,p1] of solutions) {
        for (let [s2,p2] of solutions) {
            if (set_isdisjoint(s1,s2) && (p1 + p2) > pressure) {
                pressure = p1 + p2;
            }
        }
    }
    return pressure;
}

const file = readFileSync("input", "utf-8");
const valves = Object.fromEntries(
    file.split("\n").filter(l=>l.trim() != '').map(parseLine).map(v => [v.name, v]))

let ans1 = solve1();
let ans2 = solve2();
console.log(`${ans1},${ans2}`);
