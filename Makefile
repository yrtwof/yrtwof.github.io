SRCS = $(wildcard ./*/*.md ./*.md)
FNAMES = $(patsubst %.md,%,$(SRCS))
OBJS = $(patsubst %.md,%.html,$(SRCS))

all : $(OBJS)

%.html: %.md
# 	echo $(SRCS)
# $(subst md,html, $(SRCS)) : $(SRCS)
	pandoc -st html5 $< > $@
