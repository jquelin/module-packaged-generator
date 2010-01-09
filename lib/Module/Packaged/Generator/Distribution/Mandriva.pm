use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mandriva;
# ABSTRACT: mandriva driver to fetch available modules

use base qw{ Module::Packaged::Generator::Distribution };

sub detect { -f '/etc/mandriva-release'; }

sub list {
    require URPM;

    my $db = URPM::DB->open;
    my $urpm = URPM->new;
    $urpm->parse_synthesis($_) for glob "/var/lib/urpmi/synthesis.hdlist.*";
    $urpm->parse_synthesis($_) for glob "/var/lib/urpmi/*/synthesis.hdlist.cz";

    my @modules;
    $urpm->traverse( sub {
        my $pkg  = shift;
        my @provides = $pkg->provides;
        my $pkgname = $pkg->name;
        foreach my $p ( @provides ) {
            next unless $p =~ /^perl\(([^)]+)\)(\[== (.*)\])?$/;
            my ($module, $version) = ($1, $3);
            push @modules, [ $module, $version, $pkgname ];
        }
    } );
    return @modules;
}



1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mandriva.
