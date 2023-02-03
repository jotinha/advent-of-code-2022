import std/strutils
import std/re

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

const
   fname = "test"

let
   lines = readFile(fname).splitLines()
   texture = lines[0..^4] # range is inclusive, the last line is empty line
   moves = findAll(lines[^2], re"([0-9]+|R|L)")

echo texture[10][15]



