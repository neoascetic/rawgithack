title="Purge cache"
description="The page where you can purge cached URLs if you messed up"
multiline content << 'HTML'

<p class="hero" id="purge">
  <strong>Purge cache</strong>
  <span class="desc">
    Messed up and want your cache to be purged? You can do that with the form below.<br>
    Please note, that this feature is available only to our sponsors. Consider becoming one at our <a href="https://www.patreon.com/rawgithackcom">Patreon</a> page!<br>
    Up to 30 URLs per request.
  </span>
</p>

<form method="POST" action="/purge" class="purge" id="purge-form">
  <textarea required="true" name="files" placeholder="https://rawcdn.githack.com/user/repo/branch/file1.ext&#10;http://raw.githack.com/user/repo/branch/file2.ext&#10;..."></textarea>
  <input type="email" required="true" name="patron" placeholder="Your Patreon email">
  <div>
    <span class="wait">waiting</span>
    <span class="success hidden">success</span>
    <span class="error hidden">error</span>
  </div>
  <input type="submit" value="Send purge request">
</form>

<script defer src="//rawcdn.githack.com/jackmoore/autosize/master/dist/autosize.min.js?min=1"></script>

HTML
