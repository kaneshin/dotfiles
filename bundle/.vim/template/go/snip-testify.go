import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// Test{{_input_:name}} runs
func Test{{_input_:name}}(t *testing.T) {
	assert := assert.New(t)
	_ = assert

	{{_cursor_}}
}
