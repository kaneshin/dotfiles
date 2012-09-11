var t, n;

n = 10000000;
t = (new Date).getTime();
for (var i = 0; i < n; ++i) {
	{{_cursor_}}
}
console.log((new Date).getTime() - t)

t = (new Date).getTime();
for (var i = 0; i < n; ++i) {
}
console.log((new Date).getTime() - t)
