SRCFILES = $(wildcard *.sh)
OUTFILES = $(addprefix ${PROJECTOUT}/, $(SRCFILES))

OUT_DIR_LINK_NAME := common

define prune_comments_from_file
	sed -i "s/^#.*\[RMTAG\].*//g" $(1)
endef

define cp_prune
	$(eval SRC=$(1))
	$(eval DEST=$(2))

	cp $(SRC) $(DEST)
	$(call prune_comments_from_file, $(DEST))
endef

all: $(OUTFILES)
	if [ -h "${BINDIR}/OUT_DIR_LINK_NAME" ] ; then rm ; fi
	ln -s ${PROJECTOUT} ${BINDIR}/$(OUT_DIR_LINK_NAME)

# Make does not consider implicit rules for PHONY targets
${PROJECTOUT}/%.sh: %.sh
	$(call cp_prune, $<, $@)
