use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::DB;
# ABSTRACT: database encapsulation

use DBI;
use File::Copy;
use File::Temp;
use Moose;
use MooseX::Has::Sugar;
use MooseX::SemiAffordanceAccessor;

with 'Module::Packaged::Generator::Role::Logging';


# -- public attributes

=attr file

The path to the sqlite database file (a string). Required.

=cut

has file => ( ro, isa=>'Str', required );

# temp file holding the db before moving it to final location
has _file => ( ro, isa=>'File::Temp', default => sub { File::Temp->new } );


# -- private attributes

# the dbi handler
has _dbh => ( rw, isa=>"DBI::db" );


# -- public methods

=method create

    $db->create;

Force database creation.

=cut

sub create {
    my $self = shift;
    my $file = $self->_file->filename;

    # create sqlite db
    $self->log_step( "creating sqlite database" );
    $self->log_debug( "db location: $file" );
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
    $self->log_step( "creating indexes" );
    $self->log_debug( "index on column modules" );
    $dbh->do("CREATE INDEX module__module  on module ( module  );");
    $self->log_debug( "index on column dists" );
    $dbh->do("CREATE INDEX module__dist    on module ( dist    );");
    $self->log_debug( "index on column packages" );
    $dbh->do("CREATE INDEX module__pkgname on module ( pkgname );");
}


=method close

    $db->close;

Close database and move it to its final location.

=cut

sub close {
    my $self = shift;

    # finalize db operations
    my $dbh = $self->_dbh;
    $dbh->commit;
    $dbh->disconnect;

    # moving db
    $self->log_step( "moving db to final location" );
    my $file = $self->file;
    unlink($file) if -f $file;
    $self->log( "final db location: $file" );
    move( $self->_file->filename, $file );
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

