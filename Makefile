# Build an Autoconf package
#
# Makefile targets:
#
# all/install   build and install the package
# clean         clean build products and intermediates
#
# Variables to override:
#
# MIX_COMPILE_PATH path to the build's ebin directory
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# LDFLAGS	linker flags for linking all binaries

TOP := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PLY_TOP = $(TOP)/ply

PREFIX = $(MIX_COMPILE_PATH)/../priv
BUILD  = $(MIX_COMPILE_PATH)/../obj

GNU_TARGET_NAME=$(notdir $(CROSSCOMPILE))
GNU_HOST_NAME=

# Check that we're on a supported build platform
ifeq ($(CROSSCOMPILE),)
    # Not crosscompiling, so check that we're on Linux.
    ifneq ($(shell uname -s),Linux)
        $(warning ply only works on Nerves and Linux platforms.)
    else
    endif
else
# Crosscompiled build
endif

ifeq ($(shell uname -s),Linux)
    YACC=bison
else
    # Use Homebrew's GNU bison install
    YACC=/usr/local/opt/bison/bin/bison
endif
CFLAGS += -I$(BUILD)/src/lang -I$(PLY_TOP)/src/lang

# Ugh. Force yacc to output to the src directory
YFLAGS="-o $(PLY_TOP)/src/lang/parse.c"

calling_from_make:
	mix compile

all: install

install: $(BUILD) $(PREFIX) $(BUILD)/Makefile
	make -C $(BUILD) install

$(PLY_TOP)/autogen.sh:
	git -C $(TOP) submodule update --init --recursive

$(PLY_TOP)/configure: $(PLY_TOP)/autogen.sh $(PLY_TOP)/configure.ac
	cd $(PLY_TOP) && ./autogen.sh

$(BUILD)/Makefile: $(PLY_TOP)/configure
	cd $(BUILD) && \
	    YACC=$(YACC) YFLAGS=$(YFLAGS) CFLAGS="$(CFLAGS)" $(PLY_TOP)/configure \
	    --prefix=$(PREFIX) \
	    --target=$(GNU_TARGET_NAME) \
            --host=$(GNU_TARGET_NAME) \
            --build=$(GNU_HOST_NAME)

$(PREFIX) $(BUILD):
	mkdir -p $@

clean:
	$(RM) -r $(BUILD)

.PHONY: all clean calling_from_make install
