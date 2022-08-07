all: Tutorial.md

.PHONY: all ttms

ttms:
	pack build setoid-doc.ipkg

%.md: .PHONY
	pack run katla markdown sources/$*.md ./build/ttc/$*.ttm > $*.md

install-deps:
	pack install-deps setoid-doc.ipkg
