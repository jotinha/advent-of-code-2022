// Assume add.wasm file exists that contains a single function adding 2 provided arguments
const fs = require('fs');
var mem = new WebAssembly.Memory({initial:1});

const moves = fs.readFileSync("input").toString().trim().split("");

const wasmBuffer = fs.readFileSync('bin/main.wasm');

function draw_world_at(y) {
  var data = new Uint8Array(mem.buffer, world_pos[0]);
  for (let i=20; i >= 0; i--) {
    let pixels = (data[i] | (1<<8)).toString(2); 
    console.log(pixels.replaceAll('0','.').replaceAll('1','@'))
  }
}

let pieces_pos = [0,5*4]
let moves_pos = [pieces_pos[1], pieces_pos[1] + moves.length]
let world_pos = [moves_pos[1], moves_pos[1] + 20_000]
let deltas_pos = [world_pos[1] + 4, world_pos[1] + 4 + 20_000] //the +4 is a safety margin because setframe can write 4bytes ahead

let toWasm = {
  js: {
    mem: mem,
    nmoves: new WebAssembly.Global({value: 'i32',mutable:false}, moves.length),
    world_start: new WebAssembly.Global({value: 'i32', mutable: false}, world_pos[0]),
    world_size: new WebAssembly.Global({value: 'i32', mutable: false}, world_pos[1] - world_pos[0]),
    deltas_start: new WebAssembly.Global({value: 'i32', mutable: false}, deltas_pos[0]),
    deltas_size: new WebAssembly.Global({value: 'i32', mutable: false}, deltas_pos[1] - deltas_pos[0])
  }
}
//console.log(pieces_pos, moves_pos, world_pos, deltas_pos)

//initialize data - pieces in the first 20 bytes
const pieces = [0b00111100,
  0b00010000_00111000_00010000,
  0b00001000_00001000_00111000,
  0b00100000_00100000_00100000_00100000,
  0b00110000_00110000]

var dataView = new DataView(mem.buffer);
pieces.forEach((p,i) => dataView.setUint32(pieces_pos[0] + i*4, p, true));

// save moves in the following nmoves bytes
moves.forEach((m,i) => dataView.setUint8(moves_pos[0] + i, m == '<' ? 0 : 1, true));

function simulate(instance, n) {
  let y = instance.exports.simulate(n);
  //draw_world_at(0);

  let deltas = new Uint8Array(mem.buffer, deltas_pos[0], n) 
  fs.writeFileSync('deltas.out', deltas);

  console.assert(y == array_sum(deltas));

  return {y, deltas}
}

function arrays_equal(a,b) {
  return a.every((aa,i) => aa == b[i]);
}

function array_sum(a) {
  return a.reduce((acc,x) => acc+x);
}

function find_pattern(xs) {
  let max_size = Math.floor(xs.length/2);
  let min_size = 100;
  for(let size=max_size; size >= min_size; size--) {
    let a = xs.slice(-size);
    let b = xs.slice(-size*2,-size);
    if (arrays_equal(a,b)) {
      return find_pattern(a);
    }
  }
  return xs;
}

WebAssembly.instantiate(wasmBuffer, toWasm).then(({instance}) => {
  
  // solution 1
  let ans1 = simulate(instance, 2022).y;
  
  //solution 2
  //simulate a large enough size so we can look for a pattern
  let total_pieces = 1_000_000_000_000;
  let simulated_pieces = 10_000;
  let sim = simulate(instance, simulated_pieces)
  let simulated_height = sim.y;
  
  //pattern is the last `pattern_pieces` entries of sim.deltas
  let pattern = find_pattern(sim.deltas);
  let pattern_pieces = pattern.length;
  let pattern_height = array_sum(pattern)

  let initial_pieces = simulated_pieces % pattern_pieces // number of pieces outside of the pattern
  let initial_height = array_sum(sim.deltas.slice(0,initial_pieces))

  let n_repeats = Math.floor((total_pieces - initial_pieces) / pattern_pieces);

  // We also need to create a tail array with the missing pieces at the end (because our pattern we calculated
  // wont align neatly with the end, hence the Math.floor on the n_repeats formula)
  let tail_pieces = (total_pieces - initial_pieces) % pattern_pieces;
  let tail_height = array_sum(pattern.slice(0, tail_pieces))

  let ans2 = initial_height + n_repeats*pattern_height + tail_height;

  console.log(`${ans1},${ans2}`);

});