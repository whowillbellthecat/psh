.POSIX:
PREFIX=/usr/local
BIN=$(PREFIX)/bin/
INSTALL=install

psh: *.pl
	gplc psh.pl

clean:
	rm psh

install:
	$(INSTALL) -csm 0755 psh "$(BIN)"
