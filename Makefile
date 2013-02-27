clean:
	rm -fr lib/

deps:
	@test `which coffee` || echo 'You need to have CoffeeScript in your PATH.\nPlease install it using `brew install coffee-script` or `npm install -g coffee-script`.'

generate-js: deps
	@find src -name '*.coffee' | xargs coffee -c -o lib

test: deps
	@./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--require should \
		--reporter spec \
		spec

.PHONY: all
