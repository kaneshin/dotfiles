{{_cursor_}}{{_input_:type}} *{{_input_:variable}};
unsigned int {{_input_:variable}}_size;
{{_input_:variable}}_size = sizeof({{_input_:type}}) * {{_input_:size}};

{{_input_:variable}} = ({{_input_:type}} *)malloc({{_input_:variable}}_size);

if (NULL != {{_input_:variable}}) {
	free({{_input_:variable}});
	{{_input_:variable}} = NULL;
}
