
include ../Makefile.inc

CWD = $(shell pwd)

INSTALL_DIR = $(HOME)/.config/sublime-text-2/Packages/User
SOURCE_DIR = $(CWD)/Packages/User

install: $(SOURCE_DIR) backup
	$(LN) $< $(INSTALL_DIR)

backup:
	test -L "$(INSTALL_DIR)" && $(RM) "$(INSTALL_DIR)" || exit 0
	test -d "$(INSTALL_DIR)" && $(MV) "$(INSTALL_DIR)" "$(INSTALL_DIR).old" || echo "No backup needed..."

clean:
	$(RM) "$(INSTALL_DIR)"

.PHONY: install backup
