const fs = require('fs');
const data = fs.readFileSync('input','utf-8');

const pattern = /Monkey (\d+):\s+Starting items: (.*)\s+Operation: new = old ([-+*\/]) (\d+|old)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d+)\s+If false: throw to monkey (\d+)/gm

function makeMonkey(m, i) {
    idx = parseInt(m[1])
    if (idx != i) {
        throw(`Expected index ${i}, got ${idx}. This means an earlier monkey failed to match the regex`)
    }

    return {
        idx: idx,
        items: m[2].split(',').map(x => {return {val: parseInt(x)}} ),
        operation: m[3],
        by: parseInt(m[4]) || 'old',
        divisible: parseInt(m[5]),
        trueTo: parseInt(m[6]),
        falseTo: parseInt(m[7]),
        inspected: 0,
    }    
}
function updateWorry(old, operation, by) {
    switch (operation) {
        case '*':
            return old * by;
        case '+':
            return old + by;
        default:
            throw(`Invalid operation: ${operation}`)
    }
}
function computeRests(x, maxm) {
    return [...Array(maxm+1).keys()].map(m => x % m)
}

function isDivisible(item, d) {
    return item.rests[d] == 0;
}

function round(monkeys, divideBy3) {
    monkeys.forEach(m => {
        m.items.forEach(item => {
            item.val = updateWorry(item.val, m.operation, m.by == 'old' ? item.val : m.by);
            if (divideBy3)
                item.val = Math.floor(item.val/3);
            
            // to avoid issues with large numbers we can simply keep all possible rest values
            item.rests = item.rests.map((r,d) => 
                updateWorry(r % d, m.operation, (m.by == 'old' ? r : m.by) % d) % d)
            
            let sendTo = isDivisible(item, m.divisible) ? m.trueTo : m.falseTo
            monkeys[sendTo].items.push(item)
        })
        m.inspected += m.items.length;
        m.items = [] // monkey sent everything
    })
    
}

function printItems(monkeys) {
    monkeys.forEach((m,i) => console.log(`${i}: ${m.items.map(x=>x.val)} ${m.items.map(x => x.rests[m.divisible])} (inspected ${m.inspected} total)`))
}

let monkeys = [...data.matchAll(pattern)].map(makeMonkey)
let max_d = monkeys.map(m => m.divisible).sort().slice(-1)[0];
monkeys.forEach(m => m.items.forEach(item => {item.rests = computeRests(item.val, max_d)}))

for (let i=10000; i--;) round(monkeys, false);
printItems(monkeys)

let totals = monkeys.map(m => m.inspected).sort((a,b) => b-a); // sort desc
console.log(totals)
let ans1 = totals[0]*totals[1] 
let ans2 = "TODO"
console.log(`${ans1},${ans2}`);
