src = $(wildcard *.sh)

exe_name = cfgcontrol
project_main = cfgcontrol.sh

.PHONY: all

all: $(src)
	for infile in $^ ; do \
		cp $$infile ${PROJECTOUT} ; \
	done
	if [ -h "${BINDIR}/$(exe_name)" ] ; then rm ${BINDIR}/$(exe_name) ; fi
	ln -s ${PROJECTOUT}/$(project_main) ${BINDIR}/$(exe_name)
