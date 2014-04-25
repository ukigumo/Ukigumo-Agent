package Ukigumo::Agent::Manager;
use strict;
use warnings;
use utf8;
use Ukigumo::Client;
use Ukigumo::Client::VC::Git;
use Ukigumo::Client::Executor::Perl;
use Ukigumo::Agent::Logger;
use Coro;
use Coro::AnyEvent;
use POSIX qw/SIGTERM SIGKILL/;
use Log::Minimal;

use Mouse;

has 'children' => ( is => 'rw', default => sub { +{ } } );
has 'work_dir' => ( is => 'rw', isa => 'Str', required => 1 );
has 'server_url' => ( is => 'rw', isa => 'Str', required => 1 );
has job_queue => (is => 'ro', default => sub { +[ ] });
has max_children => ( is => 'ro', default => 1 );
has timeout => (is => 'rw', isa => 'Int', default => 0);
has logger => (
    is      => 'ro',
    isa     => 'Ukigumo::Agent::Logger',
    default => sub {
        Ukigumo::Agent::Logger->new
    },
);

no Mouse;

sub count_children {
    my $self = shift;
    0+(keys %{$self->children});
}

sub push_job {
    my ($self, $job) = @_;
    push @{$self->{job_queue}}, $job;
}

sub pop_job {
    my ($self, $job) = @_;
    pop @{$self->{job_queue}};
}

sub run_job {
    my ($self, $args) = @_;
    Carp::croak "Missing args" unless $args;

    my $repository = $args->{repository} || die;
    my $branch     = $args->{branch} || die;

    my $vc = Ukigumo::Client::VC::Git->new(
        branch     => $branch,
        repository => $repository,
    );
    my $client = Ukigumo::Client->new(
        workdir     => $self->work_dir,
        vc          => $vc,
        executor    => Ukigumo::Client::Executor::Perl->new(),
        server_url  => $self->server_url,
        compare_url => $args->{compare_url},
        repository_owner => $args->{repository_owner},
        repository_name  => $args->{repository_name},
    );

    my $client_log_filename = $client->logfh->filename;

    my $timeout_timer;

    my $pid = fork();
    if (!defined $pid) {
        die "Cannot fork: $!";
    }

    if ($pid) {
        $self->logger->infof("Spawned $pid");
        $self->{children}->{$pid} = +{
            child => AE::child($pid, unblock_sub {
                my ($pid, $status) = @_;

                undef $timeout_timer;

                # Process has terminated because it was timeout
                if ($status == SIGTERM) {
                    Coro::AnyEvent::sleep 5;
                    if (kill 0, $pid) {
                        # Process is still alive
                        kill SIGTERM, $pid;
                        Coro::AnyEvent::sleep 5;
                        if (kill 0, $pid) {
                            # The last resort
                            kill SIGKILL, $pid;
                        }
                    }
                    $self->logger->warnf("[child] timeout");
                    eval { $client->report_timeout($client_log_filename) };
                }

                $self->logger->infof("[child exit] pid: $pid, status: $status");
                delete $self->{children}->{$pid};

                if ($self->count_children < $self->max_children && @{$self->job_queue} > 0) {
                    $self->logger->infof("[child exit] run new job");
                    $self->run_job($self->pop_job);
                } else {
                    $self->_take_a_break();
                }
            }),
            job => $args,
            start => time(),
        };
        my $timeout = $self->timeout;
        if ($timeout > 0) {
            $timeout_timer = AE::timer $timeout, 0, sub {
                kill SIGTERM, $pid;
            };
        }
    } else {
        eval { $client->run() };
        $self->logger->warnf("[child] error: $@") if $@;
        $self->logger->infof("[child] finished to work");
        exit;
    }
}

sub register_job {
    my ($self, $params) = @_;

    if ($self->count_children < $self->max_children) {
        # run job.
        $self->run_job($params);
    } else {
        $self->push_job($params);
    }
}

sub _take_a_break {
    my ($self) = @_;
    $self->logger->infof("[child exit] There is no jobs. sleep...");
}

1;

