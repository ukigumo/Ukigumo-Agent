requires 'parent'                        => '0';
requires 'Plack'                         => '0.9949';
requires 'Twiggy';
requires 'Amon2';
requires 'Ukigumo::Client';

on 'configure' => sub {
    requires 'Module::Build' => '0.38';
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::CPANfile';
    requires 'Module::Build::Pluggable::GithubMeta';
};

on 'test' => sub {
    requires 'Test::More' => '0.98';
    requires 'Test::Requires' => 0;
};

on 'devel' => sub {
    # Dependencies for developers
};
