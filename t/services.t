use Test::Nginx::Socket 'no_plan';

use lib 't/lib';
use RawGitHack;

RawGitHack::setup();

# Every service host requests the same file; only the Host differs.
# The mock upstream answers with the origin the request was routed to
# (empty origin means unknown host, so the mock fails with 502).
Test::Nginx::Util::add_block_preprocessor(sub {
  my $block = shift;
  my ($host) = ($block->more_headers // '') =~ /^Host:\s*(\S+)/mi;
  $block->set_value("config", "location = /user/repo/branch/file.js { return 200 'mock'; }");
  $block->set_value("request", "GET /user/repo/branch/file.js");
  $block->set_value("response_body", "mock");
});

run_tests();

__DATA__

=== raw.githack.com serves files
--- more_headers
Host: raw.githack.com

=== rawcdn.githack.com serves files
--- more_headers
Host: rawcdn.githack.com

=== gist.githack.com serves files
--- more_headers
Host: gist.githack.com

=== gistcdn.githack.com serves files
--- more_headers
Host: gistcdn.githack.com

=== gl.githack.com serves files
--- more_headers
Host: gl.githack.com

=== glcdn.githack.com serves files
--- more_headers
Host: glcdn.githack.com

=== bb.githack.com serves files
--- more_headers
Host: bb.githack.com

=== bbcdn.githack.com serves files
--- more_headers
Host: bbcdn.githack.com

=== gt.githack.com serves files
--- more_headers
Host: gt.githack.com

=== gtcdn.githack.com serves files
--- more_headers
Host: gtcdn.githack.com

=== cb.githack.com serves files
--- more_headers
Host: cb.githack.com

=== cbcdn.githack.com serves files
--- more_headers
Host: cbcdn.githack.com