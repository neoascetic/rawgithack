(function (doc) {
  "use strict";

  var TEMPLATES = [
    [/^(https?):\/\/bitbucket\.org\/([^\/]+\/[^\/]+)\/(?:raw|src)\/(.+\..+?)(?:\?.*)?$/i, '$1://bb.githack.com/$2/raw/$3'],
    [/^(https?):\/\/raw\.github(?:usercontent)?\.com\/([^\/]+\/[^\/]+\/[^\/]+|[0-9A-Za-z-]+\/[0-9a-f]+\/raw)\/(.+\..+)/i, '$1://raw.githack.com/$2/$3'],
    [/^(https?):\/\/github\.com\/(.[^\/]+?)\/(.[^\/]+?)\/(?!releases\/)(?:(?:blob|raw)\/)?(.+?\/.+)/i, '$1://raw.githack.com/$2/$3/$4'],
    [/^(https?):\/\/gist\.github(?:usercontent)?\.com\/(.+?\/[0-9a-f]+\/raw\/(?:[0-9a-f]+\/)?.+\..+)$/i, '$1://gist.githack.com/$2']
  ];

  var prodEl = doc.getElementById('url-prod');
  var devEl  = doc.getElementById('url-dev');
  var urlEl  = doc.getElementById('url');

  urlEl.addEventListener('input', function () {
    var url = urlEl.value.trim();

    urlEl.classList.remove('valid');
    urlEl.classList.toggle('invalid', url.length);
    devEl.value  = '';
    prodEl.value = '';
    devEl.classList.remove('valid');
    prodEl.classList.remove('valid');

    for (var i in TEMPLATES) {
      var pattern = TEMPLATES[i][0],
          template = TEMPLATES[i][1];

      if (pattern.test(url)) {
        urlEl.classList.remove('invalid');
        urlEl.classList.add('valid');
        prodEl.value = url.replace(pattern, template.replace(/\$1:\/\/(\w+)/, '$$1://$1cdn'));
        devEl.value  = url.replace(pattern, template);
        prodEl.classList.add('valid');
        devEl.classList.add('valid');
        break;
      }
    }
  }, false);

  prodEl.addEventListener('focus', onFocus);
  devEl.addEventListener('focus', onFocus);
  urlEl.addEventListener('focus', onFocus);

  function onFocus(e) {
    setTimeout(function () { e.target.select(); }, 1);
  }
}(document));
