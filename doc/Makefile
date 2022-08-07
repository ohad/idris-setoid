all: Tutorial.md

.PHONY: all ttms

ttms:
	pack build setoid-doc.ipkg

%.md: .PHONY
	pack run katla markdown --config ./setoid-doc-style.dhall sources/$*.md ./build/ttc/$*.ttm > $*.md
	pandoc $*.md -o $*.html

install-deps:
	pack install-deps setoid-doc.ipkg
