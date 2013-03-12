package Ukigumo::Agent::Manager;
use strict;
use warnings;
use utf8;
use Ukigumo::Client;
use Ukigumo::Client::VC::Git;

use Mouse;

has 'children' => ( is => 'rw', default => sub { +{ } } );
has 'work_dir' => ( is => 'rw', required => 1 );
has 'server_url' => ( is => 'rw', required => 1 );

no Mouse;

sub register_job {
    my ($self, $params) = @_;

    my $pid = fork();
    if (!defined $pid) {
        die "Cannot fork: $!";
    }

    my $branch = $params->{branch} // 'master';
    my $repo = $params->{repo} // 'master';

    if ($pid) {
        my $vc_module = Ukigumo::Client::VC::Git->new();
        my $client = Ukigumo::Client->new(
            workdir => $self->work_dir,
            vc => $vc_module->new(
                branch     => $branch,
                repository => $repo,
            ),
            executor => Ukigumo::Client::Executor::Perl->new(),
            server_url => $self->server_url,
        );
        $client->run();
        exit;
    } else {
        $self->{children}->{$pid} = AE::child($pid, sub {
            my ($pid, $status) = @_;
            print "[child exit] pid: $pid, status: $status\n";
            delete $self->{children}->{$pid};
        });
    }
}

1;

