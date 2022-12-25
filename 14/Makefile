all: bin/main
	$<

bin/main: main.f95
	mkdir -p bin/
	gfortran -o $@ $<

clean:
	rm -rf bin
