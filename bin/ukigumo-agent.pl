#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Twiggy::Server;
use Plack::Builder;
use Ukigumo::Agent::Manager;
use Ukigumo::Agent;
use Getopt::Long;

my $port = 1984;
my $host = '127.0.0.1';
GetOptions(
    'work_dir=s'   => \my $work_dir,
    'server_url=s' => \my $server_url,
    'h|host=i' => \$host,
    'p|port=i' => \$port,
);

my $manager = Ukigumo::Agent::Manager->new(
    work_dir   => $work_dir,
    server_url => $server_url,
);
Ukigumo::Agent->register_manager($manager);

my $app = builder {
    enable 'AccessLog';
    Ukigumo::Agent->to_app();
};

my $twiggy = Twiggy::Server->new(
    host => $host,
    port => $port,
);
$twiggy->register_service($app);

print "http://${host}:${port}/\n";

AE::cv->recv;
