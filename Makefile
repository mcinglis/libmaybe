
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
                   -Wno-override-init -Wno-unused-parameter

CFLAGS ?= $(cflags_std) -g $(cflags_warnings)

PYTHON ?= python

RENDER_JINJA_SCRIPT ?= $(DEPS_DIR)/render-jinja/render_jinja.py
RENDER_JINJA ?= $(PYTHON) $(RENDER_JINJA_SCRIPT)

uc = $(shell echo $(1) | tr [:lower:] [:upper:])

types := bool ord char schar uchar short ushort int uint long ulong \
         llong ullong int8 uint8 int16 uint16 int32 uint32 \
         intmax uintmax ptrdiff wchar size ptr ptrm

int8_type    := int8_t
uint8_type   := uint8_t
int16_type   := int16_t
uint16_type  := uint16_t
int32_type   := int32_t
uint32_type  := uint32_t
intmax_type  := intmax_t
uintmax_type := uintmax_t
ptrdiff_type := ptrdiff_t
wchar_type   := wchar_t
size_type    := size_t
ptr_type     := void const *
ptrm_type    := void *

common_typeclasses := EQ

prefix := maybe-
def_dir := def

name_to_def_path    = $(def_dir)/$(prefix)$1.h
name_to_header_path = $(prefix)$1.h
name_to_source_path = $(prefix)$1.c

gen_defs    := $(foreach t,$(types),$(call name_to_def_path,$t))
gen_headers := $(foreach t,$(types),$(call name_to_header_path,$t))
gen_sources := $(foreach t,$(types),$(call name_to_source_path,$t))

sources := $(gen_sources)
objects := $(sources:.c=.o)
mkdeps  := $(sources:.c=.dep.mk)



##############################
### BUILDING
##############################

.PHONY: all
all: $(objects)

.PHONY: fast
fast: CPPFLAGS += -DNDEBUG -DNO_ASSERT -DNO_REQUIRE -DNO_DEBUG
fast: CFLAGS = $(cflags_std) -O3 $(cflags_warnings)
fast: all


$(gen_defs) $(gen_headers) $(gen_sources): $(RENDER_JINJA_SCRIPT)

$(def_dir):
	mkdir -p $@

$(gen_defs): $(def_dir)/$(prefix)%.h: def.h.jinja | $(def_dir)
	$(eval n := $*)
	$(eval N := $(call uc,$n))
	$(RENDER_JINJA) $< "include_guard=LIBMAYBE_DEF_MAYBE_$N_H" "sys_headers=" "rel_headers=" "typename=$n" "funcname=$n" "type=$(or $($(n)_type),$n)" -o $@

$(gen_headers): $(prefix)%.h: header.h.jinja
	$(eval n := $*)
	$(eval N := $(call uc,$n))
	$(RENDER_JINJA) $< "include_guard=LIBMAYBE_MAYBE_$N_H" "sys_headers=" "rel_headers=$(call name_to_def_path,$n)" "type=$(or $($(n)_type),$n)" "macroname=$N" "typename=$n" "funcname=$n" "typeclasses=$(common_typeclasses) $($(n)_typeclasses)" -o $@

$(gen_sources): %.c: %.h
$(gen_sources): $(prefix)%.c: source.c.jinja
	$(eval n := $*)
	$(eval N := $(call uc,$n))
	$(RENDER_JINJA) $< "header=$(call name_to_header_path,$n)" "sys_headers=libbase/$n.h" "rel_headers=" "type=$(or $($(n)_type),$n)" "macroname=$N" "typename=$n" "funcname=$n" "typeclasses=$(common_typeclasses) $($(n)_typeclasses)" -o $@


$(objects): %.o: def/%.h


.PHONY: clean
clean:
	rm -rf $(def_dir) $(gen_sources) $(gen_headers) $(objects) $(mkdeps)


%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -MMD -MF "$(@:.o=.dep.mk)" -c $< -o $@


-include $(mkdeps)


