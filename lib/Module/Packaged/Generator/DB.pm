use 5.012;
use strict;
use warnings;

package Module::Packaged::Generator::DB;
# ABSTRACT: database encapsulation

use DBI;
use Moose;
use MooseX::Has::Sugar;

with 'Module::Packaged::Generator::Role::Loggable';


# -- public attributes

=attr file

The path to the sqlite database file (a string). Required.

=cut

has file => ( ro, isa=>'Str', required );


# -- private attributes

has _dbh => ( ro, isa=>"DBI::db", lazy_build );
sub _build__dbh {
    my $self = shift;
    my $file = $self->file;

    # create sqlite db
    unlink($file) if -f $file;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '');

    # create the module table
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
    return $dbh;
}

sub DEMOLISH {
    my $self = shift;
    my $dbh = $self->_dbh;
    $dbh->commit;
    $dbh->disconnect;
}

# -- public methods

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

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=for Pod::Coverage
    DEMOLISH

=head1 DESCRIPTION

This module encapsulates database creation, insertion and stuff like
this.

