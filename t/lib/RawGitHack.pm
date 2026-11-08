package RawGitHack;

# Common setup for rawgithack tests.
#
# The project config is inlined into http_config with proxy_pass pointed to
# the Test::Nginx server itself, so every test describes the upstream
# responses in its own `--- config` section.
#
# Usage:
#   use Test::Nginx::Socket 'no_plan';
#   use lib 't/lib';
#   use RawGitHack;
#   RawGitHack::setup();
#   run_tests();

use strict;
use warnings;

use Test::Nginx::Util ();

my $CONF_PATH = 'rawgithack.conf';
my $DEFAULT_HOST = 'raw.githack.com';

sub load_conf {
  my $port = shift;

  my $conf = do {
    local (@ARGV, $/) = ($CONF_PATH);
    <>;
  };
  $conf =~ s{proxy_pass https://\$origin;}{proxy_pass http://127.0.0.1:$port;}
    or die "proxy_pass not found in $CONF_PATH";
  return $conf;
}

sub setup {
  Test::Nginx::Util::use_hup();

  my $conf = load_conf($Test::Nginx::Util::ServerPort);

  Test::Nginx::Util::add_block_preprocessor(sub {
    my $block = shift;
    $block->set_value("http_config", $conf);
    $block->set_value("server_name", "127.0.0.1");
    $block->set_value("config", $block->config // '');
    my $more = $block->more_headers // '';
    $block->set_value(
      "more_headers",
      ($more =~ /^Host:/mi ? '' : "Host: $DEFAULT_HOST\n") . $more);
  });
}

1;
