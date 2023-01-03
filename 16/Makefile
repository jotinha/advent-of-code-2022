all: main.js
	node $<

main.js: main.ts package.json
	tsc $<

package.json:
	npm install --save @types/node
