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
        --return nil  
        new_state.invalid = true
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

function is_useful(move,state, bp)
  return is_valid(state) and 
         not (move == 0 and state.time <= 1) and -- no point building if we wont have time to harvest
         not ((move==1 or move==3) and state.time <= 3) and -- if we build ore/obsidian at -3 we wont have time to harvest extra geode
         (move == 0 or robot_is_worth_building(move, state, bp))
end

function robot_is_worth_building(move, state, bp)
  if move == 4 then return true end -- could always use a geode robot it we can make it
  
  -- we don't need to make a robot if we have enough robots to replentish that material for any move
  -- TODO
  return true
end        

function score(state)
  return state.minerals[4] + state.robots[4]*state.time
end

function max(a,b)
  if a > b then return a else return b end
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

function solve(bp, t)
  local start_state = {robots={1,0,0,0}, minerals={0,0,0,0}, time=t}
  local open = {start_state}
  local best = 0
  local move
  local it = 0;
  
  while #open > 0 do
    it = it +1
 
    local state = table.remove(open)
    local s = score(state)
    best = max(best, s) 
    --[[if s > best then
      show_state(state)
      print("score:", s)
      best = s
    end]]

    if (it % 100000 == 0) then 
      print(it,#open, state.time, best) 
      --show_state(state)
      --print("score", s)
    end
    --if (it > 20000000) then break end

    if state.time > 0 and upper_bound(state) > best then 
        --show_state(state)
        for move = 0,4 do
          local next = next_state(state, move, bp)
          --if is_useful(move,next,bp) then
          --if is_valid(next) then
          if not next.invalid then
            --print("doing move "..move)
            --show_state(next)
            table.insert(open, next) 
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

bps = read_blueprints("test") 
show_blueprint(bps[1])
solve(bps[1],24)

