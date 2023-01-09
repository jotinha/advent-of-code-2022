run: main.js bin/main.wasm
	time node $<

bin/main.wasm: main.wat
	clear
	mkdir -p bin
	wat2wasm $< -o $@

bin/main: main.wat
	mkdir -p bin
	wasmer create-exe $< -o $@

php: main.php 
	clear
	time php $<	

