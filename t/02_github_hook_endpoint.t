use strict;
use warnings;
use utf8;
use t::Util;
use LWP::UserAgent;
use JSON qw/encode_json/;
use Ukigumo::Agent::Manager;
use Test::More;

undef *Ukigumo::Agent::Manager::register_job;
*Ukigumo::Agent::Manager::register_job = sub {};

my $agent = t::Util::build_ukigumo_agent();
my $ua = LWP::UserAgent->new(timeout => 3);
my $res = $ua->post(
    "http://127.0.0.1:@{[ $agent->port ]}/api/github_hook",
    +{
        payload => encode_json({
            repository => {
                url => '127.0.0.1/repos',
            },
            ref => 'refs/heads/branch',
        }),
    },
);
is $res->code, 200;

done_testing;

