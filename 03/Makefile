all: bin/main
	$< 

bin/main: main.cs main.csproj  
	dotnet build -c Release -o bin

clean:
	rm -rf obj bin
