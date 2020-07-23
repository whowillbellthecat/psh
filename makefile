PREFIX?=/usr/local
BIN?=$(PREFIX)/bin/
INSTALL=install

shell: *.pl
	gplc psh.pl

clean:
	rm psh

install:
	$(INSTALL) -csm 0755 psh "$(BIN)"
