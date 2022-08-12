.PHONY: build clean

build:
	dune build @all

install:
	dune build @install
	dune install

uninstall:
	dune uninstall

clean:
	dune clean
