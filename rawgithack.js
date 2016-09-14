(function (doc) {
  "use strict";

  var TEMPLATES = [
    [/^(https?):\/\/gitlab\.com\/([^\/]+\/[^\/]+)\/(?:raw|blob)\/(.+\..+?)(?:\?.*)?$/i, '$1://gl.githack.com/$2/raw/$3'],
    [/^(https?):\/\/bitbucket\.org\/([^\/]+\/[^\/]+)\/(?:raw|src)\/(.+\..+?)(?:\?.*)?$/i, '$1://bb.githack.com/$2/raw/$3'],
    [/^(https?):\/\/raw\.github(?:usercontent)?\.com\/([^\/]+\/[^\/]+\/[^\/]+|[0-9A-Za-z-]+\/[0-9a-f]+\/raw)\/(.+\..+)/i, '$1://raw.githack.com/$2/$3'],
    [/^(https?):\/\/github\.com\/(.[^\/]+?)\/(.[^\/]+?)\/(?!releases\/)(?:(?:blob|raw)\/)?(.+?\/.+)/i, '$1://raw.githack.com/$2/$3/$4'],
    [/^(https?):\/\/gist\.github(?:usercontent)?\.com\/(.+?\/[0-9a-f]+\/raw\/(?:[0-9a-f]+\/)?.+\..+)$/i, '$1://gist.githack.com/$2']
  ];

  var prodEl = doc.getElementById('url-prod');
  var devEl  = doc.getElementById('url-dev');
  var urlEl  = doc.getElementById('url');

  new Clipboard('.url-copy-button');

  var devCopyButton  = doc.getElementById('url-dev-copy');
  var prodCopyButton = doc.getElementById('url-prod-copy');

  if (doc.queryCommandSupported && doc.queryCommandSupported('copy')) {
    devCopyButton.style.display  = 'inline-block';
    prodCopyButton.style.display = 'inline-block';
  }

  urlEl.addEventListener('input', formatURL, false);
  formatURL();

  function formatURL () {
    var url = urlEl.value = decodeURIComponent(urlEl.value.trim());

    urlEl.classList.remove('valid');
    urlEl.classList.toggle('invalid', url.length);
    devEl.value  = '';
    prodEl.value = '';
    devEl.classList.remove('valid');
    prodEl.classList.remove('valid');
    devCopyButton.disabled = true;
    prodCopyButton.disabled = true;

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
        devCopyButton.disabled = false;
        prodCopyButton.disabled = false;
        break;
      }
    }
  }

  prodEl.addEventListener('focus', onFocus);
  devEl.addEventListener('focus', onFocus);
  urlEl.addEventListener('focus', onFocus);

  function onFocus(e) {
    setTimeout(function () { e.target.select(); }, 1);
  }
}(document));
