all: bin/main
	$< 

bin/main: main.cs main.csproj  
	dotnet build -c Release -o bin 1>&2

clean:
	rm -rf obj bin
