import "github.com/stretchr/testify/assert"

func Test_{{_input_:name}}(t *testing.T) {
	assert := assert.New(t)
	assert.True(true)

	{{_cursor_}}
}
