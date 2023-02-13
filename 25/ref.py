data = list(map(str.strip,open("input")))

def to_decimal(s):
    match s:
        case '0' | '1' | '2': return int(s)
        case '-': return -1
        case '=': return -2
        case _: return to_decimal(s[-1]) + 5*to_decimal(s[:-1])

def to_base5(d):
   if d == 0: return []
   return to_base5(d // 5) + [d % 5]

def to_base5b(d):
    b = [0] + to_base5(d)
    for j in range(len(b)-1,0,-1):
        match b[j]:
            case 3: 
                b[j] = -2
                b[j-1] += 1
            case 4: 
                b[j] = -1
                b[j-1] += 1 
            case 5:
                b[j] = 0
                b[j-1] += 1
    if b[0] == 0:
        b.pop(0)
    return b

def to_snafu(d):
    b = to_base5b(d)
    return "".join(['0','1','2','=','-'][bb] for bb in b)

print(to_snafu(sum(map(to_decimal,data))))
