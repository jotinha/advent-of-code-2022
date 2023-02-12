import std.stdio, std.string, std.algorithm, std.range;
import std.container : DList;

struct World {
   string[] data; 
   int h, w;
};

World world;

struct State { int x, y, round; }
struct VisitedState { int x, y, rx, ry; }

void load(string fname) {
   world.data = File(fname).byLineCopy
                  .drop(1)
                  .map!(line => line[1..$-1])
                  .filter!(line => line[1] != '#')
                  .array;
   world.w = cast(int)world.data[0].length;
   world.h = cast(int)world.data.length; 
}

bool posEquals(State a, State b) {
   // equal except for round number
   return a.x == b.x && a.y == b.y;
}; 

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

int findPath(State start, State end) {
   State state; 
   int[VisitedState] visited;

   auto todo = [start];
   ulong it = 0;
   while (!todo.empty && it<= 100_000_000) {
      state = todo.front; // BFS
      todo.popFront;

      if (posEquals(state, end)) {
         writeln("Found in ", it, " iterations");
         return state.round;
      }
 
      auto vs = VisitedState(
         state.x, state.y, 
         state.round.wrap(world.w),
         state.round.wrap(world.h)
      );
      
      if (vs in visited && visited[vs] <= state.round) continue;
      visited[vs] = state.round;
      
  
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

int solve1() {
   return findPath(State(0,-1,0), State(world.w-1, world.h-1)) + 1;

}

void main() {
   load("input");
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
