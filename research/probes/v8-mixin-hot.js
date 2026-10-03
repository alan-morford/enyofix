var a = {};
function m1(e, n, r) { var t; for (var l in n) t = n[l], a[l] !== t && (r.exists && !t || r.ignore && e[l] || (r.filter ? !r.filter(l, t, n, e, r) : 0) || (e[l] = t)); return e; }
var fil = function (k, v) { return typeof v != 'function'; };
var src = {x: 1, y: true, z: 0}, bad = 0, i, first = null;
for (i = 0; i < 20000; i++) { var r = m1({}, src, {filter: fil}); var s = JSON.stringify(r); if (first === null) first = s; if (s !== '{"x":1,"y":true,"z":0}') bad++; }
console.log("first=" + first + " bad=" + bad + "/20000 => " + (bad ? "BUG" : "OK"));
