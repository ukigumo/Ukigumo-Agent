package Ukigumo::Agent;
use strict;
use warnings;
use 5.008005;
our $VERSION = '0.0.5';
use parent qw(Amon2 Amon2::Web);

sub config { +{ } }

use Ukigumo::Agent::Dispatcher;

__PACKAGE__->load_plugin(qw(Web::JSON));

sub dispatch {
    my ($c) = @_;
    return Ukigumo::Agent::Dispatcher->dispatch($c);
}

{
    use Ukigumo::Agent::View;
    my $view = Ukigumo::Agent::View->make_instance(__PACKAGE__);
    sub create_view { $view }
}

{
    my $_manager;
    sub register_manager { $_manager = $_[1] }
    sub manager { $_manager || die "Missing manager" }
}

use File::ShareDir;
use MRO::Compat;
use List::Util qw(first);

my %SHARE_DIR_CACHE;
sub share_dir {
    my $c = shift;

    $SHARE_DIR_CACHE{ref $c||$c} ||= sub {
        my $d1 = File::Spec->catfile($c->base_dir, 'share');
        return $d1 if -d $d1;

        my $dist = first { $_ ne 'Amon2' && $_ ne 'Amon2::Web' && $_->isa('Amon2') } reverse @{mro::get_linear_isa(ref $c || $c)};
           $dist =~ s!::!-!g;
        my $d2 = File::ShareDir::dist_dir($dist);
        return $d2 if -d $d2;

        Carp::croak "Cannot find assets path($d1, $d2).";
    }->();
}

1;
__END__

=encoding utf8

=head1 NAME

Ukigumo::Agent - Ukigumo test runner server

=head1 DESCRIPTION

Look L<ukigumo-agent.pl>.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
