from tqdm import trange

ns = list(map(int,open("input").readlines()))
idxs = list(range(len(ns)))

ns2 = [i*811589153 for i in ns]
idxs2 = list(range(len(ns2)))

def mix(ns, indices):
    for it in range(len(ns)):
        i = indices.index(it)
        val = ns.pop(i)
        i2 = (i + val) % len(ns)
        ns.insert(i2,val)
        indices.insert(i2,indices.pop(i))

def get_grooves(ns):
    return [ns[(ns.index(0) + x) % len(ns)] for x in (1000,2000,3000)]

mix(ns,idxs)
ans1 = sum(get_grooves(ns))

for _ in trange(10):
    mix(ns2,idxs2)

ans2 = sum(get_grooves(ns2))
print(ans1,ans2)
