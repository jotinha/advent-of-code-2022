// Assume add.wasm file exists that contains a single function adding 2 provided arguments
const fs = require('fs');
var mem = new WebAssembly.Memory({initial:1});

const moves = fs.readFileSync("test").toString().trim().split("");
const wasmBuffer = fs.readFileSync('bin/main.wasm');

WebAssembly.instantiate(wasmBuffer, {js: { mem }}).then(({instance}) => {
  const pieces = [0b00111100,
    0b00010000_00111000_00010000,
    0b00001000_00001000_00111000,
    0b00100000_00100000_00100000_00100000,
    0b00110000_00110000]
  

  var dataView = new DataView(mem.buffer);

  //build world (just rows of 1's, which represent 7 empty bits and one 1 as the far right wall) 
  //we will override the first bytes later with other data, but it's easier this wya
  for (let i=0; i < mem.buffer.byteLength; i++) {
    dataView.setUint8(i,1,true);
  }

  pieces.forEach((p,i) => dataView.setUint32(i*4, p, true));

  dataView.setUint32(pieces.length*4, moves.length, true);

  moves.forEach((m,i) => 
    dataView.setUint8((pieces.length+1)*4 + i, m == '<' ? 0 : 1, true));

  //var length = instance.exports.memtest();
  //var bytes = new Uint8Array(mem.buffer, 0, length);
  //var string = new TextDecoder('utf8').decode(bytes);
  let ans1 = instance.exports.main();
  console.log(ans1);

});
