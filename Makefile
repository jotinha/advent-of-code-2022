DAYS := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 
.PHONY: $(DAYS)
all: $(DAYS)
*:
	@echo -n $@,
ifdef RECOMPILE
	@$(MAKE) clean -s -C $@ 2> /dev/null || : 
endif
	@$(MAKE) -s -C $@ 2> err || (cat err && exit -1)
	@rm -f err
