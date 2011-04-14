use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution;
# ABSTRACT: base class for all distribution drivers


# -- public methods

=method match

    my $bool = $class->match;

Return true if the class has detected that it can provides information
on the current machine.

=cut

sub match { die "unimplemented" }


=method list

    my @modules = $class->list;

Return the list of available Perl modules for this distribution.

=cut

sub list   { die "unimplemented" }

1;
__END__

=head1 DESCRIPTION

This module doesn't do anything useful, but defining methods that
distribution drivers should implement. Those stub methods are just
dying, since they should be overridden in the sub-classes.

