include test/unit/test_cases.mk

UNIT = test/unit
UNITY_ROOT := test/framework/unity
CMOCK_ROOT := test/framework/cmock
MOCKS_ROOT := $(UNIT)/mocks
#MAKEFLAGS += --silent

ifeq ($(TESTS_TO_RUN),)
TEST_CASES := $(patsubst %.c, %, $(wildcard $(UNIT)/*.c))
else
TEST_CASES := $(patsubst %, $(UNIT)/%, $(TESTS_TO_RUN))
endif


ifneq (,$(findstring unit,$(MAKECMDGOALS)))

build_test_objects = $(eval OBJ_$(1)=$(patsubst %.c,%.o,$($(1))))
$(foreach test, $(notdir $(TEST_CASES)), $(call build_test_objects,$(test)))

CFLAGS += -I$(UNITY_ROOT)/src -I$(CMOCK_ROOT)/src -I$(UNIT)/mocks
$(CMOCK_ROOT)/src/cmock.c = -fno-strict-aliasing

ifneq ($(MOCK_HEADERS),)
MOCKS_LIB := $(MOCKS_ROOT)/libmock.a
MOCKS_SRC := $(patsubst %.h, $(MOCKS_ROOT)/Mock%.c, $(notdir $(MOCK_HEADERS)))
MOCKS_OBJ := $(patsubst %.c, %.o, $(MOCKS_SRC))

$(MOCKS_SRC): $(MOCK_HEADERS)
	@$(RM) -r $(MOCKS_ROOT)
	@mkdir $(MOCKS_ROOT)
	@ruby $(CMOCK_ROOT)/lib/cmock.rb -otest/framework/cmock_conf.yml --mock_path="$(MOCKS_ROOT)" $(MOCK_HEADERS)

$(MOCKS_LIB): $(MOCKS_OBJ)
	$(VAR)$(AR) cr $@ $(MOCKS_OBJ)
endif #($(MOCK_HEADERS),)


%.o: %.c $(UNIT)/test_cases.mk
	$(VCC)$(CC) -c $($<) $(CFLAGS) $< -o $@

.SECONDEXPANSION:
$(UNIT)/%_runner.c: $(UNIT)/%.c
	@ruby $(UNITY_ROOT)/auto/generate_test_runner.rb $< $@ > /dev/null
$(UNIT)/%: $$(OBJ_%) $(UNIT)/%.o $(UNIT)/%_runner.o $(UNITY_ROOT)/src/unity.o $(CMOCK_ROOT)/src/cmock.o $(MOCKS_LIB)
	$(VLD)$(CC) -o $@ $^ $(LDFLAGS)

$(UNITY_ROOT) $(CMOCK_ROOT):
	@git submodule init & git submodule update

unit: $(TEST_CASES) $(UNITY_ROOT) $(CMOCK_ROOT)
	@$(RM) .test_results.txt
	@for t in $(TEST_CASES); do \
		./$$t; \
	done | tee .test_results.txt;
	@ruby $(UNITY_ROOT)/auto/parseOutput.rb -xml .test_results.txt > /dev/null
	@$(RM) .test_results.txt

endif  # ifneq (,$(findstring unit,$(MAKECMDGOALS)))

clean::
	@$(RM) -f $(TEST_CASES)
	@$(RM) -r $(MOCKS_ROOT)
	@$(RM) report.xml

.PHONY: unit
