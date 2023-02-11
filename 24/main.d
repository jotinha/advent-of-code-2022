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

void main() {
   load("test");
   writeln(world);
}
