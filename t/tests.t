use Test::Nginx::Socket 'no_plan';

use_hup();
no_root_location();

add_block_preprocessor(sub {
  my $block = shift;
  $block->set_value("http_config", "include /etc/nginx/rawgithack/rawgithack.conf;");
  $block->set_value("config", "");
  my $more = $block->more_headers // '';
  $block->set_value(
    "more_headers",
    ($more =~ /^Host:/mi ? '' : "Host: raw.githack.com\n") . $more);
});

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

=== HTML file returns phishing warning if requested from browser
--- more_headers
Sec-Fetch-Dest: document
--- request
GET /user/repo/branch/index.html
--- response_body_like chomp
Not sure about the source?

=== directory URL is rewritten to index.html and shows phishing warning
--- more_headers
Sec-Fetch-Dest: document
--- request
GET /user/repo/branch/
--- response_body_like chomp
Not sure about the source?

=== /index.html redirects to /
--- request
GET /index.html
--- error_code: 301
--- response_headers_like
Location: ^http://raw\.githack\.com/$

=== duplicate slashes are merged with a redirect
--- request
GET /user//repo///branch/file.js
--- error_code: 307
--- response_headers_like
Location: ^/user/repo/branch/file\.js$

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
GET /foo?x=1
--- error_code: 301
--- response_headers_like
Location: ^http://raw\.githack\.com/foo\?x=1$

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

=== POST from the phishing notice sets cookie and redirects back
--- more_headers
Referer: http://raw.githack.com/user/repo/branch/index.html
--- request
POST /user/repo/branch/index.html
--- error_code: 303
--- response_headers_like
Location: ^https://raw\.githack\.com/user/repo/branch/index\.html$
Cache-Control: ^no-store$
Set-Cookie: ^__Http-phish=1; Path=/user/repo/; Max-Age=86400; SameSite=Lax; HttpOnly; Secure$

=== POST with foreign referer does not set phishing cookie
--- more_headers
Referer: http://evil.example.com/user/repo/branch/index.html
--- request
POST /user/repo/branch/index.html
--- error_code: 403
--- response_headers
Set-Cookie:

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
