import std.stdio, std.string, std.algorithm, std.range;

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
      (x == world.w-1 && y == world.h) || // ending position also allowed
      x >= 0 && x < world.w &&
      y >= 0 && y < world.h &&
      '^' != world.data[(y + round).wrap(world.h)][x] &&
      'v' != world.data[(y - round).wrap(world.h)][x] &&
      '<' != world.data[y][(x + round).wrap(world.w)] &&
      '>' != world.data[y][(x - round).wrap(world.w)];
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

int shortestPath(State start, State end) {
   State state; 
   int[VisitedState] visited;

   auto todo = [start];
   
   ulong it = 0;
   while (!todo.empty && it<= 1_000_000) {
      state = todo.front; // BFS
      todo.popFront;

      if (posEquals(state, end)) {
         //writeln("Found in ", it, " iterations");
         return state.round;
      }
 
      auto vs = VisitedState(
         state.x, state.y, 
         state.round % world.w,
         state.round % world.h
      );
      
      if (vs in visited && visited[vs] <= state.round) continue;
      visited[vs] = state.round;
      
      auto n = nextMoves(state)
         .filter!(s => isFree(s.x, s.y, s.round))
         .array;
      
      todo ~= n;
      it++;
         
   }
   throw new Exception("Couldn't find path"); 

}

void main() {
   //assert(wrap(-1,6) == 5); assert(wrap(-7,6) == 5);  assert(wrap(2,6) == 2); assert(wrap(8,6) == 2);
   
   load("input");

   /*for (int i=0; i<=18; i++) {
      writeln("minute ", i);
      showMap(i);
   }*/
 
   auto a = State(0,-1,0);
   auto b = State(world.w-1, world.h, 0);
   
   auto ans1 = shortestPath(a, b); 
   b.round = ans1; // start 2nd leg of the journey at b but update starting round
   a.round = shortestPath(b, a);
   auto ans2 = shortestPath(a, b);   
 
   writeln(ans1,',',ans2);
}
