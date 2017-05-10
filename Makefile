.PHONY: build clean

build:
	jbuilder build @install

install:
	jbuilder install

uninstall:
	jbuilder uninstall

clean:
	rm -rf _build
