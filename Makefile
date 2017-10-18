ALL_SUBPROJECTS := \
	common \
	concon

ALL_SUBMAKE_DIRECTORIES := \
	src

define call_subproject_makefiles
	$(eval TARGET=$1)

	for submake in $(ALL_SUBMAKE_DIRECTORIES) ; do \
		$(MAKE) -C $$submake $(TARGET) ; \
	done
endef

all:
	$(call call_subproject_makefiles, $@)

clean:
	$(call call_subproject_makefiles, $@)

common:
	$(call call_subproject_makefiles, $@)

concon:
	$(call call_subproject_makefiles, $@)

install:
	$(call call_subproject_makefiles, $@)

uninstall:
	$(call call_subproject_makefiles, $@)
