# === UCSF ChimeraX Copyright ===
# Copyright 2016 Regents of the University of California.
# All rights reserved.  This software provided pursuant to a
# license agreement containing restrictions on its disclosure,
# duplication and use.  For details see:
# http://www.rbvi.ucsf.edu/chimerax/docs/licensing.html
# This notice must be embedded in or attached to all copies,
# including partial copies, of the software or any revisions
# or derivations thereof.
# === UCSF ChimeraX Copyright ===

CHIMERAX_APP = /usr/local/chimerax

OS = $(patsubst CYGWIN_NT%,CYGWIN_NT,$(shell uname -s))
ifeq ($(OS),CYGWIN_NT)
PYTHON_EXE = $(CHIMERAX_APP)/bin/python.exe
CHIMERAX_EXE = $(CHIMERAX_APP)/bin/ChimeraX.exe
endif
ifeq ($(OS),Darwin)
PYTHON_EXE = $(CHIMERAX_APP)/Contents/bin/python3.6
CHIMERAX_EXE = $(CHIMERAX_APP)/Contents/bin/ChimeraX
endif
ifeq ($(OS),Linux)
PYTHON_EXE = $(CHIMERAX_APP)/bin/python3.6
CHIMERAX_EXE = $(CHIMERAX_APP)/bin/ChimeraX
endif

BUNDLE_NAME = ChimeraX-Stringdb
BUNDLE_VERSION = 0.1
PKG_NAME = chimerax.stringdb

BASE_BNDL_NAME = $(subst ChimeraX-,,$(BUNDLE_NAME))
WHL_BNDL_NAME = $(subst -,_,$(BUNDLE_NAME))

PYSRCS = $(wildcard src/*.py)
WHEEL = dist/$(WHL_BNDL_NAME)-$(BUNDLE_VERSION)-py3-none-any.whl

wheel $(WHEEL): setup.py $(PYSRCS)
	$(PYTHON_EXE) setup.py --no-user-cfg build
	$(PYTHON_EXE) setup.py --no-user-cfg test
	$(PYTHON_EXE) setup.py --no-user-cfg bdist_wheel
	rm -rf $(WHL_BNDL_NAME).egg-info

install app-install: $(WHEEL)
	$(CHIMERAX_EXE) --nogui --cmd "toolshed uninstall $(BASE_BNDL_NAME); exit"
	$(CHIMERAX_EXE) --nogui --cmd "toolshed install $(WHEEL) user false; exit"

test:
	$(CHIMERAX_EXE)

debug:
	$(CHIMERAX_EXE) --debug

clean:
	rm -rf src/__pycache__ build dist $(WHL_BNDL_NAME).egg-info setup.py

lint:
	$(PYLINT) $(PYSRCS)

setup.py: setup.py.in Makefile
	sed \
		-e 's,BUNDLE_NAME,$(BUNDLE_NAME),' \
		-e 's,BUNDLE_VERSION,$(BUNDLE_VERSION),' \
		-e 's,PKG_NAME,$(PKG_NAME),' \
		< setup.py.in > setup.py
