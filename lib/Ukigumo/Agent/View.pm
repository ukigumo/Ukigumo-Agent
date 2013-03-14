package Ukigumo::Agent::View;
use strict;
use warnings;
use utf8;
use Text::Xslate;
use File::ShareDir qw(dist_dir);
use List::Util qw(first);
use Data::Thunk qw(lazy);

sub make_instance {
    my ($class, $c) = @_;

    my $path = first { -d $_ } (
        lazy { File::Spec->catfile($c->base_dir, 'share/tmpl') },
        lazy { File::ShareDir::dist_dir('Ukigumo-Agent', 'tmpl') },
    );
    my $xslate = Text::Xslate->new(
        syntax => 'TTerse',
        path => ["$path"],
        module => [
            'Text::Xslate::Bridge::Star',
            'Time::Piece' => ['localtime'],
            'Time::Duration' => ['duration'],
        ],
        function => {
            time => sub { time() },
        },
    );
}

1;

