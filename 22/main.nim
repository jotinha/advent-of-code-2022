import std/strutils
import std/re
import std/math
import std/strformat
import std/sequtils


const
   fname = "input"

type
   Vec3 = array[3, float] 
   State = object
      pos: Vec3 # our position in the world
      fwd: Vec3 # where we're looking at
      up: Vec3 # where up is, same as the normal of the face of the map we're at
               # for the first puzzle, the world is flat so this is always +y

   Face = object
      n: Vec3 # normal
      u: Vec3 # the right direction of face in the texture map
      v: Vec3 # the down direction of the face in the texture map
      row0, col0: int # texture coords
      width, height: int

   CubeWorld = object
      faces: array[6, Face]

   FlatWorld = object
      face: Face

   World = CubeWorld | FlatWorld

func face(n,u,v:Vec3,r,c:int, w,h: int): Face =
   Face(n:n, u:u, v:v, row0:r, col0:c, width: w, height: h)

const
   x: Vec3 = [1.0, 0.0, 0.0]
   y: Vec3 = [0.0, 1.0, 0.0]
   z: Vec3 = [0.0, 0.0, 1.0]

let
   lines = readFile(fname).splitLines()
   texture = lines[0..^4] # range is inclusive, the last line is empty line
   moves = findAll(lines[^2], re"([0-9]+|R|L)")

# Math stuff
func `+`(a,b: Vec3): Vec3 = [a[0]+b[0], a[1]+b[1], a[2]+b[2]]
func `+`(a: Vec3, b: float): Vec3 = [a[0]+b, a[1]+b, a[2]+b]
func `-`(a,b: Vec3): Vec3 = [a[0]-b[0], a[1]-b[1], a[2]-b[2]]
func `-`(a: Vec3): Vec3 = [-a[0], -a[1], -a[2]]
func `*`(a: Vec3, b: float): Vec3 = [a[0]*b, a[1]*b, a[2]*b]
func `==`(a,b: Vec3): bool = a[0]==b[0] and a[1]==b[1] and a[2]==b[2]
func dot(a,b: Vec3): float = a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
func cross(a: Vec3, b: Vec3): Vec3 = [a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0]]

when fname == "test":
   const 
      w = 4
      world1 = FlatWorld(face: face(y, x, z, 0, 2*w, 4*w, 3*w))
      world2 = CubeWorld(faces : [
            face(y, x, z, 0, 2*w, w, w),
            face(-z, -x, -y, w, 0, w, w),
            face(-x,z,-y,w,w, w,w ),
            face(z,x,-y, w, 2*w, w, w),
            face(-y,x,-z,2*w,2*w, w,w),
            face(x,y,-z,2*w, 3*w, w,w )
         ])

elif fname == "input":
   const 
      w = 50
      world1 = FlatWorld(face: face(y, x, z, 0, 2*w, 3*w, 4*w))
      world2 = CubeWorld(faces :[
         face(x, -y, z, 0, 2*w, w, w),
         face(y,x,z, 0, w, w, w),
         face(z,x,-y, w, w, w, w),
         face(-y,x,-z, 2*w, w, w, w),
         face(-x,-y,-z, 2*w,0, w, w),
         face(-z,-y,x, 3*w, 0, w, w)
      ])

proc rotate(state: var State, dir: string) =
   case dir
      of "L": state.fwd = cross(state.up, state.fwd)
      of "R": state.fwd = cross(state.fwd, state.up)
   
func face_at(world: CubeWorld, state: State): Face = 
   for i, f in world.faces:
      if state.up == f.n:
         return f 

func face_at(world: FlatWorld, state: State): Face = 
   return world.face

func tex_coords(world: FlatWorld, state: State): (int,int) =
   return (state.pos[2].int, state.pos[0].int)

func tex_coords(world: CubeWorld, state: State): (int,int) =
   let
      f = world.face_at(state)
      u = dot(f.u, state.pos) + f.width/2
      v = dot(f.v, state.pos) + f.height/2
   return (f.row0 + floor(v).int,f.col0 + floor(u).int)

proc rowSize(i:int): int = 
   texture[i].strip().len
proc colSize(j:int): int = 
   for line in texture:
      if j<line.len and line[j] != ' ':
         result += 1

when fname == "test":
   doAssert rowSize(0) == 4
   doAssert rowSize(1) == 4
   doAssert rowSize(4) == 12
   doAssert rowSize(8) == 8
   doAssert colSize(0) == 4
   doAssert colSize(1) == 4
   doAssert colSize(3) == 4
   doAssert colSize(8) == 12
   doAssert colSize(12) == 4

proc is_wall(world: World, state: State): bool = 
   let (i,j) = world.tex_coords(state)
   if i >= 0 and j >= 0 and i < texture.len:
      let row = texture[i]
      return row[j] == '#'
   else:
      return false

proc is_void(world: FlatWorld, state: State): bool = 
   let (i,j) = world.tex_coords(state)
   if i >= 0 and j >= 0 and i < texture.len:
      let row = texture[i]
      return j >= row.len or row[j] == ' '
   else:
      return true

proc move(world: FlatWorld, state: var State) =
   let old = state

   # move on step in the currently facing direction, unless a wall is there
   state.pos = state.pos + state.fwd
   echo state

   if world.is_void(state):
      
      # wrap around
      # state.pos = state.pos - state.fwd
      let f = world.face_at(state)
      let (i,j) = world.tex_coords(state)
      if dot(state.fwd, f.u) != 0:
         state.pos = state.pos - state.fwd * float(rowSize(i))
      else:
         state.pos = state.pos - state.fwd * float(colSize(j))
      echo "wraped around to ", state
   
   doAssert state.pos[0] >= 0 and state.pos[1] >= 0 and state.pos[2] >= 0
   
   if world.is_wall(state):
      echo "is wall, stop"
      state = old 

proc move(world: CubeWorld, state: var State) =
   let old = state

   # move on step in the currently facing direction, unless a wall is there
   state.pos = state.pos + state.fwd
   
   let f = world.face_at(state)
   
   if dot(state.pos, state.fwd) > f.width/2: # Assuming width == height
      # change to another face
      let tmp = state.fwd
      state.fwd = -state.up
      state.up = tmp 
      
      # now walk another step so we're at the correct first or last position
      state.pos = state.pos + state.fwd

   if world.is_wall(state):
      state = old 
   
proc walk(world: World, state: var State, moves: seq[string]) =
   for m in moves:
      if m in "LR":
         rotate(state, m)
      else:
         for i in 1..parseInt(m):
            move(world, state)

func score(world: World, state: State): int =
   let f = world.face_at(state)
   let (i,j) = world.tex_coords(state)    
   let facing = 
      if dot(f.u, state.fwd) == 1: 0 
      elif dot(f.v, state.fwd) == 1: 1
      elif dot(f.u, state.fwd) == -1: 2
      else: 3

   result = (i+1)*1000 + (j+1)*4 + facing


var state1 = State(pos: [2.0*w, 0.0, 0.0], fwd: x, up: y)
walk(world1, state1, moves)
let ans1 = score(world1, state1)

var state2 = State(pos: [-w/2,w/2,-w/2], fwd: x, up: y)
state2.pos = state2.pos + 0.5
walk(world2, state2, moves)
let ans2 = score(world2, state2)

echo fmt"{ans1},{ans2}"

