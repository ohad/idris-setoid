all: Tutorial.html

.PHONY:

ttms:
	pack build setoid-doc.ipkg

%.html: ttms .PHONY
	pack run katla \
	  markdown \
    --config ./setoid-doc-style.dhall \
    sources/$*.md \
    ./build/ttc/*/$*.ttm > $*.md
	pandoc $*.md --from=markdown -o $*.html

install-deps:
	pack install-deps setoid-doc.ipkg
