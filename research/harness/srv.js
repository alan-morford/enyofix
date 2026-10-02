var http = require('http'), fs = require('fs'), root = '/media/internal/pw2test';
var types = {html: 'text/html', js: 'application/javascript', css: 'text/css', png: 'image/png', gif: 'image/gif', json: 'application/json'};
http.createServer(function (req, res) {
  var p = req.url.split('?')[0];
  if (p === '/log') { var b=''; req.setEncoding('utf8'); req.on('data', function (c) { b += c; }); req.on('end', function () { fs.writeFile(root + '/diag-' + (req.url.split('?')[1] || 'x') + '.txt', b); res.writeHead(200, {}); res.end('ok'); }); return; } if (p === '/') p = '/index.html';
  if (p.indexOf('..') >= 0) { res.writeHead(403, {}); res.end(); return; }
  fs.readFile(root + p, function (err, data) {
    if (err) { res.writeHead(404, {'Content-Type': 'text/plain'}); res.end('nf'); return; }
    res.writeHead(200, {'Content-Type': types[p.split('.').pop()] || 'application/octet-stream'});
    res.end(data);
  });
}).listen(8123, '127.0.0.1');
