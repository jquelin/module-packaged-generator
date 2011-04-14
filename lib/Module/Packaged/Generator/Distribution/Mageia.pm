#
# This file is part of Module-Packaged-Generator
#
# This software is copyright (c) 2010 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mageia;
BEGIN {
  $Module::Packaged::Generator::Distribution::Mageia::VERSION = '1.111040';
}
# ABSTRACT: mageia driver to fetch available modules

use Moose;
use Path::Class;

extends 'Module::Packaged::Generator::Distribution::Mandriva';


# -- public methods

sub match {
    my $mgarel = file( '/etc/mageia-release' );
    return unless -f $mgarel;
    my $content = $mgarel->slurp;
    return ( $content =~ /mageia/i );
}

1;


=pod

=head1 NAME

Module::Packaged::Generator::Distribution::Mageia - mageia driver to fetch available modules

=head1 VERSION

version 1.111040

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mageia.

=head1 AUTHOR

Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

