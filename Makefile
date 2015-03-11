
##############################
### VARIABLES
##############################

DEPS_DIR ?= ./deps

CPPFLAGS += -I$(DEPS_DIR)

cflags_std := -std=c11
cflags_warnings := -Wall -Wextra -pedantic \
                   -Wcomments -Wformat=2 -Wlogical-op -Wmissing-include-dirs \
                   -Wnested-externs -Wold-style-definition -Wredundant-decls \
                   -Wshadow -Wstrict-prototypes -Wunused-macros -Wvla \
                   -Wwrite-strings \
                   -Wno-missing-field-initializers -Wno-override-init \
                   -Wno-unused-parameter

CFLAGS ?= $(cflags_std) -g $(cflags_warnings)

templates := $(wildcard *.jinja)



##############################
### BUILDING
##############################

.PHONY: all
all: tests


.PHONY: fast
fast: CPPFLAGS += -DNDEBUG
fast: CFLAGS = $(cflags_std) -O3 $(cflags_warnings)
fast: all


.PHONY: test
test: tests
	@./tests/test

.PHONY: tests
tests: tests/test

tests/test: \
    tests/maybe/int.o \
    tests/maybe/ptr.o \
    $(DEPS_DIR)/libbase/int.o \
    $(DEPS_DIR)/libbase/ptr.o

int_type := int
ptr_type := void const *

.PRECIOUS: tests/maybe/%
tests/maybe/%.c: gentype $(templates)
	$(eval p := $(basename $*))
	$(eval n := $(subst -,_,$p))
	./gentype "$($(n)_type)" --typeclasses EQ ORD --type-func-header "libbase/$p.h" --output-dir tests/maybe


.PHONY: clean
clean:
	rm -rf tests/maybe/ tests/test


%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -MMD -MF "$(@:.o=.dep.mk)" -c $< -o $@


-include $(mkdeps)


