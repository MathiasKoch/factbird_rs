all:
	@$(MAKE) -f rust.mk
	@$(MAKE) -f application.mk

.PHONY: clean
clean:
	@$(MAKE) -f application.mk clean
	@$(MAKE) -f rust.mk clean

# .PHONY: flash debug ramdebug setup
# setup:
# 	@$(MAKE) -f application.mk $(MAKECMDGOALS)

# flash:
# 	@$(MAKE) -f application.mk flashburn

# debug:
# 	@$(MAKE) -f application.mk debug

# ramdebug:
# 	@$(MAKE) -f application.mk ramdebug
