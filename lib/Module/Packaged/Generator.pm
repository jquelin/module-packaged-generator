use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator;
# ABSTRACT: build list of modules packaged by a linux distribution

use DBI;
use Devel::Platform::Info::Linux;
use Moose;
use MooseX::Has::Sugar;

with 'Module::Packaged::Generator::Role::Loggable';


# -- public attributes

=attr file

The path to the database file to be created (a string). Defaults to
C<cpan_$dist.db>, where C<$dist> is the distribution name.

=cut

has file => ( ro, isa=>'Str', lazy_build );
sub _build_file {
    my $self = shift;
    my $dist = $self->find_dist;
    return "cpan_$dist.db";
}


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

    my $flavour = $self->find_dist;
    my $driver  = "Module::Packaged::Generator::Distribution::$flavour";

    $self->log_debug( "trying to use $driver" );
    eval "use $driver";
    $self->log_fatal( $@ ) if $@ =~ /Compilation failed/;
    $self->log_fatal( "no driver found for this distribution" ) if $@;

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

=method run

    $generator->run;

Create the database and populate it according to the driver's list of
modules.

=cut

sub run {
    my $self = shift;

    # try to find a suitable driver
    my $dist = Module::Packaged::Generator->find_dist;
    $self->log( "linux distribution: $dist" );
    my $driver = $self->find_driver;
    $self->log( "distribution driver: $driver" );

    # create the database
    my $file = $self->file;
    my $dbh  = Module::Packaged::Generator->create_db($file);
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;


    # fetch the list of available perl modules
    $self->log( "fetching list of available perl modules" );
    my @modules = $driver->new->list;
    $self->log( "found " . scalar(@modules) . " perl modules" );


    # insert the modules in the database
    my $sth = $dbh->prepare("
        INSERT
            INTO   module (module, version, dist, pkgname)
            VALUES        (?,?,?,?);
    ");
    my $prefix = "inserting modules in db";
    my $progress = $self->progress_bar( {
        count     => scalar(@modules),
        bar_width => 50,
        remove    => 1,
        name      => $prefix,
    } );
    $progress->minor(0);  # we're so fast now that we don't need minor scale
    my $next_update = 0;
    foreach my $i ( 0 .. $#modules ) {
        my $m = $modules[$i];
        $sth->execute($m->name, $m->version, $m->dist, $m->pkgname);
        $next_update = $progress->update($_)
            if $i >= $next_update;
    }
    $progress->update( scalar(@modules) );
    $sth->finish;
    $self->log( "${prefix}: done" );


    # create indexes in the db to make it faster
    $self->log( "creating indexes:" );
    $self->log( "  - modules " );
    $dbh->do("CREATE INDEX module__module  on module ( module  );");
    $self->log( "  - dists " );
    $dbh->do("CREATE INDEX module__dist    on module ( dist    );");
    $self->log( "  - packages " );
    $dbh->do("CREATE INDEX module__pkgname on module ( pkgname );");


    # all's done, close the db
    $dbh->commit;
    $dbh->disconnect;
    $self->log( "database created" );
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
