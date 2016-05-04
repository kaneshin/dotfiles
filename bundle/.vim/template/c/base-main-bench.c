#include <stdio.h>
#include <time.h>

static long n = 10000; 

int
main(int argc, char* argv[]) {
	long i;
	clock_t t;

	t = clock();
	for (i = 0; i < n; ++i) {
            {{_cursor_}}
	}
	printf("%ld\n", clock() - t);

	return 0;
}
