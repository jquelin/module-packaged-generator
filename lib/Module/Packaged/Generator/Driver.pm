use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Driver;
# ABSTRACT: base class for all drivers

use Moose;

with 'Module::Packaged::Generator::Role::Loggable';


# -- public methods

=method list

    my @modules = $driver->list;

Return the list of available Perl modules found by this distribution
driver. The method in this class just logs a fatal error, and needs to
be overridden in child classes.

=cut

sub list { my $self = shift; $self->log_fatal( "unimplemented" ); }


1;
__END__

=head1 DESCRIPTION

This module is the base class for all distribution drivers. It provides
some helper methods, and stubs that needs to be overriden in
sub-classes.
