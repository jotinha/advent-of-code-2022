run: bin/main
	$<

bin/main: main.swift
	mkdir -p bin
	swiftc $< -o $@

clean:
	rm -rf bin
