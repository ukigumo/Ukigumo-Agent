use strict;
use warnings;
use Module::Build::Pluggable qw(
    CPANfile
    GithubMeta
);

my $build = Module::Build::Pluggable->new(
    license              => 'perl',
    dynamic_config       => 0,

    requires             => {
        perl => '5.008005',
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Ukigumo-Agent',
    module_name => 'Ukigumo::Agent',

    script_files => ['bin/ukigumo-agent'],

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    share_dir => 'share',

    script_files => ['bin/ukigumo-agent'],
   
    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
