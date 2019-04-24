# Makefile for building the NIF
#
# Makefile targets:
#
# all/install   build and install the NIF
# clean         clean build products and intermediates
#
# Variables to override:
#
# MIX_COMPILE_PATH path to the build's ebin directory
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# ERL_CFLAGS	additional compiler flags for files using Erlang header files
# ERL_EI_INCLUDE_DIR include path to ei.h (Required for crosscompile)
# ERL_EI_LIBDIR path to libei.a (Required for crosscompile)
# LDFLAGS	linker flags for linking all binaries
# ERL_LDFLAGS	additional linker flags for projects referencing Erlang libraries

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
LDFLAGS += -fPIC -shared
endif

ifeq ($(shell uname -s),Linux)
    YACC=bison
    YFLAGS=
else
    # Use Homebrew's GNU bison install
    YACC=/usr/local/opt/bison/bin/bison

    # Ugh. Force yacc to output to the src directory
    YFLAGS="-o $(PLY_TOP)/src/lang/parse.c"
endif
CFLAGS += -I$(BUILD)/src/lang -I$(PLY_TOP)/src/lang

calling_from_make:
	mix compile

all: install

install: $(BUILD)/Makefile
	make -C $(BUILD) install

$(PLY_TOP)/configure: $(PLY_TOP)/autogen.sh $(PLY_TOP)/configure.ac
	cd $(PLY_TOP) && ./autogen.sh

$(BUILD)/Makefile: $(BUILD) $(PLY_TOP)/configure
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
