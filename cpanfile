requires 'parent'                        => '0';
requires 'Plack'                         => '0.9949';
requires 'Twiggy';
requires 'Amon2' => 6.00;
requires 'Amon2::Plugin::ShareDir';
requires 'Ukigumo::Client' => '0.19';
requires 'Data::Validator';
requires 'Text::Xslate';
requires 'Time::Duration';
requires 'File::ShareDir';
requires 'MRO::Compat';
requires 'Mouse';
requires 'Router::Boom';

on 'test' => sub {
    requires 'Test::More' => '0.98';
};

