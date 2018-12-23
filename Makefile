.PHONY: build clean

build:
	./configure
	dune build @all

install:
	./configure
	dune build @install
	dune install

uninstall:
	dune uninstall

clean:
	dune clean
