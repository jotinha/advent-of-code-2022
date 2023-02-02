import std/strutils
import std/re

const
   fname = "test"

let
   lines = readFile(fname).splitLines()
   board = lines[0..^4] # range is inclusive, the last line is empty line
   moves = findAll(lines[^2], re"([0-9]+|R|L)")

echo moves 

