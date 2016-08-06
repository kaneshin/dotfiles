var buf bytes.Buffer
if err := json.NewEncoder(&buf).Encode(v); err != nil {
	{{_cursor_}}
}
