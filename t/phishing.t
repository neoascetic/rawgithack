use Test::Nginx::Socket 'no_plan';

use lib 't/lib';
use RawGitHack;

RawGitHack::setup();

run_tests();

__DATA__

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

=== phishing warning is not cacheable
--- more_headers
Sec-Fetch-Dest: document
--- request
GET /user/repo/branch/warning-headers.html
--- response_headers
Cache-Control: no-store
Vary: Cookie

=== POST from the phishing notice sets cookie and redirects back
--- more_headers
Referer: http://raw.githack.com/user/repo/branch/index.html
--- request
POST /user/repo/branch/index.html
--- error_code: 303
--- response_headers
Location: https://raw.githack.com/user/repo/branch/index.html
Cache-Control: no-store
Set-Cookie: __Http-phish=1; Path=/user/repo/; Max-Age=86400; SameSite=Lax; HttpOnly; Secure

=== POST with foreign referer does not set phishing cookie
--- more_headers
Referer: http://evil.example.com/user/repo/branch/index.html
--- request
POST /user/repo/branch/index.html
--- error_code: 403
--- response_headers
!Set-Cookie

=== HTML file is served if phishing cookie is set
--- config
location = /user/repo/branch/with-cookie.html { return 200 "<p>mock</p>"; }
--- more_headers
Sec-Fetch-Dest: document
Cookie: __Http-phish=1
--- request
GET /user/repo/branch/with-cookie.html
--- response_headers
Content-Type: text/html; charset=utf-8
--- response_body chomp
<p>mock</p>

=== HTML file is served if phishing cookie is among others
--- config
location = /user/repo/branch/with-cookies.html { return 200 "<p>mock</p>"; }
--- more_headers
Sec-Fetch-Dest: document
Cookie: a=b; __Http-phish=1; c=d
--- request
GET /user/repo/branch/with-cookies.html
--- response_body chomp
<p>mock</p>

=== HTML file is served if not requested as a document
--- config
location = /user/repo/branch/iframe.html { return 200 "<p>mock</p>"; }
--- more_headers
Sec-Fetch-Dest: iframe
--- request
GET /user/repo/branch/iframe.html
--- response_body chomp
<p>mock</p>

=== HTML file is served if Sec-Fetch-Dest is absent
--- config
location = /user/repo/branch/no-header.html { return 200 "<p>mock</p>"; }
--- request
GET /user/repo/branch/no-header.html
--- response_body chomp
<p>mock</p>

=== non-HTML file is served without warning even for document requests
--- config
location = /user/repo/branch/doc.js { return 200 "mock"; }
--- more_headers
Sec-Fetch-Dest: document
--- request
GET /user/repo/branch/doc.js
--- response_body chomp
mock
