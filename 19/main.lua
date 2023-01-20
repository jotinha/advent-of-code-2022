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
  local matches = string.gmatch(s,"([0-9]+)")
  local m = function() return tonumber(matches()) end
  local idx = m()
  return {
    {m(),0,0,0},
    {m(),0,0,0},
    {m(),m(),0,0},
    {m(), 0, m(),0}
  }
end

function clone_amounts(a)
  local b = { }
  local i
  for k=1,4 do b[k] = a[k] end
  return b  
end

  
function clone_state(state)
  return {robots=clone_amounts(state.robots),
      minerals=clone_amounts(state.minerals),
      time=state.time}
end

function next_state(state, i, bp)
  local j
  local new_state = clone_state(state) 

  new_state.time = new_state.time - 1
  if i > 0 then -- i = 0 means just wait
    for j=1,4 do
      -- consume minerals according to blueprint 
      new_state.minerals[j] = new_state.minerals[j] - bp[i][j]
     -- this may lead to invalid states, because we need to have enough minerals at the start of the round
      if new_state.minerals[j] < 0 then
        return nil  
        --new_state.invalid = true
      end 
   end
   -- create robot
   new_state.robots[i] = new_state.robots[i] + 1
   
  end
  for j=1,4 do
      -- harvest 
      new_state.minerals[j] = new_state.minerals[j] + state.robots[j]
  end
  
  return new_state
end

function no_negatives(t)
  for k,v in pairs(t) do
    if v < 0 then return false end
  end
  return true
end

function is_valid(state)
  return (state.time >= 0) and no_negatives(state.minerals)
end

function max_of_mineral_needed_to_build_anything(mineral_i, bp)
  local i
  local m = 0
  for i=1,4 do
    m = math.max(m,bp[i][mineral_i])
  end
  return m
end

function is_useful(move,state, bp)  
  if (move > 0 and state.time <= 1) then return false end -- no point in building

  -- always useful to build geodes
  if (move==4) then return true end 
 
   -- if we build ore/obsidian at -3 we wont have time to harvest extra geode
  if ((move==1 or move==3) and state.time <= 3) then return false end

  -- build clay at -5,harvest clay at -4, build obsidian at -3, harvest at -2, build geode at -1, can't harvest
  if (move == 2 and state.time <=5) then return false end

  if (move > 0) then
    local m = max_of_mineral_needed_to_build_anything(move,bp) 
    
    -- we dont need a move that make a robot if we have enough of that robot to replentish the mineral everytime
    if state.robots[move] >= m then return false end 

    -- we don't need to make a robot if we can't possibly spend the mineral we have/will have until the end
    -- FIXME this condition doesn't work well
    --if amount_until_end(state, move) > m then return false end 
  end
  return true
end

function amount_until_end(state, t)
  return state.minerals[t] + state.robots[t]*state.time
end

function score(state)
  return amount_until_end(state,4)
end

function upper_bound(state)
  return score(state) + state.time*(state.time -1) //2
end

function show_amounts(name,t)
  local i
  io.write(name..": ")
  for i=1,4 do
    io.write(t[i]..",")
  end
  io.write("\n")
end
function show_state(state)
  if state.invalid then print("INVALID") end
  show_amounts("robots",state.robots)
  show_amounts("minerals", state.minerals)
  print("time left: ", state.time) 
end

function improves_previously_seen(closed, state, score)
  local rs = state.robots[1]..','..  state.robots[2]..','..  state.robots[3]..','..  state.robots[4]..","..
           state.minerals[1]..','..state.minerals[2]..','..state.minerals[3]..','..state.minerals[4]
  
  score = state.time  
 
  if (closed[rs] == nil) then
    closed[rs] = score
    closed.size = closed.size + 1
    return true
  elseif (score > closed[rs]) then
    closed[rs] = score
    return true
  else
    return false
  end
end

function solve(bp, t)
  local start_state = {robots={1,0,0,0}, minerals={0,0,0,0}, time=t}
  local open = {start_state}
  local best = 0
  local move
  local it = 0;
  local closed = {size=0}
  
  while #open > 0 do
    it = it +1
 
    local state = table.remove(open)
    local s = score(state)
    best = math.max(best, s) 
    --[[if s > best then
      show_state(state)
      print("score:", s)
      best = s
    end]]

    if (it % 100000 == 0) then 
      --print(it,#open, closed.size, state.time, best) 
      --show_state(state)
      --print("score", s)
    end
    --if (it > 20000000) then break end
    -- 
    if state.time > 0 and upper_bound(state) >= best and improves_previously_seen(closed, state, s) then
        --show_state(state)
        for move = 0,4 do
          local next = next_state(state, move, bp)
          if next ~= nil then
            --print("doing move "..move)
            --show_state(next)
            if is_useful(move,state,bp) then
              table.insert(open, next) 
            end
          else
            --[[if move == 2 then
              print("\ncan't do move ".. move)
              show_state(state)
              print("to")
              show_state(next)
              print("")
            end]]
          end 
        end
      end 
      --break
    end
    print("Found best result ("..best..") in "..it.." iterations")
    return best
end

function show_blueprint(bp)
  local i
  print("blueprint")
  for i=1,4 do
    show_amounts("\t"..i,bp[i])
  end 
end

bps = read_blueprints("input") 
--show_blueprint(bps[2])
--solve(bps[2],24)
bps2 = {}; for k=1,3 do bps2[k] = bps[k] end
ans1 = 0 -- solve(bps[3],32) 
ans2 = 1
for k,bp in pairs(bps) do
  ans1 = ans1 + k*solve(bp,24)
  if k >= 1 and k <= 3 then
    ans2 = ans2*solve(bp,32)
  end
end
print(ans1..","..ans2)

