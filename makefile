.POSIX:
PREFIX=/usr/local
BIN=$(DESTDIR)$(PREFIX)/bin
INSTALL=install
CC=gcc

psh: *.pl os.c
	gplc --no-top-level make.pl
	./make
	gplc --c-compiler "$(CC)" p_psh.pl os.c
	mv -f p_psh psh

clean:
	rm p_*.pl
	rm make
	rm psh

install: psh
	$(INSTALL) -csm 0755 psh "$(BIN)"
