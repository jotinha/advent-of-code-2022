all: main.js
	node $<

main.js: main.ts package.json tsconfig.json
	tsc 

tsconfig.json:
	tsc --init --noEmitOnError	

package.json:
	npm install --save @types/node

clean:
	rm -f main.js
