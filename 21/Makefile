run: bin/main
	clear
	$<

bin/main: main.swift
	clear
	mkdir -p bin
	swiftc $< -o $@

clean:
	rm -rf bin

ref:
	clear
	python3 main.py

