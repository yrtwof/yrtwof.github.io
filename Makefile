index.html: index.md
	pandoc -st html5 $< > $@
