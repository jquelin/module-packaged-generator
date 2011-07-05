use 5.012;
use strict;
use warnings;

package Module::Packaged::Generator::Role::UrlFetching;
# ABSTRACT: role to provide easy url fetching

use LWP::Simple;
use Moose::Role;

use Module::Packaged::Generator::Utils qw{ $DATADIR };

with 'Module::Packaged::Generator::Role::Logging';


# -- public methods

=method fetch_url

    my $file = $self->fetch_url( $url, $basename );

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

no Moose::Role;

1;
__END__

=head1 DESCRIPTION

This L<Moose> role provides the consuming class with an easy way to
mirror files from the internet.

