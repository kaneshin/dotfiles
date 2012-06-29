#include <stdio.h>
#include <time.h>

int
main(int argc, char* argv[]) {
	int i, n;
	clock_t t;
	n = 100000000;

	t = clock();
	for (i = 0; i < n; ++i) {
		{{_cursor_}}
	}
	printf("%ld\n", clock() - t);

	t = clock();
	for (i = 0; i < n; ++i) {
	}
	printf("%ld\n", clock() - t);

	return 0;
}

