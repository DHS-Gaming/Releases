DATESTAMP := $(shell date +%s)

RELEASE = bin/release.sh "$(@)" "$(DATESTAMP)"

all: testing

clean:
	rm -rfv /cygdrive/d/CYGWIN_RELEASES

.PHONY: production
production:
	@$(RELEASE)

.PHONY: testing
testing:
	@$(RELEASE)
