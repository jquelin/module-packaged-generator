use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mandriva;
# ABSTRACT: mandriva driver to fetch available modules

use base qw{ Module::Packaged::Generator::Distribution };

sub detect { -f '/etc/mandriva-release'; }

sub list {
}



1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mandriva.
