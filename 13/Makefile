all: bin/main
	$< 

bin/main: main.fs main.fsproj
	dotnet build -c Release -o bin 1>&2

clean:
	rm -rf obj bin
