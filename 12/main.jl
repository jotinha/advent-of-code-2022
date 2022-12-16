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

function neighbors(hmap, a, dir)
    return filter(ij -> dir == "fwd" ? canjump(hmap, a, ij) : canjump(hmap, ij, a),
           map(ij -> a + CartesianIndex(ij),
           [(-1,0),(1,0),(0,1),(0,-1)]))
end

function findpath(hmap, start, endcond; dir = "fwd")
    q = [start]
    parents = Dict()

    notvisited(n) = !haskey(parents,n)
  
    while !endcond(local a = pop!(q))
        for b = neighbors(hmap, a, dir)
            if notvisited(b)
                parents[b] = a;
                pushfirst!(q,b) # Breadth first, push! for depth first
            end
        end
    end
    
    path(a, b) = a == b ? [] : [path(a, parents[b]); b] # reconstruct path
    path(start, a) 
end


path1 = findpath(hmap, startpos, ij -> isend(hmap[ij]))
path2 = findpath(hmap, endpos, ij -> hmap[ij] == Int('a'), dir="bwd")

fmt(ij:: CartesianIndex) = "($(ij[1]),$(ij[2]))"
#println(fmt(startpos),"->",fmt(endpos))
#map(println∘fmt,path1)

ans1 = length(path1)
ans2 = length(path2) 
println("$ans1,$ans2")

