use Test::Nginx::Socket 'no_plan';

use lib 't/lib';
use RawGitHack;

RawGitHack::setup();

run_tests();

__DATA__

=== index page works flawessly
--- request
GET /
--- response_body_like chomp
decade proven way to serve files

=== 404 returns HTML page
--- request
GET /not-found
--- error_code: 404
--- response_body_like chomp
Something is wrong. That's all we know.

=== /index.html redirects to /
--- request
GET /index.html
--- error_code: 301
--- response_headers
Location: http://raw.githack.com/

=== duplicate slashes are merged with a redirect
--- request
GET /user//repo///branch/file.js
--- error_code: 301
--- response_headers
Location: http://raw.githack.com/user//repo//branch/file.js

=== index page on a non-main host redirects to raw.githack.com
--- more_headers
Host: gl.githack.com
--- request
GET /?url=abc
--- error_code: 301
--- response_headers
Location: https://raw.githack.com/?url=abc

=== unknown host redirects to raw.githack.com
--- more_headers
Host: example.com
--- request
GET /user/repo/branch/file.js
--- error_code: 301
--- response_headers
Location: http://raw.githack.com/user/repo/branch/file.js

=== index page rejects non-GET methods
--- request
DELETE /
--- error_code: 403

=== file URL rejects methods other than GET and POST
--- request
DELETE /user/repo/branch/file.js
--- error_code: 403

=== POST to file URL is forbidden
--- request
POST /user/repo/branch/file.js
--- error_code: 403

=== unknown extension redirects to origin
--- request
GET /user/repo/branch/file.unknown
--- error_code: 301
--- response_headers
Location: https://raw.githubusercontent.com/user/repo/branch/file.unknown
X-Robots-Tag: none
Access-Control-Allow-Origin: *
Cache-Control: max-age=86400, public

=== internal pages are not directly accessible
--- request
GET /internal/error.html
--- error_code: 404

=== proxied dev file gets proper Content-Type and short cache
--- config
location = /user/repo/branch/dev.js { return 200 "mock"; }
--- request
GET /user/repo/branch/dev.js
--- response_headers
Content-Type: application/javascript; charset=utf-8
Cache-Control: max-age=60, public, stale-while-revalidate=60, stale-if-error=604800
X-Robots-Tag: none
Access-Control-Allow-Origin: *
--- response_body chomp
mock

=== proxied CDN file is cached permanently
--- config
location = /user/repo/branch/cdn.js { return 200 "mock"; }
--- more_headers
Host: rawcdn.githack.com
--- request
GET /user/repo/branch/cdn.js
--- response_headers
Content-Type: application/javascript; charset=utf-8
Cache-Control: max-age=31536000, public, immutable

=== binary types have no charset
--- config
location = /user/repo/branch/font.woff2 { return 200 "mock"; }
--- request
GET /user/repo/branch/font.woff2
--- response_headers
Content-Type: application/font-woff2

=== upstream headers are replaced
--- config
location = /user/repo/branch/hidden.js {
    add_header Set-Cookie "a=b";
    add_header Content-Security-Policy "default-src 'none'";
    add_header Cache-Control "no-cache";
    return 200 "mock";
}
--- request
GET /user/repo/branch/hidden.js
--- response_headers
!Set-Cookie
!Content-Security-Policy
Cache-Control: max-age=60, public, stale-while-revalidate=60, stale-if-error=604800

=== second request is served from cache
--- config
location ~* ^/user/repo/branch/cached-.*.js$ { return 200 "mock"; }
--- request eval
my $fn = rand(9999999);
["GET /user/repo/branch/cached-$fn.js", "GET /user/repo/branch/cached-$fn.js"]
--- response_headers eval
["X-Githack-Cache-Status: MISS", "X-Githack-Cache-Status: HIT"]

=== upstream 404 is replaced with error page
--- config
location = /user/repo/branch/missing.js { return 404 "nope"; }
--- request
GET /user/repo/branch/missing.js
--- error_code: 404
--- response_body_like chomp
Something is wrong. That's all we know.

=== upstream 500 is replaced with error page
--- config
location = /user/repo/branch/broken.js { return 500 "boom"; }
--- request
GET /user/repo/branch/broken.js
--- error_code: 500
--- response_body_like chomp
Something is wrong. That's all we know.
