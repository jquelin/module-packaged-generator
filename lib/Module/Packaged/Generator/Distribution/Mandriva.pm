use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mandriva;
# ABSTRACT: mandriva driver to fetch available modules

use relative -to => 'Module::Packaged::Generator', -aliased => qw{ Module };
use base qw{ Module::Packaged::Generator::Distribution };

sub match { -f '/etc/mandriva-release'; }

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
            push @modules, Module->new( {
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

=for Pod::Coverage::TrustPod
    Module

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mandriva.
