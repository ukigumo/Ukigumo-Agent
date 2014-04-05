package Ukigumo::Agent;
use strict;
use warnings;
use 5.008005;
use version; our $VERSION = version->declare("v0.1.2");
use parent qw(Amon2 Amon2::Web);

sub config { +{ } }

use Ukigumo::Agent::Dispatcher;

__PACKAGE__->load_plugins(qw(Web::JSON ShareDir));

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
