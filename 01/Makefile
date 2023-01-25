all: bin/Main.class
	java -classpath bin Main 
	
bin/Main.class: main.java
	mkdir -p bin
	javac $< -d bin/ 

clean:
	rm -f Main.class
