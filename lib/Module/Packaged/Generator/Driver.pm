use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Driver;
# ABSTRACT: base class for all drivers

use LWP::Simple;
use Moose;

use Module::Packaged::Generator::Utils qw{ $DATADIR };

with 'Module::Packaged::Generator::Role::Loggable';


# -- public methods

=method list

    my @modules = $driver->list;

Return the list of available Perl modules found by this distribution
driver. The method in this class just logs a fatal error, and needs to
be overridden in child classes.

=cut

sub list { my $self = shift; $self->log_fatal( "unimplemented" ); }


=method fetch_url

    my $file = $driver->fetch_url( $url, $basename );

Try to fetch C<$url>, and store it as C<$basename> in a private data
directory (cf L<Module::Packaged::Generator::Utils>). Return the full
path if successful (a L<Path::Class> object), throws an error if
download ended up as an error.

=cut

sub fetch_url {
    my ($self, $url, $basename) = @_;

    my $file = $DATADIR->file( $basename );
    $self->log_debug( "downloading $url" );
    my $rc = mirror($url, $file);
    return $file if $rc == 304; # file is up to date
    return $file if is_success($rc);
    $self->log_fatal( status_message($rc) . "$rc $url " );
}

1;
__END__

=head1 DESCRIPTION

This module is the base class for all distribution drivers. It provides
some helper methods, and stubs that needs to be overriden in
sub-classes.
