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

package Module::Packaged::Generator::Distribution;
BEGIN {
  $Module::Packaged::Generator::Distribution::VERSION = '1.111040';
}
# ABSTRACT: base class for all distribution drivers


# -- public methods


sub match { die "unimplemented" }



sub list   { die "unimplemented" }

1;


=pod

=head1 NAME

Module::Packaged::Generator::Distribution - base class for all distribution drivers

=head1 VERSION

version 1.111040

=head1 DESCRIPTION

This module doesn't do anything useful, but defining methods that
distribution drivers should implement. Those stub methods are just
dying, since they should be overridden in the sub-classes.

=head1 METHODS

=head2 match

    my $bool = $class->match;

Return true if the class has detected that it can provides information
on the current machine.

=head2 list

    my @modules = $class->list;

Return the list of available Perl modules for this distribution.

=head1 AUTHOR

Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

