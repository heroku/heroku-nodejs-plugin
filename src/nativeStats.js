
// This file will be bundled by webpack, and webpack tries to bundle
// all require statements, but we need to require this at runtime.
// To work around this, webpack aliases the real `require` to
// `__not_webpack_require__`
var nativeStats = __non_webpack_require__('./heroku-nodejs-plugin.node');
exports.sense = nativeStats.sense;
exports.start = nativeStats.start;
exports.stop = nativeStats.stop;
