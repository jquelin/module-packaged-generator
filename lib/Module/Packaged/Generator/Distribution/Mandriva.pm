#
# This file is part of Module-Packaged-Generator
#
# This software is copyright (c) 2010 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::Distribution::Mandriva;
BEGIN {
  $Module::Packaged::Generator::Distribution::Mandriva::VERSION = '1.111040';
}
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


=pod

=head1 NAME

Module::Packaged::Generator::Distribution::Mandriva - mandriva driver to fetch available modules

=head1 VERSION

version 1.111040

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Distribution> driver
for Mandriva.

=head1 AUTHOR

Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

