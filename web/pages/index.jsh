title="CDN for your source code"
description="raw.githack.com - ${title}"
multiline content << 'HTML'

<p class="hero">
  <strong title="Content Delivery Network">CDN</strong> for your source code
  <span class="desc">A decade proven way to serve files from source code hostings with proper <strong>Content-Type</strong> headers</span>
</p>

<div class="url-helper">
  <div class="url-paste">
    <form method="get" id="url-form">
      <label for="url" class="offscreen">URL:</label>
      <input id="url" class="url" type="url" name="url" value="<!--# echo var="arg_url" encoding="none" default="" -->" placeholder="Paste GitHub, Bitbucket, GitLab or sourcehut URL here" autofocus tabindex="1">
    </form>
  </div>

  <div class="column">
    <h2>Use this URL in <strong>production</strong></h2>
    <p class="url-container">
      <input id="url-prod" class="url" placeholder="https://rawcdn.githack.com/user/repo/tag/file" readonly tabindex="2">
      <button id="url-prod-copy" class="url-copy-button" data-clipboard-target="#url-prod" title="Copy URL" disabled>&#128203;</button>
    </p>
    <ul>
      <li><p>No traffic limits. Files are served via CloudFlare's CDN.
      <li><p>Files can be automatically optimized if you add <code>?min=1</code> query parameter.
      <li><p>Use a specific tag or commit hash in the URL (not a branch). Files are cached permanently based on the URL. Query string is ignored.
    </ul>
  </div>

  <div class="column">
    <h2>Use this URL for <strong>development</strong></h2>
    <p class="url-container">
      <input id="url-dev" class="url" placeholder="https://raw.githack.com/user/repo/branch/file" readonly tabindex="3">
      <button id="url-dev-copy" class="url-copy-button" data-clipboard-target="#url-dev" title="Copy URL" disabled>&#128203;</button>
    </p>
    <ul>
      <li><p>New changes you push will be reflected within minutes.</p>
      <li><p>Excessive traffic will be temporary redirected to corresponding CDN URLs.</p>
    </ul>
  </div>
</div>

<script defer src="//rawcdn.githack.com/zenorocha/document.queryCommandSupported/v1.0.0/dist/queryCommandSupported.min.js?min=1"></script>
<script defer src="//rawcdn.githack.com/zenorocha/clipboard.js/v1.5.10/dist/clipboard.min.js?min=1"></script>

HTML
