all: bin/Main.class
	scala -classpath bin/ Main 

bin/Main.class: main.sc
	mkdir -p bin
	scalac -d bin/ $<

clean:
	rm -rf bin
