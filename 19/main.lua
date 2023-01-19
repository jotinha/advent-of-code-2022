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
  local idx = m()
  return {
    ore={ore=m()},
    clay={ore=m()},
    obsidian={ore=m(),clay=m()},
    geode={ore=m(), obsidian=m()}
  }
end

function clone_amounts(a)
  if a == nil then return nil end

  local b = { }
  for k, v in pairs(a) do b[k] = v end
  return b  
end

  
function clone_state(state)
  return {robots=clone_amounts(state.robots),
      minerals=clone_amounts(state.minerals),
      time=state.time}
end

types = {"ore","clay","obsidian","geode"}

function next_state(state, move_idx, bp)
  local j, ti, tj
  local new_state = clone_state(state) 

  new_state.time = new_state.time - 1

  if move_idx > 0 then -- move_idx = 0 means just wait 
    ti = types[move_idx]
    
    -- create robot
    new_state.robots[ti] = (new_state.robots[ti] or 0) + 1

    for j=1,4 do
      tj = types[j]
      
      -- consume minerals according to blueprint
      if bp[ti][tj] ~= nil then
        new_state.minerals[tj] = (new_state.minerals[types[tj]] or 0) - bp[ti][tj]
      end
    
      -- harvest minerals
      new_state.minerals[tj] = (new_state.minerals[tj] or 0) + (state.robots[tj] or 0)
    end

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
  return (state.time > 0) and no_negatives(state.minerals)
end

function is_useful(move,state, bp)
  return is_valid(state) and 
         not (move == 0 and state.time <= 1) and -- no point building if we wont have time to harvest
         not ((move==1 or move==3) and state.time <= 3) and -- if we build ore/obsidian at -3 we wont have time to harvest extra geode
         (move == 0 or robot_is_worth_building(move, state, bp))
end

function robot_is_worth_building(move, state, bp)
  if move == 4 then return true end -- could always use a geode robot it we can make it
  
  -- we don't need to make a robot if we have enough robots to replentish that material for any move
  local t = types[move]
  -- TODO
  return true
end        

function score(state)
  return (state.minerals.geode or 0) + (state.robots.geode or 0)*state.time
end

function max(a,b)
  if a > b then return a else return b end
end

function upper_bound(state)
  return score(state) + state.time*(state.time -1) //2
end

function show(t)
  for k,v in pairs(t) do
    print("-",k,v)
  end
end
function show_state(state)
  print("robots")
  show(state.robots)
  print("minerals")
  show(state.minerals)
  print("time left: ", state.time) 
end

function solve(bp, t)
  local start_state = {robots={ore=1}, minerals={}, time=t}
  local open = {start_state}
  local best = 0

  local it = 0;
  
  while #open > 0 do
    it = it +1
 
    local state = table.remove(open)
    local s = score(state)
    --best = max(best, s) 
    if s > best then
      show_state(state)
      print("score:", s)
      best = s
    end

    if (it % 100000 == 0) then 
      print(it,#open, state.time, best) 
      --show_state(state)
      --print("score", s)
    end
    --if (it > 20000000) then break end

    if upper_bound(state) > best then 
        for move = 0,4 do 
          local next = next_state(state, move, bp)
          --if is_useful(move,next,bp) then
          if is_valid(next) then
            table.insert(open, next) 
          end
        end
      end 
    end
    print("Found best result ("..best..") in "..it.." iterations")
    return best
end

bps = read_blueprints("test") 
--[[for i,bp in pairs(bps) do 
  print(i,bp)
end]]

solve(bps[1],20)
