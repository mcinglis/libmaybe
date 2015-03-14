
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

TPLRENDER ?= $(DEPS_DIR)/tplrender/tplrender


name_from_path = $(subst -,_,$(basename $(notdir $1)))


test_types := ulong intmax ptr-ptr-char

ulong_type           := ulong
ulong_options        := --typeclasses BOUNDED EQ ORD ENUM NUM \
                        --extra num_type=unsigned

intmax_type          := intmax_t
intmax_options       := --typeclasses BOUNDED EQ ORD ENUM NUM \
                        --extra num_type=signed

ptr_ptr_char_type    := char const * const *
ptr_ptr_char_options := --typeclasses EQ ORD

test_libbase_sources := $(foreach t,$(test_types),$(DEPS_DIR)/libbase/$t.c)
test_libbase_headers := $(test_libbase_sources:.c=.h)
test_libbase_objects := $(test_libbase_sources:.c=.o)

test_libmaybe_sources := $(foreach t,$(test_types),maybe-$t.c)
test_libmaybe_headers := $(test_libmaybe_sources:.c=.h)
test_libmaybe_defs    := $(addprefix def/,$(test_libmaybe_headers))
test_libmaybe_objects := $(test_libmaybe_sources:.c=.o)

test_gen_objects := $(test_libbase_objects) \
                    $(test_libmaybe_objects)

test_gen := $(test_libbase_sources) \
            $(test_libbase_headers) \
            $(test_libmaybe_sources) \
            $(test_libmaybe_headers) \
            $(test_libmaybe_defs) \
            $(test_gen_objects)

test_binaries := tests/test

mkdeps := $(test_gen_objects:.o=.dep.mk)



##############################
### BUILDING
##############################

.PHONY: all
all: tests

.PHONY: fast
fast: CPPFLAGS += -DNDEBUG
fast: CFLAGS = $(cflags_std) -O3 $(cflags_warnings)
fast: all

.PHONY: tests
tests: $(test_binaries)

.PHONY: test
test: tests/test
	./tests/test

.PHONY: clean
clean:
	rm -rf $(test_gen) $(test_binaries) $(mkdeps)


%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -MMD -MF "$(@:.o=.dep.mk)" -c $< -o $@


tests/test: $(test_gen_objects)

$(test_libbase_headers): %.h: $(DEPS_DIR)/libbase/header.h.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libbase_sources): %.c: $(DEPS_DIR)/libbase/source.c.jinja %.h
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libmaybe_defs): def/maybe-%.h: def.h.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libmaybe_headers): maybe-%.h: header.h.jinja def/maybe-%.h
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libmaybe_sources): maybe-%.c: source.c.jinja maybe-%.h $(DEPS_DIR)/libbase/%.h
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) --sys-headers "libbase/$*.h" -o $@


-include $(mkdeps)


