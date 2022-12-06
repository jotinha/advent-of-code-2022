DAYS := 1 2 3 4 5 6 

.PHONY: $(DAYS)
all: $(DAYS)
*:
	@echo -n $@,
	@$(MAKE) -s -C $@
