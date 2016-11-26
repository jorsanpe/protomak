include build_config.mk
include build_rules.mk
include test/framework/test.mk

all: pre-build $(TARGET)

# Commands to be run before the build
pre-build::

# Commands to be run after the build
post-build::

# Include here any custom clean command
clean::
	@$(RM) bin/*
	@find . -name '*.o' -exec rm -f {} \;
