import { readFileSync } from 'fs';

interface Valve {
    name: string;
    flow: number;
    to: number[];
}

let parseLine = function(line: string): Valve {
    const re = /Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)/
    let [_, name, flow, to, ...rest] = re.exec(line);
    return {name, flow: +flow, to: to.split(', ').map(t=>+t)}
} 

const file = readFileSync("test", "utf-8");
const lines = file.split("\n").filter(l=>l.trim() != '').map(parseLine);

console.log(file)
