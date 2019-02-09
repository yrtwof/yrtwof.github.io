SRCS = $(wildcard ./*/*.md ./*.md)

# all:
# 	echo "a" $(SRCS) "b"

$(subst html, md, $(SRCS)) : $(SRCS)
	pandoc -st html5 $< > $@

# index.html: index.md
# 	pandoc -st html5 $< > $@
