PREFIX?=/usr/local
INSTALL_PATH=$(PREFIX)/bin/spotify-cli
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
	install -d $(shell dirname $(INSTALL_PATH))
	install spotify_cli.native $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)

clean:
	ocamlbuild -clean
	rm -f setup.data setup.log

scrub: clean
	rm -f myocamlbuild.ml
	rm -f setup.ml
