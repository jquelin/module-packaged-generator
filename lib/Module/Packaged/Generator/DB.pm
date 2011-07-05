use 5.012;
use strict;
use warnings;

package Module::Packaged::Generator::DB;
# ABSTRACT: database encapsulation

use DBI;
use Moose;
use MooseX::Has::Sugar;
use MooseX::SemiAffordanceAccessor;

with 'Module::Packaged::Generator::Role::Loggable';


# -- public attributes

=attr file

The path to the sqlite database file (a string). Required.

=cut

has file => ( ro, isa=>'Str', required );


# -- private attributes

# the dbi handler
has _dbh => ( rw, isa=>"DBI::db" );


# -- initialization
{
    sub DEMOLISH {
        my $self = shift;
        my $dbh = $self->_dbh;
        $dbh->commit;
        $dbh->disconnect;
    }
}

# -- public methods

=method create

    $db->create;

Force database creation.

=cut

sub create {
    my $self = shift;
    my $file = $self->file;

    # create sqlite db
    $self->log( "creating sqlite database: $file" );
    unlink($file) if -f $file;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '');
    $self->_set_dbh( $dbh );

    # create the module table
    $self->log_debug( "creating module table" );
    $dbh->do("
        CREATE TABLE module (
            module      TEXT NOT NULL,
            version     TEXT,
            dist        TEXT,
            pkgname     TEXT NOT NULL
        );
    ");

    # set database options
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
}


=method insert_module

    $db->insert_module( $module );

Insert C<$module> (a L<Module::Packaged::Generator::Module> object) in
the database.

=cut

sub insert_module {
    my ($self, $mod) = @_;
    state $sth = $self->_dbh->prepare("
        INSERT
            INTO   module (module, version, dist, pkgname)
            VALUES        (?,?,?,?);
    ");
    $sth->execute($mod->name, $mod->version, $mod->dist, $mod->pkgname);
}

=method create_indices

    $db->create_indices;

Create indices on the various columns of the C<module> table to make it
faster.

=cut

sub create_indices {
    my $self = shift;
    my $dbh = $self->_dbh;
    $self->log( "creating indexes" );
    $self->log_debug( "  - modules " );
    $dbh->do("CREATE INDEX module__module  on module ( module  );");
    $self->log_debug( "  - dists " );
    $dbh->do("CREATE INDEX module__dist    on module ( dist    );");
    $self->log_debug( "  - packages " );
    $dbh->do("CREATE INDEX module__pkgname on module ( pkgname );");
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=for Pod::Coverage
    DEMOLISH

=head1 DESCRIPTION

This module encapsulates database creation, insertion and stuff like
this.

