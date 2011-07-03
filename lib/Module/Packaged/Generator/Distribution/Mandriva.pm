use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mandriva;
# ABSTRACT: mandriva driver to fetch available modules

use Moose;

extends 'Module::Packaged::Generator::Distribution::URPMI';

# -- public methods

1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mandriva.
