include .make/Makefile

vignettes/startup-intro.md: OVERVIEW.md
	sed -i '/%\\Vignette/!d' $@
	cat $< >> $@

vigs: vignettes/startup-intro.md
