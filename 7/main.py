from dataclasses import dataclass

@dataclass
class Dir:
    name: str
    parent: "Dir" = None
    children: ["Dir"] = None 
    own_size: int = 0

    def add_child(self, c: "Dir"):
        self.children.append(c)

    @property
    def total_size(self):
        return self.own_size + sum(c.total_size for c in self.children) 

    def walk(self):
        for c in self.children:
            yield c
            yield from c.walk()

root = cwd = Dir("root", None, [])

for line in open("input"): 
    # print(line, cwd)
    match line.split():
        case ["$", "cd", ".."]:
            cwd = cwd.parent
        case ["$", "cd", name]:
            cwd_ = Dir(name, cwd, [])
            cwd.add_child(cwd_)
            cwd = cwd_
        case ["$", "ls"]:
            pass
        case ["dir", _]:
            pass
        case [size, _]:
            cwd.own_size += int(size)

ans1 = sum(filter(lambda s: s < 100_000, map(lambda d: d.total_size, root.walk())))
ans2 = "TODO"

print(f"{ans1},{ans2}")
        

