var n = 10000;
var t = (new Date).getTime();
for (var i = 0; i < n; ++i) {
	{{_cursor_}}
}
console.log((new Date).getTime() - t);
