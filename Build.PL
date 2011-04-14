
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::Find' => '0',
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'build list of modules packaged by a linux distribution',
  'dist_author' => [
    'Jerome Quelin'
  ],
  'dist_name' => 'Module-Packaged-Generator',
  'dist_version' => '1.111040',
  'license' => 'perl',
  'module_name' => 'Module::Packaged::Generator',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'DBI' => '0',
    'File::HomeDir::PathClass' => '0',
    'File::Spec::Functions' => '0',
    'FindBin' => '0',
    'List::Util' => '0',
    'Module::Pluggable' => '0',
    'Moose' => '0',
    'MooseX::Has::Sugar' => '0',
    'Parse::CPAN::Packages::Fast' => '0',
    'Path::Class' => '0',
    'Term::ProgressBar::Quiet' => '0',
    'perl' => '5.010'
  },
  'script_files' => [
    'bin/pkgcpan'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
