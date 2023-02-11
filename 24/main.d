import std.stdio, std.string, std.algorithm, std.range;
import std.container : DList;

struct World {
   string[] data; 
   ulong h, w;
};

World world;

void load(string fname) {
   world.data = File(fname).byLineCopy
                  .drop(1)
                  .map!(line => line[1..$-1])
                  .filter!(line => line[1] != '#')
                  .array;
   world.w = world.data[0].length;
   world.h = world.data.length; 
}

bool isFree(int x, int y, int round) {
   return 
      '^' != world.data[(y + round) % world.h][x] &&
      'v' != world.data[(y - round) % world.h][x] &&
      '<' != world.data[y][(x + round) % world.w] &&
      '>' != world.data[y][(x - round) % world.w];
}

void main() {
   load("test");
   writeln(world);
   
   assert(!isFree(0,0,0));
   assert(!isFree(1,0,0));
   assert(isFree(0,1,0));
   assert(isFree(0,1,0));
   assert(isFree(2,0,0));
   assert(!isFree(2,0,1));
   assert(!isFree(2,0,1));
   assert(isFree(2,1,1));
   
}
