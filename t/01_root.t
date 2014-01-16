use strict;
use warnings;
use utf8;
use Test::More;
use Test::TCP;
use Plack::Loader;
use File::Temp qw(tempdir);

use LWP::UserAgent;

my $server = Test::TCP->new(
    code => sub {
        my ($port) = @_;
        my $app = sub {
            [200, [], ['OK']];
        };
        my $loader = Plack::Loader->auto(
            port => $port,
        );
        $loader->run($app);
    },
);

my $agent = Test::TCP->new(
    code => sub {
        my ($port) = @_;
        my $work_dir = tempdir();
        @ARGV = ('--host=127.0.0.1', "--port=$port", "--work_dir=$work_dir", "--server_url=http://127.0.0.1:@{[ $server->port ]}/");
        do 'script/ukigumo-agent';
        exit 0;
    },
);

my $ua = LWP::UserAgent->new(timeout => 3);
my $res = $ua->get("http://127.0.0.1:@{[ $agent->port ]}");
is $res->code, 200;

done_testing;

