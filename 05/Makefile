export PATH := /opt/homebrew/opt/llvm/bin:${PATH}

all: bin/main
	$< 

bin/main: main.hs
	mkdir -p bin
	ghc -o $@ $< -no-keep-hi-files -no-keep-o-files 1>&2

clean:
	rm -rf bin

install:
	brew install ghc llvm

