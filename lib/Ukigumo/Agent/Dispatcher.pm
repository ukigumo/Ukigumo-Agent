package Ukigumo::Agent::Dispatcher;
use strict;
use warnings;
use utf8;

use Amon2::Web::Dispatcher::Lite;
use Ukigumo::Agent::Manager;

post '/api/v0/test' => sub {
    my $c = shift;

    Ukigumo::Agent::Manager->instance->register_job($c->req->parameters);

    return $c->render_json(+{});
};

1;

