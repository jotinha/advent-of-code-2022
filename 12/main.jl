lines = readlines("input")
hmap = transpose(hcat([[Int(x) for x = line] for line = lines]...))

isend(c) = c == Int('E')
isstart(c) = c == Int('S')
istallest(c) = c == Int('z') # the node before the end
isshortest(c) = c == Int('a')

startpos = findfirst(isstart, hmap)
endpos = findfirst(isend, hmap)

validpos(hmap, pos) = all(Tuple(pos) .>= (1,1)) && all(Tuple(pos) .<= size(hmap)) 

function canjump(hmap,from,to)
    if !validpos(hmap,to) || !validpos(hmap,from) 
        return false
    elseif isstart(hmap[from]) 
        return isshortest(hmap[to]) # jump from S to a
    elseif isend(hmap[to]) 
        return istallest(hmap[from]) # jump from z to E
    elseif isstart(hmap[to]) 
        return false
    else 
        return (hmap[to] - hmap[from]) <= 1
    end
end

function neighbors(hmap, a)
    return filter(ij -> canjump(hmap, a, ij),
           map(ij -> a + CartesianIndex(ij),
           [(-1,0),(1,0),(0,1),(0,-1)]))
end

function reconstructpath(parents, start, end_) 
    path = [];
    while end_ != start
        push!(path, end_)        
        end_ = parents[end_]
    end
    reverse(path)
end

function findpath(hmap, start, end_)
    q = [start]
    visited = Set()
    parents = Dict()
    while !isempty(q)
        a = pop!(q)
        if a == end_
            return reconstructpath(parents, start, end_) 
        end
        for b = neighbors(hmap, a)
            if !in(b, visited)
                parents[b] = a;
                push!(visited,b)
                push!(q,b) # Depth first
            end
        end
   end
end


path = findpath(hmap, startpos, endpos)

fmt(ij:: CartesianIndex) = "($(ij[1]),$(ij[2]))"
println(fmt(startpos),"->",fmt(endpos))
map(println∘fmt,path)

ans1 = length(path)
ans2 = "TODO"
println("$ans1,$ans2")


