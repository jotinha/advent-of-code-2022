run: bin/main
	$<

bin/main: main.d
	mkdir -p bin
	dmd -of=$@ $< 

clean:
	rm -rf bin

install:
	brew install dmd # doesn't work for M1, got it from the website instead
