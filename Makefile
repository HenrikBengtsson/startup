include .make/Makefile

vignettes/startup-intro.md: OVERVIEW.md vignettes/incl/clean.css
	sed -i '/%\\Vignette/!d' $@
	cat $< >> $@

vigs: vignettes/startup-intro.md
