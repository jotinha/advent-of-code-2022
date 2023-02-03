import std/strutils
import std/re
import std/math
import std/strformat

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
      row0: int # row in the texture where the face starts
      col0: int

func face(n,u,v:Vec3,r,c:int): Face =
   Face(n:n, u:u, v:v, row0:r, col0:c)

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
func `==`(a,b: Vec3): bool = a[0]==b[0] and a[1]==b[1] and a[2]==b[2]
func dot(a,b: Vec3): float = a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
func cross(a: Vec3, b: Vec3): Vec3 = [a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0]]

when fname == "test":
   const w = 4
   const faces = [
      face(y, x, z, 0, 2*w),
      face(-z, -x, -y, w, 0),
      face(-x,z,-y,w,w),
      face(z,x,-y, w, 2*w),
      face(-y,x,-z,2*w,2*w),
      face(x,y,-z,2*w, 3*w)
   ]

elif fname == "input":
   const w = 50
   const faces = [
      face(x, -y, z, 0, 100),
      face(y,x,z, 0, 50),
      face(z,x,-y, 50, 50),
      face(-y,x,-z, 100, 50),
      face(-x,-y,-z, 100,0),
      face(-z,-y,x, 150, 0)
   ]

proc rotate(state: var State, dir: string) =
   case dir
      of "L": state.fwd = cross(state.up, state.fwd)
      of "R": state.fwd = cross(state.fwd, state.up)
   
func face_at(state: State): Face = 
   for i, f in faces:
      if state.up == f.n:
         return f 

func tex_coords(state: State): (int,int) =
   let
      f = face_at(state)
      u = dot(f.u, state.pos) + w/2
      v = dot(f.v, state.pos) + w/2
   return (f.row0 + floor(v).int,f.col0 + floor(u).int)

proc is_wall(state: State): bool = 
   let (i,j) = tex_coords(state)
   return texture[i][j] == '#'

proc move(state: var State) =
   let old = state

   # move on step in the currently facing direction, unless a wall is there
   state.pos = state.pos + state.fwd
   
   if dot(state.pos, state.fwd) > w/2:
      # change to another face
      let tmp = state.fwd
      state.fwd = -state.up
      state.up = tmp 
      
      # now walk another step so we're at the correct first or last position
      state.pos = state.pos + state.fwd

   if is_wall(state):
      state = old 
   
proc walk(state: var State, moves: seq[string]) =
   for m in moves:
      if m in "LR":
         rotate(state, m)
      else:
         for i in 1..parseInt(m):
            move(state)

func score(state: State): int =
   let f = face_at(state)
   let (i,j) = tex_coords(state)    
   let facing = 
      if dot(f.u, state.fwd) == 1: 0 
      elif dot(f.v, state.fwd) == 1: 1
      elif dot(f.u, state.fwd) == -1: 2
      else: 3

   result = (i+1)*1000 + (j+1)*4 + facing

let ans1 = 0
var state = State(pos: [-w/2,w/2,-w/2], fwd: x, up: y)
state.pos = state.pos + 0.5

walk(state, moves)
echo state

let ans2 = score(state)
echo fmt"{ans1},{ans2}"

