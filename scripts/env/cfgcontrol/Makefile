src = $(wildcard *.sh)

project_main = cfgcontrol.sh

# Substitute .sh with empty. Place string to use in substitution after the '='
# character.
exe_name = $(project_main:.sh=)

.PHONY: all

all: $(src)
	echo "exe name is: $(exe_name)"
	for infile in $^ ; do \
		cp $$infile ${PROJECTOUT} ; \
	done
	if [ -h "${BINDIR}/$(exe_name)" ] ; then rm ${BINDIR}/$(exe_name) ; fi
	ln -s ${PROJECTOUT}/$(project_main) ${BINDIR}/$(exe_name)
