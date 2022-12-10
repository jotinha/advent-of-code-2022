from collections import defaultdict

def parent(wd): 
    return wd[:-1]
def child(wd, name): 
    return (*wd, name)
def parents(d): 
    while d := parent(d): 
        yield d

sizes = defaultdict(lambda : 0)   
cwd = ()

for line in open("input"): 
    # print(line, cwd)
    match line.split():
        case ["$", "cd", ".."]: 
            cwd = cwd[:-1]
            #cwd = cwd.parent
        case ["$", "cd", name]:
            cwd = (*cwd, name)
        case ["$", "ls"]:
            pass
        case ["dir", _]:
            pass
        case [size, _]:
            size = int(size)
            sizes[cwd] += size # update own size
            for d in parents(cwd): # update parents as well
                sizes[d] += size

ans1 = sum(s for s in sizes.values() if s < 100_000)
ans2 = "TODO"

print(f"{ans1},{ans2}")
        

