PREFIX?=/usr/local
J=4

.PHONY: install uninstall clean

all: build

setup.ml: _oasis
	oasis setup

setup.data: setup.ml
	ocaml setup.ml -configure

build: setup.data setup.ml
	ocaml setup.ml -build -j $(J)

install:
	install -D spotify_cli.native $(PREFIX)/bin/spotify-cli

uninstall:
	rm -f $(PREFIX)/bin/spotify-cli

clean:
	ocamlbuild -clean
	rm -f setup.data setup.log
