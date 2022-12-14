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
        items: m[2].split(',').map(x => parseInt(x)),
        operation: m[3],
        by: parseInt(m[4]) || 'old',
        divisible: parseInt(m[5]),
        trueTo: parseInt(m[6]),
        falseTo: parseInt(m[7]),
        inspected: 0
    }    
}
function updateWorry(old, operation, by) {
    by = by == 'old' ? old : by
    switch (operation) {
        case '*':
            return old * by;
        case '+':
            return old + by;
        case '-':
            return old - by;
        case '/':
            return old / by;
        default:
            throw(`Invalid operation: ${operation}`)
    }
}

function round(monkeys) {
    monkeys.forEach(m => {
        m.items.forEach(worry => {
            newWorry = updateWorry(worry, m.operation, m.by);
            newWorry2 = Math.floor(newWorry/3);
            sendTo = newWorry2 % m.divisible == 0 ? m.trueTo : m.falseTo
            //console.log(`${worry}->${newWorry}->${newWorry2} to monkey ${sendTo}`);
            monkeys[sendTo].items.push(newWorry2)
        })
        m.inspected += m.items.length;
        m.items = [] // monkey sent everything
    })
    
}

function printItems(monkeys) {
    monkeys.forEach((m,i) => console.log(`${i}: ${m.items} (inspected ${m.inspected} total)`))
}

let monkeys = [...data.matchAll(pattern)].map(makeMonkey)

for (let i=20; i--;) round(monkeys);
printItems(monkeys)

let [i1,i2] = monkeys.map(m => m.inspected).sort((a,b) => b-a); // sort desc

let ans1 = i1*i2
let ans2 = "TODO"
console.log(`${ans1},${ans2}`);
