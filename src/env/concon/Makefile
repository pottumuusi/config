SRC = $(wildcard *.sh)

PROJECT_MAIN = concon.sh

# Substitute .sh with empty.
EXE_NAME := $(PROJECT_MAIN:.sh=)

.PHONY: all

all: $(SRC)
	echo "exe name is: $(EXE_NAME)"
	for infile in $^ ; do \
		cp $$infile ${PROJECTOUT} ; \
	done
	if [ -h "${BINDIR}/$(EXE_NAME)" ] ; then rm ${BINDIR}/$(EXE_NAME) ; fi
	ln -s ${PROJECTOUT}/$(PROJECT_MAIN) ${BINDIR}/$(EXE_NAME)
