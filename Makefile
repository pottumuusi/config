repo_root = "/root/my/config/useful-files"
subprojects := \
	scripts/env/cfgcontrol \
	scripts/common

.PHONY: all install uninstall

all:
	if [ ! -d "out" ] ; then mkdir out ; fi
	for project in $(subprojects) ; do \
		echo "subproject is: $$project" ; \
		mkdir -p $(repo_root)/out/$$project ; \
		$(MAKE) -C $$project REPOROOT=$(repo_root) OUTDIR=$(repo_root)/out/$$project all ; \
	done

install: out/scripts/env/cfgcontrol/cfgcontrol.sh
	mkdir bin/
	cp $< bin/cfgcontrol

uninstall:
	rm -f bin/cfgcontrol
