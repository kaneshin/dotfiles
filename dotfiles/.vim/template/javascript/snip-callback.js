var foo = {
  bar: 10,
  baz: function(num, callback) {
    callback(num * num);
  },
  qux: function(num, callback) {
    var self = this;
    this.baz(num, function(res) { 
      callback(res + self.bar);
    });
  }
};
foo.qux(5, function(res) {
  console.log(res);
});
