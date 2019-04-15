(function (doc) {
  "use strict";

  const GITHUB_API_URL = 'https://api.github.com';

  const TEMPLATES = [
    [/^(https?):\/\/gitlab\.com\/([^\/]+.*\/[^\/]+)\/(?:raw|blob)\/(.+?)(?:\?.*)?$/i,
     '$1://gl.githack.com/$2/raw/$3'],
    [/^(https?):\/\/bitbucket\.org\/([^\/]+\/[^\/]+)\/(?:raw|src)\/(.+?)(?:\?.*)?$/i,
     '$1://bb.githack.com/$2/raw/$3'],

    // snippet file URL from web interface, with revision
    [/^(https?):\/\/bitbucket\.org\/snippets\/([^\/]+\/[^\/]+)\/revisions\/([^\/\#\?]+)(?:\?[^#]*)?(?:\#file-(.+?))$/i,
     '$1://bb.githack.com/!api/2.0/snippets/$2/$3/files/$4'],
    // snippet file URL from web interface, no revision
    [/^(https?):\/\/bitbucket\.org\/snippets\/([^\/]+\/[^\/\#\?]+)(?:\?[^#]*)?(?:\#file-(.+?))$/i,
     '$1://bb.githack.com/!api/2.0/snippets/$2/HEAD/files/$3'],
    // snippet file URLs from REST API
    [/^(https?):\/\/bitbucket\.org\/\!api\/2.0\/snippets\/([^\/]+\/[^\/]+\/[^\/]+)\/files\/(.+?)(?:\?.*)?$/i,
     '$1://bb.githack.com/!api/2.0/snippets/$2/files/$3'],
    [/^(https?):\/\/api\.bitbucket\.org\/2.0\/snippets\/([^\/]+\/[^\/]+\/[^\/]+)\/files\/(.+?)(?:\?.*)?$/i,
     '$1://bb.githack.com/!api/2.0/snippets/$2/files/$3'],

    // welcome rawgit refugees
    [/^(https?):\/\/(?:cdn\.)?rawgit\.com\/(.+?\/[0-9a-f]+\/raw\/(?:[0-9a-f]+\/)?.+)$/i,
     '$1://gist.githack.com/$2'],
    [/^(https?):\/\/(?:cdn\.)?rawgit\.com\/([^\/]+\/[^\/]+\/[^\/]+|[0-9A-Za-z-]+\/[0-9a-f]+\/raw)\/(.+)/i,
     '$1://raw.githack.com/$2/$3'],

    // ...and maybe gitcdn.xyz? ;)
    [/^(https?):\/\/gitcdn\.(?:xyz|link)\/[^\/]+\/(.+?\/[0-9a-f]+\/raw\/(?:[0-9a-f]+\/)?.+)$/i,
     '$1://gist.githack.com/$2'],
    [/^(https?):\/\/gitcdn\.(?:xyz|link)\/[^\/]+\/([^\/]+\/[^\/]+\/[^\/]+|[0-9A-Za-z-]+\/[0-9a-f]+\/raw)\/(.+)/i,
     '$1://raw.githack.com/$2/$3'],

    [/^(https?):\/\/raw\.github(?:usercontent)?\.com\/([^\/]+\/[^\/]+\/[^\/]+|[0-9A-Za-z-]+\/[0-9a-f]+\/raw)\/(.+)/i,
     '$1://raw.githack.com/$2/$3'],
    [/^(https?):\/\/github\.com\/(.[^\/]+?)\/(.[^\/]+?)\/(?!releases\/)(?:(?:blob|raw)\/)?(.+?\/.+)/i,
     '$1://raw.githack.com/$2/$3/$4'],
    [/^(https?):\/\/gist\.github(?:usercontent)?\.com\/(.+?\/[0-9a-f]+\/raw\/(?:[0-9a-f]+\/)?.+)$/i,
     '$1://gist.githack.com/$2']
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

  if (/(iPhone|iPad|iPod)/i.test(navigator.userAgent)) {
    // On iOS, it's quite difficult to copy the value of readonly input elements (see https://git.io/vpI8Z).
    // By making the inputs non-readonly and preventing keydown we can mimic the behaviour of readonly inputs while
    // improving the copy-input-value interaction.
    inputDev.removeAttribute('readonly')
    inputProd.removeAttribute('readonly')
    inputDev.addEventListener('keydown', function (e) {
      e.preventDefault();
    });
    inputProd.addEventListener('keydown', function (e) {
      e.preventDefault();
    });
  }

  formatURL();

  function formatURL() {
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
        var ghUrl = url.replace(pattern, template);
        var matches = ghUrl.match(/^(\w+:\/\/(raw).githack.com\/([^\/]+)\/([^\/]+))\/([^\/]+)\/(.*)/i);
        if (!matches) {
          devEl.value = ghUrl;
          prodEl.value = cdnize(ghUrl);
          setValid();
        } else if (matches[2] === 'raw') {
          devEl.value = ghUrl;
          let apiUrl = `${GITHUB_API_URL}/repos/${matches[3]}/${matches[4]}/git/refs/heads/${matches[5]}`;
          fetch(apiUrl)
            .then(res => { if (res.ok) return res.json(); })
            .then(data => {
              let ref = data && data.object && data.object.sha ? data.object.sha : matches[5];
              prodEl.value = cdnize(`${matches[1]}/${ref}/${matches[6]}`);
              setValid();
            });
        }
        break;
      }
    }
  }

  function cdnize(url) {
    return url.replace(/^(\w+):\/\/(\w+)/, "$1://$2cdn");
  }

  function setValid() {
    urlEl.classList.remove('invalid');
    urlEl.classList.add('valid');
    prodEl.classList.add('valid');
    devEl.classList.add('valid');
    devCopyButton.disabled = false;
    prodCopyButton.disabled = false;
  }

  prodEl.addEventListener('focus', onFocus);
  devEl.addEventListener('focus', onFocus);
  urlEl.addEventListener('focus', onFocus);

  function onFocus(e) {
    setTimeout(function () { e.target.select(); }, 1);
  }

  autosize(doc.querySelector('textarea'));

}(document));
