.POSIX:
PREFIX=/usr/local
BIN=$(DESTDIR)$(PREFIX)/bin
INSTALL=install

psh: *.pl
	gplc psh.pl

clean:
	rm psh

install: psh
	$(INSTALL) -csm 0755 psh "$(BIN)"
