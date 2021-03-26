.POSIX:
PREFIX=/usr/local
BIN=$(DESTDIR)$(PREFIX)/bin
INSTALL=install
CC=gcc

psh: *.pl os.c
	gplc --no-top-level make.pl
	./make
	gplc --c-compiler "$(CC)" psh.pl os.c

clean:
	rm p_*.pl
	rm make
	rm psh

install: psh
	$(INSTALL) -csm 0755 psh "$(BIN)"
