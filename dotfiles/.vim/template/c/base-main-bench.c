#include <stdio.h>
#include <time.h>

int
main(int argc, char* argv[]) {
	clock_t t;
	int i, n;
	n = 100000000;

	t = clock();
	for (i = 0; i < n; ++i) {
        {{_cursor_}}
	}
	printf("%ld\n", clock() - t);

	t = clock();
	for (i = 0; i < n; ++i) {
		
	}
	printf("%d\n", clock() - t);

	return 0;
}

