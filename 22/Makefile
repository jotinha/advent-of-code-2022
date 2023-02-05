run: bin/main
	$<

bin/main: main.nim
	mkdir -p bin
	nim c -o=$@ $<

clean:
	rm -rf bin

install:
	brew install nim

