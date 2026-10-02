window.__d3 = function (out, P) {
  var a = {};
  var fil = function (key, value) { return !(typeof value == 'function' || enyo.isInherited(value)) && enyo.concatenated.indexOf(key) === -1; };
  out.push("fil(_observing,true)=" + P(fil("_observing", true)) + " fil(_observeCount,0)=" + P(fil("_observeCount", 0)));
  // the minified mixin body, verbatim
  function m1(e, n, r) { var t; for (var l in n) t = n[l], a[l] !== t && (r.exists && !t || r.ignore && e[l] || (r.filter ? !r.filter(l, t, n, e, r) : 0) || (e[l] = t)); return e; }
  // unminified equivalent
  function m2(e, n, r) { var t; for (var l in n) { t = n[l]; if (a[l] !== t) { if ((!r.exists || t) && (!r.ignore || !e[l]) && (r.filter ? r.filter(l, t, n, e, r) : true)) e[l] = t; } } return e; }
  function m3(e, n, r) { var t; for (var l in n) { t = n[l]; var skip = (r.filter ? !r.filter(l, t, n, e, r) : 0); if (!skip) e[l] = t; } return e; }
  var T = function () { return true; };
  var src = {x: 1, y: true, z: 0};
  [["m1 filter=fil", m1, {filter: fil}], ["m2 filter=fil", m2, {filter: fil}], ["m3 filter=fil", m3, {filter: fil}],
   ["m1 filter=T", m1, {filter: T}], ["m1 nofilter", m1, {}], ["enyo.mixin filter=T", function (e, n, r) { return enyo.mixin(e, n, r); }, {filter: T}]].forEach(function (c) {
    var res = c[1]({}, src, c[2]); out.push(c[0] + " -> " + JSON.stringify(res));
  });
  // simplest shapes of the suspect expression
  var r = {filter: T}, e = {};
  (r.filter ? !r.filter() : 0) || (e.k = 1); out.push("ternary||assign: " + JSON.stringify(e));
  var e2 = {}; var v = (r.filter ? !r.filter() : 0); v || (e2.k = 1); out.push("split: " + JSON.stringify(e2));
  var e3 = {}; (false || (r.filter ? !r.filter() : 0) || (e3.k = 1)); out.push("false||ternary||assign: " + JSON.stringify(e3));
  var e4 = {}; (!T() || (e4.k = 1)); out.push("!call||assign: " + JSON.stringify(e4));
  var e5 = {}; ((true ? !T() : 0) || (e5.k = 1)); out.push("(true?!call:0)||assign: " + JSON.stringify(e5));
  var e6 = {}; ((true ? false : 0) || (e6.k = 1)); out.push("(true?false:0)||assign: " + JSON.stringify(e6));
  var x7 = (r.filter ? !r.filter() : 0); out.push("value of ternary = " + P(x7) + " typeof " + typeof x7);
};
