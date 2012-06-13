{{_input_:type}} *{{_input_:variable}};

{{_input_:variable}} = ({{_input_:type}} *)malloc(sizeof({{_input_:type}}) * {{_input_:size}});
{{_cursor_}}

if (NULL != {{_input_:variable}}) {
	free({{_input_:variable}});
	{{_input_:variable}} = NULL;
}
