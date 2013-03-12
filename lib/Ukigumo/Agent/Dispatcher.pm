package Ukigumo::Agent::Dispatcher;
use strict;
use warnings;
use utf8;

use Amon2::Web::Dispatcher::Lite;
use Ukigumo::Agent::Manager;
use Data::Validator;

get '/' => sub {
    my $c = shift;

    $c->render(
        'index.tt' => {
            children     => $c->manager->children,
            job_queue    => $c->manager->job_queue,
            server_url   => $c->manager->server_url,
            work_dir     => $c->manager->work_dir,
            max_children => $c->manager->max_children,
        }
    );
};

my $rule = Data::Validator->new(
    repository => { isa => 'Str' },
    branch     => { isa => 'Str' },
)->with('NoThrow');
post '/api/v0/enqueue' => sub {
    my $c = shift;

    my $args = $rule->validate(+{%{$c->req->parameters}});
    if ($rule->has_errors) {
        my $errors = $rule->clear_errors();

        my $res = $c->render_json({errors => $errors});
        $res->code(400);
        return $res;
    }

    $c->manager->register_job($args);

    return $c->render_json(+{});
};

1;

