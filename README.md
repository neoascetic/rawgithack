raw.githack.com
===============

This         is          the         source          code         behind
[raw.githack.com](https://raw.githack.com)  - CDN  for your  source code
that serves files with proper `Content-Type` headers.

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
