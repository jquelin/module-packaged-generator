use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator;
# ABSTRACT: build list of modules packaged by a linux distribution

use DBI;
use Devel::Platform::Info::Linux;

use Module::Packaged::Generator::Logger;


# -- public methods

=method find_dist

    my $dist = $self->find_dist;

Return the Linux distribution name.

=cut

sub find_dist {
    return Devel::Platform::Info::Linux->new->get_info->{oslabel};
}

=method find_driver

    my $driver = Module::Packaged::Generator->find_driver;

Return a driver that can be used on the current machine, or log a fatal
error if no suitable driver was found.

=cut

sub find_driver {
    my $self = shift;
    my $logger = Module::Packaged::Generator::Logger->instance;

    my $flavour = $self->find_dist;
    my $driver  = "Module::Packaged::Generator::Distribution::$flavour";

    $logger->log_debug( "trying to use $driver" );
    eval "use $driver";
    $logger->log_fatal( $@ ) if $@ =~ /Compilation failed/;
    $logger->log_fatal( "no driver found for this distribution" ) if $@;

    return $driver;
}


=method create_db

    my $dbh = Module::Packaged::Generator->create_db($file);

Creates a sqlite database with the correct schema. Remove the previous
C<$file> if it exists. Return the handler on the opened database.

=cut

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
__END__

=head1 DESCRIPTION

This module alows to fetch modules available as native Linux (or BSD)
distribution packages, and wraps them in a sqlite database. This allows
people to do analysis, draw CPANTS metrics from it or whatever.

Of course, running the utility shipped in this dist will only create the
database for the current distribution. But that's not our job to do
crazy manipulation with this data, we just provide the data :-)


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
