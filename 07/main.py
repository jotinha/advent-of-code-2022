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
    #print(cwd)
    match line.split():
        case ["$", "cd", ".."]: 
            cwd = parent(cwd) 
        case ["$", "cd", name]:
            cwd = child(cwd, name)
        case ["$", "ls"]:
            pass
        case ["dir", _]:
            pass
        case [size, _]:
            size = int(size)
            sizes[cwd] += size # update own size
            for d in parents(cwd): # update parents as well
                sizes[d] += size

used_size = sizes[("/",)] 
disk_size = 70_000_000
need_size = 30_000_000

ans1 = sum(s for s in sizes.values() if s < 100_000)
ans2 = min(s for s in sizes.values() if s > need_size - (disk_size - used_size))
print(f"{ans1},{ans2}")
        

