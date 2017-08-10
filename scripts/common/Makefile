srcfiles = $(wildcard *.sh)
outfiles = $(addprefix ${PROJECTOUT}/, $(srcfiles))

linkname = common

define prune_comments_from_file
	sed -i "s/^#.*\[RMTAG\].*//g" $(1)
endef

define cp_prune
	$(eval src=$(1))
	$(eval dest=$(2))

	cp $(src) $(dest)
	$(call prune_comments_from_file, $(dest))
endef

all: $(outfiles)

# make does not consider implicit rules for PHONY targets
${PROJECTOUT}/%.sh: %.sh
	$(call cp_prune, $<, $@)

#	if [ ! -f "newfile" ] ; then touch newfile ; fi
#	echo "something happens"
#	cat $< > implicit_copy_$@

#	$(info src is $(src))
#	$(info testsrc is $(testsrc))
#	echo "Common done"

#	if [ -h "${BINDIR}/$(linkname)" ] ; then rm ${BINDIR}/$(linkname) ; fi
#	ln -s ${PROJECTOUT} ${BINDIR}/$(linkname)

# common_paths: common_paths.sh
# 	$(eval outfile=${OUTDIR}/$^)
# 	echo "readonly repo_root=\"${REPOROOT}\"" > $(outfile)
# 	cat $^ >> $(outfile)
# 	$(call prune_comments_from_file, $(outfile))

#	restore common.sh from temp copy

# %.shout: %.insh
# 	echo ".insh to .shout"
#	$(info target is $@)
#	$(info requirement is $<)
#	cp $@ $<
