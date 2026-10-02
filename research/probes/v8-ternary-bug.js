var out = [];
function T() { return true; }
function run() {
  var r = {filter: T};
  var e1 = {}; (r.filter ? !r.filter() : 0) || (e1.k = 1);
  var e2 = {}; ((true ? false : 0) || (e2.k = 1));
  var e3 = {}; var v = (r.filter ? !r.filter() : 0); v || (e3.k = 1);
  var e4 = {}; for (var l in {a: 1}) { (r.filter ? !r.filter() : 0) || (e4[l] = 1); }
  var e5 = {}; ((true ? false : 0) && 1) || (e5.k = 1);
  var e6 = {}; if ((true ? false : 0) || (e6.k = 1)) {}
  var x7 = ((true ? false : 0) || "rhs");
  return [e1.k, e2.k, e3.k, e4.a, e5.k, e6.k, x7].join(",");
}
var s = run();
var s2 = run(); // second call (possibly different compiler tier)
var ok = "1,1,1,1,1,1,rhs";
console.log("first=" + s + " second=" + s2 + " => " + (s === ok && s2 === ok ? "OK" : "BUG"));
