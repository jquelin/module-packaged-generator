use 5.012;
use strict;
use warnings;

package Module::Packaged::Generator;
# ABSTRACT: build list of modules packaged by a linux distribution

use DBI;
use Devel::Platform::Info::Linux;
use Moose;
use MooseX::Has::Sugar;

use Module::Packaged::Generator::DB;

with 'Module::Packaged::Generator::Role::Loggable';


# -- public attributes
{

=attr file

The path to the database file to be created (a string). Defaults to
C<cpan_$dist.db>, where C<$dist> is the distribution name.

=cut

    has file => ( ro, isa=>'Str', lazy_build );
    sub _build_file {
        my $self = shift;
        my $dist = $self->_dist;
        return "cpan_$dist.db";
    }
}


# -- private attributes
{
    # the mpg::db object
    has _db => ( ro, isa=>'Module::Packaged::Generator::DB', lazy_build );
    sub _build__db {
        my $self = shift;
        return Module::Packaged::Generator::DB->new( file => $self->file );
    }

    # the linux distribution name
    has _dist => ( ro, isa=>'Str', lazy_build );
    sub _build__dist {
        my $self = shift;
        my $dist = Devel::Platform::Info::Linux->new->get_info->{oslabel};
        $self->log( "linux distribution: $dist" );
        return $dist;
    }

    # the driver object
    has _driver => ( ro, isa=>'Module::Packaged::Generator::Distribution', lazy_build );
    sub _build__driver {
        my $self = shift;

        my $flavour = $self->_dist;
        my $driver  = "Module::Packaged::Generator::Distribution::$flavour";
        $self->log( "distribution driver: $driver" );

        $self->log_debug( "trying to use distribution driver" );
        eval "use $driver";
        $self->log_fatal( $@ ) if $@ =~ /Compilation failed/;
        $self->log_fatal( "no driver found for this distribution" ) if $@;

        return $driver->new;
    }
}


# -- public methods


=method run

    $generator->run;

Create the database and populate it according to the driver's list of
modules.

=cut

sub run {
    my $self = shift;

    # fetch the list of available perl modules
    $self->log( "fetching list of available perl modules" );
    my @modules = $self->_driver->list;
    $self->log( "found " . scalar(@modules) . " perl modules" );

    # insert the modules in the database
    my $db = $self->_db;
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
        $db->insert_module($m);
        $next_update = $progress->update($_)
            if $i >= $next_update;
    }
    $progress->update( scalar(@modules) );
    $self->log( "${prefix}: done" );

    $db->create_indices;

    # all's done, close the db
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
