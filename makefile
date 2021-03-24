.POSIX:
PREFIX=/usr/local
BIN=$(DESTDIR)$(PREFIX)/bin
INSTALL=install
CC=gcc

psh: *.pl os.c
	gplc --c-compiler "$(CC)" psh.pl os.c

clean:
	rm psh

install: psh
	$(INSTALL) -csm 0755 psh "$(BIN)"
