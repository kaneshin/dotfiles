func Benchmark_{{_input_:name}}(b *testing.B) {
	for n := 0; n < b.N; n++ {
		{{_cursor_}}
	}
}
