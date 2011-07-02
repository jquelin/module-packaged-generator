use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mandriva;
# ABSTRACT: mandriva driver to fetch available modules

use Moose;
use Path::Class;

use Module::Packaged::Generator::Module;

extends 'Module::Packaged::Generator::Distribution';


# -- public methods

sub list {
    require URPM;

    my $db = URPM::DB->open;
    my $urpm = URPM->new;
    $urpm->parse_synthesis($_) for glob "/var/lib/urpmi/*/synthesis.hdlist.cz";

    my @modules;
    my %seen;
    $urpm->traverse( sub {
        my $pkg  = shift;
        my @provides = $pkg->provides;
        my $pkgname = $pkg->name;
        foreach my $p ( @provides ) {
            next unless $p =~ /^perl\(([^)]+)\)(\[== (.*)\])?$/;
            my ($name, $version) = ($1, $3);
            next if $seen{ $name }++;
            push @modules, Module::Packaged::Generator::Module->new( {
                name    => $name,
                version => $version,
                pkgname => $pkgname,
            } );
        }
    } );
    return @modules;
}

1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mandriva.
