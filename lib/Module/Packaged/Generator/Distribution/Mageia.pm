use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mageia;
# ABSTRACT: mageia driver to fetch available modules

use Moose;
use Path::Class;

extends 'Module::Packaged::Generator::Distribution::URPMI';


# -- public methods

1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mageia.
