
##############################
### VARIABLES
##############################

DEPS_DIR ?= deps

LIBBASE ?= $(DEPS_DIR)/libbase

CPPFLAGS += -I$(DEPS_DIR)

CFLAGS ?= -std=c11 -g \
          -Wall -Wextra -pedantic \
          -Wcomments -Wformat=2 -Wlogical-op -Wmissing-include-dirs \
          -Wnested-externs -Wold-style-definition -Wredundant-decls \
          -Wshadow -Wstrict-prototypes -Wunused-macros -Wvla -Wwrite-strings \
          -Wno-missing-field-initializers -Wno-override-init \
          -Wno-unused-parameter

TPLRENDER ?= $(DEPS_DIR)/tplrender/tplrender


test_libmaybe_types := ulong intmax ptr-ptr-char
test_libbase_types := $(test_libmaybe_types)

ulong_type           := ulong
ulong_options        := --typeclasses BOUNDED EQ ORD ENUM NUM \
                        --extra num_type=unsigned

intmax_type          := intmax_t
intmax_options       := --typeclasses BOUNDED EQ ORD ENUM NUM \
                        --extra num_type=signed

ptr_ptr_char_type    := char const * const *
ptr_ptr_char_options := --typeclasses EQ ORD

test_libbase_sources := $(foreach t,$(test_libbase_types),$(LIBBASE)/$t.c)
test_libbase_headers := $(test_libbase_sources:.c=.h)
test_libbase_objects := $(test_libbase_sources:.c=.o)

test_libmaybe_sources := $(foreach t,$(test_libmaybe_types),maybe_$t.c)
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

test_binaries := $(basename $(wildcard tests/*.c))

mkdeps := $(test_gen_objects:.o=.dep.mk)



##############################
### BUILDING
##############################

.PHONY: all
all: tests

.PHONY: tests
tests: $(test_binaries)

.PHONY: test
test: tests
	./tests/test

.PHONY: clean
clean:
	rm -rf $(test_gen) $(test_binaries) $(mkdeps)


%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -MMD -MF "$(@:.o=.dep.mk)" -c $< -o $@


tests/test: $(test_gen_objects)

name_from_path = $(subst -,_,$1)

$(test_libbase_headers): $(LIBBASE)/%.h: $(LIBBASE)/header.h.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libbase_sources): $(LIBBASE)/%.c: $(LIBBASE)/source.c.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libbase_objects): $(LIBBASE)/%.o: $(LIBBASE)/%.h

$(test_libmaybe_defs): def/maybe_%.h: def.h.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libmaybe_headers): maybe_%.h: header.h.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) -o $@

$(test_libmaybe_sources): maybe_%.c: source.c.jinja
	$(eval n := $(call name_from_path,$*))
	$(TPLRENDER) $< "$($(n)_type)" $($(n)_options) --sys-headers "libbase/$*.h" -o $@

$(test_libmaybe_objects): maybe_%.o: maybe_%.h def/maybe_%.h $(LIBBASE)/%.h


-include $(mkdeps)


