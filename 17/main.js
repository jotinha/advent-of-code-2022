// Assume add.wasm file exists that contains a single function adding 2 provided arguments
const fs = require('fs');
var mem = new WebAssembly.Memory({initial:1});

const wasmBuffer = fs.readFileSync('bin/main.wasm');
WebAssembly.instantiate(wasmBuffer, {js: { mem }}).then(({instance}) => {
  const pieces = [0b00111100,
    0b00010000_00111000_00010000,
    0b00001000_00001000_00111000,
    0b00100000_00100000_00100000_00100000,
    0b00110000_00110000]
  

  var dataView = new DataView(mem.buffer);
  pieces.forEach((p,i) => dataView.setUint32(i*4, p, true));
  

  //var length = instance.exports.memtest();
  //var bytes = new Uint8Array(mem.buffer, 0, length);
  //var string = new TextDecoder('utf8').decode(bytes);
  let ans1 = instance.exports.main();
  console.log(ans1);

});
