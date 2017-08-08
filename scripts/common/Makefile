srcfiles = $(wildcard *.sh)
outfiles = $(addprefix ${PROJECTOUT}/, $(srcfiles))

#outfiles = $(srcfiles:.sh=.out)
#all_targets = $(addprefix ${PROJECTOUT}/, $(outfiles))
myfs = $(wildcard *.myf)

# all_targets := \
# 	common_paths

# Delete default suffixes including one for sh
#.SUFFIXES:
#.SUFFIXES: .txt .wut .myf .sh

# .PHONY: all $(all_targets)

linkname = common

define prune_comments_from_file
	sed -i "s/^#.*\[RMTAG\].*//g" $(1)
endef

define outcopy_file
	$(eval outfile=${OUTDIR}/$(1))
	cp $(1) $(outfile)
	$(call prune_comments_from_file, $(outfile))
endef

# make does not consider implicit rules for PHONY targets
#all: $(outfiles) $(myfs)
all: $(outfiles)
	echo "all_targets is: $(all_targets)"
	echo "projectout is: ${PROJECTOUT}"
#	echo "deps are: $^"

%.wut: %.myf
	cp $< $@
#	if [ ! -f "newfile" ] ; then touch newfile ; fi
#	echo "something happens"
#	cat $< > implicit_copy_$@

${PROJECTOUT}/%.sh: %.sh
	cp $< $@
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
