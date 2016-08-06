buf := bytes.NewBuffer([]byte(""))
if err := json.NewDecoder(&buf).Decode(v); err != nil {
	{{_cursor_}}
}
