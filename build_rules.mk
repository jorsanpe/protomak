.DEFAULT_GOAL := all

NON_BUILD_RULES := clean

## OS definitions
ifeq ($(OS),Windows_NT)
else
	UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OS := Linux
    else
        OS := OSX
    endif
endif

export ARCH

CC:=$(CROSS_COMPILE)gcc
C++:=$(CROSS_COMPILE)g++
CPP:=$(CROSS_COMPILE)cpp
AR:=$(CROSS_COMPILE)ar
OBJCOPY:=$(CROSS_COMPILE)objcopy
LD:=$(CROSS_COMPILE)ld

ifndef V
VCC=@echo '\tCC $<';
VLD=@echo '\tLD $@';
VAR=@echo '\tAR $@';
endif

BUILD_DIR := build/$(ARCH)

# Process all configuration defined parameters
TARGET := bin/$(NAME)
SRCS += $(filter-out $(EXCLUDED_FILES),$(foreach dir,$(SOURCE_PATHS),$(wildcard $(dir)/*.c)))
OBJS += $(addprefix $(BUILD_DIR)/, $(patsubst %.c,%.o,$(SRCS)))
INC += $(patsubst %,-I%,$(INCLUDE_PATHS))
SYMS += $(patsubst %,-D%,$(SYMBOLS))
ifeq ($(OS),Linux)
LIBS += -Wl,--start-group $(patsubst %,-l%,$(LIBRARIES)) -Wl,--end-group
else
LIBS += $(patsubst %,-l%,$(LIBRARIES))
endif
LIB_DIR += $(patsubst %,-L%,$(LIBRARY_PATHS))
OBJDIR += $(sort $(dir $(OBJS)))

LDFLAGS += $(LIB_DIR)
CFLAGS += $(INC) $(SYMS) -g -Wall -Werror

ifndef NOOPT
CFLAGS += -O2
endif


## Generate dependencies if not cleaning
ifneq (clean,$(MAKECMDGOALS))
$(BUILD_DIR)/dep.mk: $(SRCS)
	@mkdir -p $(BUILD_DIR)
	@for file in $(SRCS) ; do \
		$(CC) $(CFLAGS) -MM -MT $(BUILD_DIR)/`echo $$file | cut -d'.' -f1`.o $$file; \
	done > $@
-include $(BUILD_DIR)/dep.mk
endif


## Source file compilation
$(BUILD_DIR)/%.o: %.c build_config.mk
	$(VCC)$(CC) -c $($<) $(CFLAGS) $< -o $@

## Build information
$(TARGET).build:: $(OBJS)
	@mkdir -p bin
	@echo "\tDate:     `date '+%d/%m/%y %T'`" > $@
	@echo "\tName:     $(notdir $(TARGET))" >> $@
	@echo "\tArch:     $(ARCH)" >> $@
	@if [ -e .git ]; then \
		echo "\tRevision: `git rev-parse HEAD`" >> $@; \
	fi

$(OBJS): $(OBJDIR)

## Build directory creation
$(OBJDIR):
ifeq ($(findstring $(MAKECMDGOALS), $(NON_BUILD_RULES)),)
	@mkdir -p $@
endif


## Clean project
clean::
	@echo "Cleaning build..."
	@$(RM) -r build bin
ifneq ($(TARGET),)
	@rm -f $(TARGET) $(TARGET).build
endif
	@echo "> done"


## Target compilation
$(TARGET): $(OBJS) $(TARGET).build
	$(VLD)$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	@echo "> $@"
	@$(MAKE) --no-print-directory post-build

clean-all:: clean

.PHONY: clean $(TARGET).build
