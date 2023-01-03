all: main.js
	node $<

main.js: main.ts package.json tsconfig.json
	clear
	tsc

tsconfig.json:
	tsc --init	

package.json:
	npm install --save @types/node
