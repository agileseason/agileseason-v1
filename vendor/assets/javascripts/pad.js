Number.prototype.pad = function(size) {
  var s = String(this);
  while (s.length < (size || 2)) { s = '0' + s; }
  return s;
};
