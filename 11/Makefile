all: bin/main
	$<

bin/main: main.rs
	mkdir -p bin/
	rustc $< -o $@

clean:
	rm -rf bin 
