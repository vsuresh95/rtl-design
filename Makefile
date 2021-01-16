export VCS_HOME=
export VERDI_HOME=
export PATH:=$(VCS_HOME):${PATH}
export SNPSLMD_LICENSE_FILE=
export WORKAREA=${PWD}

CC_OPTS+=-sverilog -kdb -debug_access+all
INCDIR+='+incdir+$(WORKAREA)/rtl'
DUMP_VPD?=

all: compile run

compile:
	@echo ${PATH}
	$(VCS_HOME)/bin/vcs $(CC_OPTS) $(WORKAREA)/tb/$(PROJECT)_tb.v $(INCDIR) -o $(WORKAREA)/$(PROJECT).simv

run:
	$(WORKAREA)/$(PROJECT).simv

clean:
	rm -rf *DB DVEfiles *novas* csrc *simv *daidir *log *Log ucli.key *vpd *fsdb

debug:
ifeq ($(DUMP_FSDB), y)
	$(VERDI_HOME)/bin/verdi -simBin $(WORKAREA)/$(PROJECT).simv -ssf $(WORKAREA)/$(PROJECT).fsdb
else
	$(VCS_HOME)/bin/dve -vpd $(WORKAREA)/$(PROJECT).vpd
endif

create_test:
	mkdir -p $(PROJECT)/rtl
	mkdir -p $(PROJECT)/tb
	cp four_bit_adder/Makefile $(PROJECT)
