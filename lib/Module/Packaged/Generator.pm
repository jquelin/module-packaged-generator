#
# This file is part of Module-Packaged-Generator
#
# This software is copyright (c) 2010 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator;
BEGIN {
  $Module::Packaged::Generator::VERSION = '1.111040';
}
# ABSTRACT: build list of modules packaged by a linux distribution

use DBI;
use List::Util qw{ first };
use Module::Pluggable
    require     => 1,
    sub_name    => 'dists',
    search_path => __PACKAGE__.'::Distribution';


# -- public methods


sub all_drivers { return $_[0]->dists; }



sub find_driver {
    my $self = shift;
    return first { $_->match } $self->dists;
}



sub create_db {
    my ($self, $file) = @_;

    unlink($file) if -f $file;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '');
    $dbh->do("
        CREATE TABLE module (
            module      TEXT NOT NULL,
            version     TEXT,
            dist        TEXT,
            pkgname     TEXT NOT NULL
        );
    ");
    return $dbh;
}


1;


=pod

=head1 NAME

Module::Packaged::Generator - build list of modules packaged by a linux distribution

=head1 VERSION

version 1.111040

=head1 DESCRIPTION

This module alows to fetch modules available as native Linux (or BSD)
distribution packages, and wraps them in a sqlite database. This allows
people to do analysis, draw CPANTS metrics from it or whatever.

Of course, running the utility shipped in this dist will only create the
database for the current distribution. But that's not our job to do
crazy manipulation with this data, we just provide the data :-)

=head1 METHODS

=head2 all_drivers

    my @drivers = Module::Packaged::Generator->all_drivers();

Return a list of all available drivers supporting a distribution. The
list is a list of module names (strings) such as
L<Module::Packaged::Generator::Mandriva>.

=head2 find_driver

    my $driver = Module::Packaged::Generator->find_driver;

Return a driver that can be used on the current machine, or undef if no
suitable driver was found.

=head2 create_db

    my $dbh = Module::Packaged::Generator->create_db($file);

Creates a sqlite database with the correct schema. Remove the previous
C<$file> if it exists. Return the handler on the opened database.

=head1 SEE ALSO

You can find more information on this module at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/Module-Packaged-Generator>

=item * See open / report bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Packaged-Generator>

=item * Git repository

L<http://github.com/jquelin/module-packaged-generator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Module-Packaged-Generator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Module-Packaged-Generator>

=back

=head1 AUTHOR

Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

