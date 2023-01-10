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
console.log(pieces_pos, moves_pos, world_pos, deltas_pos)

WebAssembly.instantiate(wasmBuffer, toWasm).then(({instance}) => {
  const pieces = [0b00111100,
    0b00010000_00111000_00010000,
    0b00001000_00001000_00111000,
    0b00100000_00100000_00100000_00100000,
    0b00110000_00110000]
  
  var dataView = new DataView(mem.buffer);

  pieces.forEach((p,i) => dataView.setUint32(pieces_pos[0] + i*4, p, true));

  moves.forEach((m,i) => 
    dataView.setUint8(moves_pos[0] + i, m == '<' ? 0 : 1, true));

  //var length = instance.exports.memtest();
  //var bytes = new Uint8Array(mem.buffer, 0, length);
  //var string = new TextDecoder('utf8').decode(bytes);
  let ans1 = instance.exports.main(2022);
  draw_world_at(0);

  var deltas = new Uint8Array(mem.buffer, deltas_pos[0], 2022) 
  fs.writeFileSync('deltas.out', deltas);

  let ans1b = deltas.reduce((acc,x) => acc + x);
  console.assert(ans1 == ans1b)
  console.log(ans1);


});
/*
151428577
15142861
1514288
151434
*/