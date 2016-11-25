#include <unity.h>

#include <Mockmodule.h>

void setUp(void)
{
    Mockmodule_Init();
}

void tearDown(void)
{
    Mockmodule_Verify();
}

void test_framework_is_ok(void)
{
    int ret;

    Module_ExpectAndReturn(5, 0);
    ret = Module(5);
    TEST_ASSERT_EQUAL_INT(0, ret);
}
