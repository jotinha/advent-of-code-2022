const fs = require('fs');
const data = fs.readFileSync('input','utf-8');

function initMonkeys(data) {
    const pattern = /Monkey (\d+):\s+Starting items: (.*)\s+Operation: new = old ([-+*\/]) (\d+|old)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d+)\s+If false: throw to monkey (\d+)/gm

    let monkeys = [...data.matchAll(pattern)].map(parseMonkey)
    
    // initialize rests array
    let max_d = max(monkeys.map(m => m.divisible));
    monkeys.forEach(m => m.items.forEach(item => {item.rests = computeRests(item.val, max_d)}))
    
    return monkeys
}

function parseMonkey(m, i) {
    let idx = parseInt(m[1])
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

function operate(a, operation, b) {
    if (b == 'old') b = a;
    switch (operation) {
        case '*':
            return a * b;
        case '+':
            return a + b;
        default:
            throw(`Invalid operation: ${operation}`)
    }
}

function computeRests(x, maxm) {
    return [...Array(maxm+1).keys()].map(m => x % m )
}

function round(monkeys, divideBy3) {
    monkeys.forEach(m => {
        m.items.forEach(item => {
            item.val = operate(item.val, m.operation, m.by);
           
            // to avoid issues with large numbers we can simply keep operate on the rest values over all divisors
            item.rests = item.rests.map((r,d) => operate(r, m.operation, m.by) % d)

            var isDivisible
            if (divideBy3) {
                item.val = Math.floor(item.val/3);
                isDivisible = item.val % m.divisible == 0
            } else {
                isDivisible = item.rests[m.divisible] == 0
            }
            
            let sendTo = isDivisible ? m.trueTo : m.falseTo
            monkeys[sendTo].items.push(item)
            m.inspected += 1;
        })
        m.items = [] // monkey sent everything
    })
    
}


function max(xs,n,key) {
    let s = [...xs].sort((a,b) => b-a)
    return n === undefined ? s[0] : s.slice(0,n);
}

var monkeys, i1,i2 

// do monkey business part I
monkeys = initMonkeys(data); 
for (let i=20; i--;) round(monkeys, true);
[i1,i2] = max(monkeys.map(m => m.inspected),2)
let ans1 = i1*i2;

// do monkey business part II
monkeys = initMonkeys(data); 
for (let i=10000; i--;) round(monkeys, false);
[i1,i2] = max(monkeys.map(m => m.inspected),2)
let ans2 = i1*i2;

console.log(`${ans1},${ans2}`);
