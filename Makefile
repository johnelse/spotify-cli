PREFIX?=/usr/local

.PHONY: install uninstall clean

dist/build/spotify-cli/spotify-cli:
	obuild configure
	obuild build

install:
	install -D dist/build/spotify-cli/spotify-cli $(PREFIX)/bin/spotify-cli

uninstall:
	rm -f $(PREFIX)/bin/spotify-cli

clean:
	rm -rf dist
