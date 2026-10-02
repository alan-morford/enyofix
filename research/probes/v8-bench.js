function now() { return new Date().getTime(); }
function fib(n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }
function objs() { var a = []; for (var i = 0; i < 30000; i++) a.push({x: i, y: String(i), z: [i, i + 1]}); var s = 0; for (var j = 0; j < a.length; j++) s += a[j].x + a[j].z[1]; return s; }
function strs() { var s = ""; for (var i = 0; i < 8000; i++) s += i.toString(36); return s.split("a").join("b").length; }
function mix() { var o = {}; for (var i = 0; i < 100000; i++) { o["k" + (i % 500)] = (o["k" + (i % 500)] || 0) + i; } var t = 0; for (var k in o) t += o[k]; return t; }
var res = [];
[["fib(25)", function () { return fib(25); }], ["objects", objs], ["strings", strs], ["dict", mix]].forEach(function (b) {
  var t = now(); b[1](); res.push(b[0] + "=" + (now() - t) + "ms");
});
console.log(res.join(" "));
