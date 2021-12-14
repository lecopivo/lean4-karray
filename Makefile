.PHONY: clean build run test

clean:
	@lake clean && rm -rf examples/*.cpp

build:
	@make clean && lake build

run:
	@lake run examples

test:
	@make build && make run
