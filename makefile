.POSIX:
PREFIX=/usr/local
BIN=$(DESTDIR)$(PREFIX)/bin
INSTALL=install
CC=gcc

psh: *.pl os.c
	gplc --no-top-level make.pl
	./make psh.pl
	gplc --c-compiler "$(CC)" build/psh.pl os.c
	mv -f build/psh psh

clean:
	rm build/*.pl
	rm make
	rm psh

install: psh
	$(INSTALL) -csm 0755 psh "$(BIN)"

install_dict: psh_jargon
	$(INSTALL) -cm 0444 psh_jargon "$(PREFIX)/share/dict"

check: psh
	./psh -c do_tests.
