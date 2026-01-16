.PHONY: all clean html

NAME = edge-iot-arch-guide
TXT = $(NAME).txt
PDF = $(NAME).pdf
HTML = $(NAME).html

# List sources files here; order is meaningful.
MARKDOWNS = \
	index.md \
	source/chapter1-about.md \
	source/FWU/MBFW/index.md \
	source/FWU/MBFW/chapter2-uefi.md \
	source/FWU/MBFW/chapter1-introduction.md \
	source/FWU/MBFW/chapter4-failsafe.md \
	source/FWU/MBFW/chapter3-fwupdate.md \
	source/FWU/MBFW/references.md \
	source/Security/SecureStorage/index.md

PANDOC_OPTS = -f markdown+rebase_relative_paths

all: $(TXT) $(MAN) $(PDF) $(HTML)

$(TXT):	$(MARDOWNS)
	pandoc -o $@ $(MARKDOWNS) $(PANDOC_OPTS) -t plain

$(PDF) $(HTML):	$(MARDOWNS)
	pandoc -o $@ $(MARKDOWNS) $(PANDOC_OPTS)

clean:
	rm -fr $(TXT) $(PDF) $(HTML)
