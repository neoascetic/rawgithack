use Test::Nginx::Socket 'no_plan';

use lib 't/lib';
use RawGitHack;

my $port = $Test::Nginx::Util::ServerPort;

# The purge endpoint is rate limited per CF-Connecting-IP, so give every
# test its own address to keep them independent of each other.
my $n = 0;

# Fake credentials, written by Test::Nginx into servroot/html (user_files)
my $config_lua = <<'LUA';
>>> config.lua
return {
   cf = {
      zone = "test-zone",
      username = "test@example.com",
      api_key = "test-key"
   }
}
LUA

Test::Nginx::Util::add_block_preprocessor(sub {
  my $block = shift;

  # Cloudflare API goes to the mock server, `config` module is the fake one
  my $html_dir = $Test::Nginx::Util::HtmlDir;
  my $conf = $block->http_config;
  $conf =~ s{https://api\.cloudflare\.com}{http://127.0.0.1:$port}
    or die "Cloudflare API URL not found in http_config";
  $conf =~ s{lua_package_path\s+'[^']*';}{lua_package_path '$html_dir/?.lua;;';}
    or die "lua_package_path not found in http_config";
  $block->set_value("http_config", $conf);
  $block->set_value("user_files", $config_lua);

  my $more = $block->more_headers // '';
  $block->set_value("more_headers", $more . "CF-Connecting-IP: 10.0.0." . ++$n . "\n");
});

RawGitHack::setup();

run_tests();

__DATA__

=== missing url parameter is rejected
--- request
DELETE /purge
--- error_code: 400
--- response_body
missing url parameter

=== empty url parameter is rejected
--- request
DELETE /purge?url=
--- error_code: 400
--- response_body
missing url parameter

=== purge rejects methods other than DELETE
--- request eval
["GET /purge?url=x", "POST /purge?url=x"]
--- error_code eval
[403, 403]

=== purge sends a correct request to Cloudflare API
--- config
location = /client/v4/zones/test-zone/purge_cache {
    content_by_lua_block {
        ngx.req.read_body()
        local json = require("cjson.safe")
        local body = json.decode(ngx.req.get_body_data() or '')
        local h = ngx.req.get_headers()
        local ok = ngx.req.get_method() == 'POST'
            and h['content-type'] == 'application/json'
            and h['x-auth-email'] == 'test@example.com'
            and h['x-auth-key'] == 'test-key'
            and type(body) == 'table'
            and type(body.files) == 'table'
            and body.files[1] == 'https://raw.githack.com/user/repo/branch/file.js'
            and body.files[2] == nil
        ngx.say(json.encode({ success = ok and true or false }))
    }
}
--- request
DELETE /purge?url=https%3A%2F%2Fraw.githack.com%2Fuser%2Frepo%2Fbranch%2Ffile.js
--- error_code: 200

=== Cloudflare failure is reported as an error
--- config
location = /client/v4/zones/test-zone/purge_cache {
    return 200 '{"success":false}';
}
--- request
DELETE /purge?url=https%3A%2F%2Fraw.githack.com%2Fuser%2Frepo%2Fbranch%2Ffile.js
--- error_code: 400
--- response_body
CDN response error
--- error_log
CDN error: {"success":false}

=== non-JSON Cloudflare response is reported as an error
--- config
location = /client/v4/zones/test-zone/purge_cache {
    return 200 'not json';
}
--- request
DELETE /purge?url=https%3A%2F%2Fraw.githack.com%2Fuser%2Frepo%2Fbranch%2Ffile.js
--- error_code: 400
--- response_body
CDN response error
--- error_log
CDN error: not json

=== purge is rate limited
--- request eval
[("DELETE /purge") x 7]
--- error_code eval
[(400) x 6, 429]
