function read_blueprints(fname)
    local file = io.open(fname, "r")
    local lines = file:lines()
    local res = {} 
    for line in lines do
        table.insert(res, parseline(line))
    end
    file:close()
    return res
end

function parseline(s)
    local m = string.gmatch(s,"([0-9]+)")
    return {
        ore={ore=m()},
        clay={ore=m()},
        obsidian={ore=m(),clay=m()},
        geode={ore=m(), obsidian=m()}
    }
end

bps = read_blueprints("test") 
for i,bp in pairs(bps) do 
    print(i,bp)
 end
