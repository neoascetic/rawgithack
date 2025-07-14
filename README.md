raw.githack.com
===============

This         is          the         source          code         behind
[raw.githack.com](https://raw.githack.com)  - CDN  for your  source code
that serves files with proper `Content-Type` headers.

Supported Platforms
-------------------

raw.githack.com supports the following source code hosting platforms:

- **[GitHub](https://github.com)** - served via `raw.githack.com` subdomain
- **[GitHub Gist](https://gist.github.com)** - served via `gist.githack.com` subdomain
- **[GitLab](https://gitlab.com)** - served via `gl.githack.com` subdomain
- **[Bitbucket](https://bitbucket.org)** - served via `bb.githack.com` subdomain
- **[Gitea](https://gitea.com)** - served via `gitea.githack.com` subdomain
- **[Codeberg](https://codeberg.org)** - served via `codeberg.githack.com` subdomain
- **[SourceHut Git](https://git.sr.ht)** - served via `srht.githack.com` subdomain
- **[SourceHut Mercurial](https://hg.sr.ht)** - served via `srhgt.githack.com` subdomain

Both development and production (CDN) URLs are available for each platform.

Example config.lua
------------------

```lua
return {
   simsim = "SECRET",
   cf = {
      zone = "ZONE_ID",
      username = "USERNAME",
      api_key = "API_KEY",
      username = "USERNAME"
   },
   patreon = {
      campaign = "CAMPAIGN_ID",
      token = "ACCESS_TOKEN"
   }
}
```

Frontend
--------

Pages are built  using [jopa](https://github.com/neoascetic/jopa) static
site generator, with the following command:

```bash
layout_file="web/layout.jsh" from="web/pages" jopa
```
