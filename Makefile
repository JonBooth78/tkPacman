PROGNM = tkpacman
PREFIX ?= /usr/local
DOCDIR ?= $(PREFIX)/share/doc/$(PROGNM)
SHRDIR ?= $(PREFIX)/share/$(PROGNM)
BINDIR ?= $(PREFIX)/bin
TCL = config.tcl generic.tcl main.tcl misc.tcl options.tcl
DOC = README.txt CHANGE_LOG.txt

.PHONY: install

install:
	@install -Dm644 $(TCL) -t $(DESTDIR)$(SHRDIR)

	@install -Dm644 icons/* -t $(DESTDIR)$(SHRDIR)/icons
	@install -Dm644 msgs/* -t $(DESTDIR)$(SHRDIR)/msgs

	@install -Dm755 askpass/askpass.tcl -t $(DESTDIR)$(SHRDIR)/askpass
	@install -Dm644 askpass/msgs/* -t $(DESTDIR)$(SHRDIR)/askpass/msgs

	@install -Dm755 $(PROGNM) -t $(DESTDIR)$(BINDIR)
	@install -Dm644 $(PROGNM).desktop -t $(DESTDIR)$(PREFIX)/share/applications

	@install -Dm644 $(DOC) -t $(DESTDIR)$(DOCDIR)
	@install -Dm644 doc/en/help.txt -t $(DESTDIR)$(DOCDIR)/en
	@install -Dm644 doc/nl/help.txt -t $(DESTDIR)$(DOCDIR)/nl
