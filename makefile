.POSIX:
PREFIX=/usr/local
BIN=$(DESTDIR)$(PREFIX)/bin
INSTALL=install

psh: *.pl
	gplc psh.pl

clean:
	rm psh

install:
	$(INSTALL) -csm 0755 psh "$(BIN)"
