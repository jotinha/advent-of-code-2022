all: bin/main
	$< 

bin/main: main.fs main.fsproj
	dotnet build -c Release -o bin

clean:
	rm -rf obj bin
