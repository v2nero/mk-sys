PHONY += all clean cleanall build_all rebuild

all : build_all

ifeq ($(VERBOSE),1)
Q :=
else
Q :=@
endif

include scripts/defination.mk

#include ...


PHONY += $(BUILD_MODULES)

build_all : $(BUILD_MODULES)

rebuild: clean all

clean:
	$(Q)$(RM) $(CLEAN_TGTS)

cleanall:
	$(Q)$(RM) $(CLEANALL_TGTS)

.PHONY : $(PHONY)
