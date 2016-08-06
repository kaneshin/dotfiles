package {{_name_}}

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFoo(t *testing.T) {
	assert := assert.New(t)

	{{_cursor_}}
}
