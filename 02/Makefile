all: bin/main
	$<	

bin/main: main.c
	mkdir -p bin/
	gcc $< -o $@

clean:
	rm -rf bin 
