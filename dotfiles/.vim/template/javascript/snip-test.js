var {{_name_}} = function() {
};

test{{_name_}}(,);

function test{{_name_}}(expect) {
	var result = {{_name_}}();
	if (result === expect) {
		console.log('OK:', result);
	}
	else {
		console.log('NG:', result);
	}
}
