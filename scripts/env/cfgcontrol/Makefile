src = $(wildcard *.sh)

.PHONY: all

all: $(src)
	$(info outdir is ${OUTDIR})
	if [ ! -d "out" ] ; then mkdir out ; fi
	for asource in $(src) ; do \
		cp $$asource out ; \
	done

# ifneq ($(wildcard /a/dirr/.*),)
#         @echo "Found /a/dirr."
# else
#         @echo "Did not find /a/dirr."
# endif
