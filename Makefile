SHELL=bash
include .make/Makefile

vignettes/startup-intro.md: OVERVIEW.md vignettes/incl/clean.css
	sed -E -i '/^(<!-- DO NOT EDIT THIS FILE|!\[|#+[[:space:]])/,$$d' $@
	echo "<!-- DO NOT EDIT THIS FILE! Edit 'OVERVIEW.md' instead and then rebuild this file with 'make vigs' -->" >> $@
	cat $< >> $@

vigns: vignettes/startup-intro.md

spelling:
	$(R_SCRIPT) -e "spelling::spell_check_package()"
	$(R_SCRIPT) -e "spelling::spell_check_files(c('NEWS', dir('vignettes', pattern='[.](md|rsp)$$', full.names=TRUE)), ignore=readLines('inst/WORDLIST', warn=FALSE))"

