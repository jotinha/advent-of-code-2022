all: bin/main.js
	node $<

bin/main.js: main.ts
	mkdir -p bin
	tsc $< --outFile $@
