#include <CUnit/CUnit.h>
#include <CUnit/Console.h>

void
test_{{_input_:name}}(void)
{
	{{_cursor_}}
}

int
main(int argc, char* argv[])
{
	CU_pSuite {{_input_:name}}_suite;
	CU_initialize_registry();

	{{_input_:name}}_suite = CU_add_suite("{{_input_:name}} TestSuite", NULL, NULL);
	CU_add_test({{_input_:name}}_suite, "{{_input_:name}} Test", test_{{_input_:name}});

	CU_console_run_tests();
	CU_cleanup_registry();

	return 0;
}

