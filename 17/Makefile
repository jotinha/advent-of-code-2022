run: main.js bin/main.wasm
	node $<

bin/main.wasm: main.wat
	mkdir -p bin
	wat2wasm $< -o $@

bin/main: main.wat
	mkdir -p bin
	wasmer create-exe $< -o $@

