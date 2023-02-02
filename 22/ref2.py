from numpy import ndarray, dot, array, cross
from dataclasses import dataclass, replace as copy
import re
from math import floor

data = open("input").readlines()
board = data[:-2]
pwd = data[-1]

ww = max(len(b) for b in board)
board = [[1 if c == '.' else 2 if c == '#' else 0 for c in b.ljust(ww) if c!='\n'] for b in board]
board = array(board)

moves = re.findall('([0-9]+|R|L)',pwd)

Vec3 = ndarray

def vec3(x,y,z) -> Vec3: 
   return array([x,y,z], dtype='float')

x = vec3(1,0,0)
y = vec3(0,1,0)
z = vec3(0,0,1)

# w = 4  #  for test set
w = 50  # for input set

@dataclass
class Face:
   n: Vec3
   u: Vec3
   v: Vec3
   row0: int
   col0: int

@dataclass
class State:
   pos: Vec3
   fwd: Vec3
   up: Vec3

def face_at(state):
   for i,f in enumerate(faces):
      if all(f.n == state.up):
         return f,i
   raise ValueError("can't find face")

def get_tex_coord(state):
   f,i = face_at(state)
   u,v = dot(f.u, state.pos) + w/2, dot(f.v, state.pos) + w/2
   if abs(u) >= w or abs(v) >= w:
      raise ValueError(f"invalid coords: u={u},v={v}")
   col = floor(f.col0 + u)
   row = floor(f.row0 + v)
   return row, col
      

def is_wall(row, col):
   return board[row,col] == 2

def is_at_wall(state):
   return is_wall(*get_tex_coord(state))
 
def move1(state):
   old = state
   state = copy(state)

   state.pos = state.pos + state.fwd
   
   proj = dot(state.pos, state.fwd)
   if proj > w/2:
      # state.pos = state.pos - state.fwd # walk back
      # change to another face
      state.up, state.fwd = state.fwd, -state.up
      state.pos = state.pos + state.fwd
   if is_at_wall(state):
      return old
   return state

def rotate(state, dir):
   state = copy(state)
   if dir == 'L':
      state.fwd = cross(state.up, state.fwd)
   elif dir == 'R':
      state.fwd = cross(state.fwd, state.up)   
   else: raise ValueError
   return state
   
def walk(state, moves, trace):
   for m in moves:
      if m in 'LR':
         state = rotate(state, m)
         trace.append(state)
      else:
         for _ in range(int(m)):
            state = move1(state)
            trace.append(state)

def score(state):
   f,_ = face_at(state)
   row, col = get_tex_coord(state)    
   facing = 0 if dot(f.u, state.fwd) == 1 else \
            1 if dot(f.v, state.fwd) == 1 else \
            2 if dot(f.u, state.fwd) == -1 else \
            3

   return (row+1)*1000 + (col+1)*4 + facing


#input
faces = [
  Face(x, -y, z, 0, 100),
  Face(y,x,z, 0, 50),
  Face(z,x,-y, 50, 50),
  Face(-y,x,-z, 100, 50),
  Face(-x,-y,-z, 100,0),
  Face(-z,-y,x, 150, 0)
]

# test
# faces = [
#    Face(y, x, z, 0, 2*w),
#    Face(-z, -x, -y, w, 0),
#    Face(-x,z,-y,w,w),
#    Face(z,x,-y, w, 2*w),
#    Face(-y,x,-z,2*w,2*w),
#    Face(x,y,-z,2*w, 3*w)
# ]

state = state0 = State(pos=vec3(-w/2,w/2,-w/2), fwd=vec3(1,0,0), up=vec3(0,1,0))
state0.pos = state0.pos + 0.5
trace = []
walk(state0, moves, trace)
print(score(trace[-1]))

def draw_trace(trace):
   import matplotlib.pyplot as plt
   bm = board.copy()
   for s in trace:
       row,col = get_tex_coord(s)
       bm[row,col] = 3
   plt.imshow(bm)

def draw_trace3d(trace):
   import matplotlib.pyplot as plt
   ax = plt.figure().add_subplot(projection='3d')
   ax.set_xlim(-w/2,w/2);
   ax.set_ylim(-w/2,w/2);
   ax.set_zlim(-w/2,w/2);
   data = np.vstack([s.pos for s in trace])
   ax.plot(data[:,0], data[:,1], data[:,2], 'k.-')

