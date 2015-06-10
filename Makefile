
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
          -Wno-type-limits -Wno-unused-parameter

TPLRENDER ?= $(DEPS_DIR)/tplrender/tplrender


libmaybe_types := ulong intmax ptr_ptr_char
libbase_types := $(libmaybe_types)

ulong_type           := ulong
ulong_options        := --typeclasses NULL BOUNDED EQ ORD ENUM NUM FROM_STR \
                        --extra num_type=unsigned

intmax_type          := intmax_t
intmax_options       := --typeclasses NULL BOUNDED EQ ORD ENUM NUM FROM_STR \
                        --extra num_type=signed

ptr_ptr_char_type    := char const * const *
ptr_ptr_char_options := --typeclasses NULL EQ ORD

libbase_sources := $(foreach t,$(libbase_types),$(LIBBASE)/$t.c)
libbase_headers := $(libbase_sources:.c=.h)
libbase_objects := $(libbase_sources:.c=.o)

libmaybe_sources := $(foreach t,$(libmaybe_types),maybe_$t.c)
libmaybe_headers := $(libmaybe_sources:.c=.h)
libmaybe_defs    := $(addprefix def/,$(libmaybe_headers))
libmaybe_objects := $(libmaybe_sources:.c=.o)

gen_objects := $(libbase_objects) \
               $(libmaybe_objects)

gen := $(libbase_sources) \
       $(libbase_headers) \
       $(libmaybe_sources) \
       $(libmaybe_headers) \
       $(libmaybe_defs) \
       $(gen_objects)

test_binaries := $(basename $(wildcard tests/*.c))

mkdeps := $(gen_objects:.o=.dep.mk)



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
	rm -rf $(gen) $(test_binaries) $(mkdeps)


%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -MMD -MF "$(@:.o=.dep.mk)" -c $< -o $@


tests/test: $(gen_objects)


$(libbase_headers): $(LIBBASE)/%.h: $(LIBBASE)/header.h.jinja
	$(TPLRENDER) $< "$($(*)_type)" $($(*)_options) -o $@

$(libbase_sources): $(LIBBASE)/%.c: $(LIBBASE)/source.c.jinja
	$(TPLRENDER) $< "$($(*)_type)" $($(*)_options) -o $@

$(libbase_objects): $(LIBBASE)/%.o: $(LIBBASE)/%.h

$(libmaybe_defs): def/maybe_%.h: def.h.jinja
	$(TPLRENDER) $< "$($(*)_type)" $($(*)_options) -o $@

$(libmaybe_headers): maybe_%.h: header.h.jinja
	$(TPLRENDER) $< "$($(*)_type)" $($(*)_options) -o $@

$(libmaybe_sources): maybe_%.c: source.c.jinja
	$(TPLRENDER) $< "$($(*)_type)" $($(*)_options) --sys-headers "libbase/$*.h" -o $@

$(libmaybe_objects): maybe_%.o: maybe_%.h def/maybe_%.h $(LIBBASE)/%.h


-include $(mkdeps)


