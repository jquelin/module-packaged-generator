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

sub match {
    my $mdvrel = file( '/etc/mandriva-release' );
    return unless -f $mdvrel;
    my $content = $mdvrel->slurp;
    return ( $content =~ /mandriva/i );
}

sub list {
    require URPM;

    my $db = URPM::DB->open;
    my $urpm = URPM->new;
    $urpm->parse_synthesis($_) for grep {!/32/} glob "/var/lib/urpmi/synthesis.hdlist.*";
    $urpm->parse_synthesis($_) for grep {!/32/} glob "/var/lib/urpmi/*/synthesis.hdlist.cz";

    my @modules;
    $urpm->traverse( sub {
        my $pkg  = shift;
        my @provides = $pkg->provides;
        my $pkgname = $pkg->name;
        foreach my $p ( @provides ) {
            next unless $p =~ /^perl\(([^)]+)\)(\[== (.*)\])?$/;
            push @modules, Module::Packaged::Generator::Module->new( {
                name    => $1,
                version => $3,
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
