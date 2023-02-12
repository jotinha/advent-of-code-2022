import std.stdio, std.string, std.algorithm, std.range;
import std.container : DList;

struct World {
   string[] data; 
   int h, w;
};

World world;

struct State {
    int x, y;
    int rx, ry;
    int round;
};


void load(string fname) {
   world.data = File(fname).byLineCopy
                  .drop(1)
                  .map!(line => line[1..$-1])
                  .filter!(line => line[1] != '#')
                  .array;
   world.w = cast(int)world.data[0].length;
   world.h = cast(int)world.data.length; 
}

bool isTarget(int x, int y) {
   return x == world.w-1 && y == world.h-1;
}

bool isFree(int x, int y, int round) {
   return 
      (x == 0 && y == -1) || // starting position is allowed
      x >= 0 && x < world.w &&
      y >= 0 && y < world.h &&
      '^' != world.data[wrap(y + round,world.h)][x] &&
      'v' != world.data[wrap(y - round,world.h)][x] &&
      '<' != world.data[y][wrap(x + round,world.w)] &&
      '>' != world.data[y][wrap(x - round,world.w)];
}

int wrap(int a, int b) {
   //d's implementation of modulo gives -1%6 == -1, and we want it to give -1%6 == 5
   return (b + (a % b)) % b;
}



State[] nextMoves(State state) {
   state.round += 1;
   //WRONG state.rx = (state.rx + 1) % world.w;
   //WRONG state.ry = (state.ry + 1) % world.h;
   auto moves = [state, state, state, state, state]; 
   moves[0].x -= 1;
   moves[1].x += 1;
   moves[2].y -= 1;
   moves[3].y += 1;
   //move 4 is wait
   return moves;
}
void showMap(int round) {
   for (int y=0; y<world.h; y++) {
      for(int x=0; x<world.w; x++) {
          write(isFree(x,y,round) ? '.' : '#');
      }
      write("\n");
   }
}

int solve1() {
   State state; 

   auto todo = [State(0,-1,0,0,0)];

   ulong it = 0;
   while (!todo.empty && it<= 100_000) {
      state = todo.front;
      todo.popFront;
    
      if (isTarget(state.x, state.y)) {
         return state.round+1;
      }
   
      if ((it % 1000) == 0) {
         writeln(it, ' ', todo.length);
      }
          
      auto n = nextMoves(state)
         .filter!(s => isFree(s.x, s.y, s.round))
         .array;
      
      todo ~= n;
      it++;
         
   }
   return -1;

}

void main() {
   load("test");
   writeln(world);
   
   /*assert(!isFree(0,0,0));
   assert(!isFree(1,0,0));
   assert(isFree(0,1,0));
   assert(isFree(0,1,0));
   assert(isFree(2,0,0));
   assert(!isFree(2,0,1));
   assert(!isFree(2,0,1));
   assert(isFree(2,1,1));*/
   writeln(wrap(-1,6));
   assert(wrap(-1,6) == 5);
   assert(wrap(-7,6) == 5);
   assert(wrap(2,6) == 2);
   assert(wrap(8,6) == 2);

   auto ans1 = solve1();
  /* showMap(0);
   for (int i=1; i<=18; i++) {
      writeln("minute ", i);
      showMap(i);
   }*/
   auto ans2= 0;
   writeln(ans1,',',ans2);
}
