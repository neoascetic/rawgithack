use Test::Nginx::Socket 'no_plan';

use_hup();
no_root_location();

add_block_preprocessor(sub {
  my $block = shift;
  $block->set_value("http_config", "include /etc/nginx/rawgithack/rawgithack.conf;");
  $block->set_value("config", "");
  $block->set_value(
    "more_headers",
    "Host: raw.githack.com\n" . ($block->more_headers // ''));
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