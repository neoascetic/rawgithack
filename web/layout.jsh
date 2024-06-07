year="$(date +%Y)"

if [[ "$target" != index.html ]]; then
  canonical="${target%.*}"
fi

multiline layout << 'HTML'
<!doctype html>
<html lang="en">

<head>

<meta charset="utf-8">
<title>${title} | raw.githack.com</title>
<meta name="viewport" content="width=device-width">
<meta name="description" content="${description}">
<link rel="stylesheet" href="//rawcdn.githack.com/neoascetic/rawgithack/358bddc/web/rawgithack.css?min=1">

<link rel="canonical" href="https://raw.githack.com/${canonical}">
<link rel="search" type="application/opensearchdescription+xml" href="//rawcdn.githack.com/neoascetic/rawgithack/465ac52/web/opensearch.xml" title="raw.githack.com">
<link rel="icon" href="//rawcdn.githack.com/neoascetic/rawgithack/092e86b/web/sushi.svg">

</head>

<body>

<header class="hd">
  <h1 class="title">
    <img class="logo" src="//rawcdn.githack.com/neoascetic/rawgithack/092e86b/web/sushi.svg" alt="Logo icon">
    <a href="/">raw.githack.com</a>
  </h1>
  <nav class="nav">
    <ul>
      <li><a href="/faq">FAQ</a></li>
      <li><a href="/purge-cache">Purge cache</a></li>
      <li><a href="/faq#sponsorship">❤️</a></li>
    </ul>
  </nav>
</header>

<div><script async src="//cdn.carbonads.com/carbon.js?serve=CEADPK3U&placement=rawgithackcom" id="_carbonads_js"></script></div>

<div class="bd">
  <div class="content">

${content}

  </div>
</div>

<footer class="ft">
  <p>
    © <strong>2013 — ${year}</strong> Pavel Puchkin
    <br>
    <a href="http://thenounproject.com/noun/sushi/#icon-No14497">Sushi icon</a> designed by <a href="http://thenounproject.com/lnakanishi">Linda Yuki Nakanishi</a> from The Noun Project.
    <br>
    <a href="/faq">FAQ</a>
    <a href="/purge-cache">Purge cache</a>
    <a href="/faq#feedback">Report abuse</a>
    <a href="https://stats.uptimerobot.com/XAMJYh438n">Status page</a>
    <a href="https://github.com/neoascetic/rawgithack">Source code</a>
  </p>
</footer>


<script defer src="//rawcdn.githack.com/cdnjs/cdnjs/0971b44/ajax/libs/fetch/2.0.1/fetch.min.js?min=1"></script>
<script defer src="//rawcdn.githack.com/neoascetic/rawgithack/c162f69/web/rawgithack.js?min=1"></script>
<script defer src="https://static.cloudflareinsights.com/beacon.min.js" data-cf-beacon='{"token": "9fdcadef580f4335ad3c1e18bf166d0f"}'></script>

</body>
HTML
