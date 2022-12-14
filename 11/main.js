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
        items: m[2].split(',').map(x => parseInt(x)),
        operation: m[3],
        by: parseInt(m[4]) || 'old',
        divisible: parseInt(m[5]),
        trueTo: parseInt(m[6]),
        falseTo: parseInt(m[7])
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
            console.log(`${worry}->${newWorry}->${newWorry2} to monkey ${sendTo}`);
            monkeys[sendTo].items.push(newWorry2)
        })
        m.items = [] // monkey sent everything
    })
    
}

function printItems(monkeys) {
    monkeys.forEach((m,i) => console.log(`${i}: ${m.items}`))
}

let monkeys = [...data.matchAll(pattern)].map(makeMonkey)
round(monkeys);
printItems(monkeys)
