import std.stdio, std.string, std.algorithm;
import std.container : DList;


enum Dir { None, Up, Down, Left, Right};
struct World {
   Dir[128][32] pos;
   int w, h;
};

World world;

void load(string fname) {
   auto f = File(fname);
   foreach(line; f.byLine) {
      line = line[1..$-1];
      if (line[1] != '#') {
         foreach (w; line) {
            Dir d;
            switch (w) {
                case '<': d = Dir.Left; break;
                case '>': d = Dir.Right; break;
                case '^': d = Dir.Up; break;
                case 'v': d = Dir.Down; break;
                case '.': d = Dir.None; break;
                default: assert(0); 
            }
            world.pos[world.h++][world.w++] = d;
         }
      }
   }
}

void main() {
    load("test");
}
