#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

use Twiggy;
use Plack::Builder;
use Ukigumo::Agent::Manager;
use Getopt::Long;

GetOptions(
    'work_dir=s'   => \my $work_dir,
    'server_url=s' => \my $server_url,
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

my $twiggy = Twiggy->new();
$twiggy->run($app);

$app;
