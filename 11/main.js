const fs = require('fs');
const data = fs.readFileSync('test','utf-8');

const pattern = /Monkey (\d+):\s+Starting items: (.*)\s+Operation: new = old ([-+*\/]) (\d+|old)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d+)\s+If false: throw to monkey (\d+)/gm

function makeMonkey(m, i) {
    idx = parseInt(m[1])
    if (idx != i) {
        throw(`Expected index ${i}, got ${idx}. This means an earlier monkey failed to match the regex`)
    }

    return {
        idx: idx,
        starting: m[2].split(',').map(x => parseInt(x)),
        operation: m[3],
        by: parseInt(m[4]) || 'old',
        divisible: parseInt(m[5]),
        trueTo: parseInt(m[6]),
        falseTo: parseInt(m[7])
    }    
}

let monkeys = [...data.matchAll(pattern)].map(makeMonkey)

console.log(monkeys)
