use strict;
use warnings;
use utf8;
use t::Util;
use LWP::UserAgent;
use JSON qw/decode_json encode_json/;
use Ukigumo::Agent::Manager;
use Test::More;

undef *Ukigumo::Agent::Manager::register_job;
*Ukigumo::Agent::Manager::register_job = sub {};

my $ua = LWP::UserAgent->new(timeout => 3);

subtest "Don't ignore github tags" => sub {
    my $agent = t::Util::build_ukigumo_agent();

    subtest 'push branch' => sub {
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
        is decode_json($res->content)->{branch}, 'branch';
    };

    subtest 'push tag' => sub {
        my $res = $ua->post(
            "http://127.0.0.1:@{[ $agent->port ]}/api/github_hook",
            +{
                payload => encode_json({
                    repository => {
                        url => '127.0.0.1/repos',
                    },
                    ref => 'refs/tags/tag',
                }),
            },
        );
        is $res->code, 200;
        is decode_json($res->content)->{branch}, 'tag';
    };
};

subtest 'ignore github tags' => sub {
    my $agent = t::Util::build_ukigumo_agent('--ignore_github_tags');

    subtest 'push tag but do nothing' => sub {
        my $res = $ua->post(
            "http://127.0.0.1:@{[ $agent->port ]}/api/github_hook",
            +{
                payload => encode_json({
                    repository => {
                        url => '127.0.0.1/repos',
                    },
                    ref => 'refs/tags/tag',
                }),
            },
        );
        is $res->code, 200;
        is_deeply decode_json($res->content), {};
    };
};

done_testing;

