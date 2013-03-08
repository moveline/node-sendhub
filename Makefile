clean:
	rm -fr lib/

deps:
	@test `which npm` || echo 'You need to have NPM in your PATH.\nPlease install it using `brew install node`'

install: deps
	@npm install

generate-js: deps
	@find src -name '*.coffee' | xargs coffee -c -o lib

test: install
	@./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--require should \
		--reporter spec \
		spec

.PHONY: all
