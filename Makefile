.POSIX:

EMACS = emacs
EMACS_RUN = $(EMACS) -batch -Q -L .

FILE = jwt-mode

build: $(FILE).elc $(FILE)-tests.elc

$(FILE).elc: $(FILE).el
$(FILE)-tests.elc: $(FILE)-tests.el $(FILE).elc

clean:
	@rm -f *.elc

check: $(FILE)-tests.elc
	@$(EMACS_RUN) -l $(FILE)-tests.elc -f ert-run-tests-batch

bench: $(FILE)-tests.elc
	@$(EMACS_RUN) -l $(FILE)-tests.elc -f $(FILE)-benchmark

.SUFFIXES: .el .elc
.el.elc:
	@$(EMACS_RUN) -f batch-byte-compile $<
