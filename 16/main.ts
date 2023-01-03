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


let tobit = (n : number) => 1 << n;
let set_from = (xs: number[]) : number => xs.reduce(set_add, 0);
let set_add = (s: number, n: number) => s | tobit(n);
let set_has = (s: number, n: number) => (s & tobit(n)) != 0;

let s = set_from([1,2,3]); 
if (set_has(s,2) && !set_has(s, 5) && set_has(set_add(s,10),10) && !set_has(s,10)) {
    console.log("ok")
} else {
    throw Error("tests failed");
}

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

let find_max_reward = function(time: number) : number {
     
    let valves_with_flow = Object.entries(valves).filter(([k,v]) => v.flow > 0).map(([k,v]) => k)   
    let ids = Object.fromEntries(valves_with_flow.map((v,i) => [v,i])) // maps name to unique code
    console.log(ids);
 
    let start : State = {valve: "AA", time, open: 0, pressure:0}
    let q = [start];
    
    //solutions is a map of open nodes to the pressure they can release for time iterations
    let solutions : Map<number,number> = new Map(); 

    let visited : Map<string,number> = new Map(); 
    let it = 0;
    
    while (q.length > 0) {
        it += 1
        if (it % 10_000 == 0) 
            console.log(it, solutions.size, Math.max(...solutions.values()));
   
        let s = q.pop()!;
        
        if (s.pressure > (solutions.get(s.open) ?? 0))
            solutions.set(s.open, s.pressure);
        
        valves_with_flow.forEach(v => {
            if (set_has(s.open,ids[v])) return;
            //if (valves[v].flow == 0) return;
            let d = min_distance(s.valve, v);
            let new_time = s.time - d - 1;

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
    } 
    console.log(it, "iterations");
    return Math.max(...solutions.values());

}

const file = readFileSync("input", "utf-8");
const valves = Object.fromEntries(
    file.split("\n").filter(l=>l.trim() != '').map(parseLine).map(v => [v.name, v]))

let ans1 = find_max_reward(30)
let ans2 = 0;
console.log(`${ans1},${ans2}`);
//console.log(min_distance("AA","BB"), 1)
//console.log(min_distance("GG","JJ"), 6)
