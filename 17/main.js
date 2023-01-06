// Assume add.wasm file exists that contains a single function adding 2 provided arguments
const fs = require('fs');
var mem = new WebAssembly.Memory({initial:1});

const wasmBuffer = fs.readFileSync('bin/main.wasm');
WebAssembly.instantiate(wasmBuffer, {js: { mem }}).then(({instance}) => {
  //var length = instance.exports.memtest();
  //var bytes = new Uint8Array(mem.buffer, 0, length);
  //var string = new TextDecoder('utf8').decode(bytes);
  let ans1 = instance.exports.main();
  console.log(ans1);

});
