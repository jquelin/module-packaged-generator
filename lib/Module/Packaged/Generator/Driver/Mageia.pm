use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Driver::Mageia;
# ABSTRACT: mageia driver to fetch available modules

use Moose;

extends 'Module::Packaged::Generator::Driver::URPMI';


# -- initialization

sub _build__medias {
    my $self = shift;
    my $root = 'http://distrib-coffee.ipsl.jussieu.fr/pub/linux/Mageia/distrib/cauldron/x86_64/media';
    my @medias = qw{ core nonfree tainted };
    my $suffix = 'release/media_info/synthesis.hdlist.cz';
    return { map { $_ => "$root/$_/$suffix" } @medias };
}

1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Driver> for Mageia.
