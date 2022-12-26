all: bin/main
	$<

bin/main: main.rs
	mkdir -p bin/
	clear
	rustc $< -o $@

clean:
	rm -rf bin 
