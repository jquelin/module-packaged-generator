use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::Driver::URPMI;
# ABSTRACT: urpmi-based driver to fetch available modules

use Moose;
use MooseX::Has::Sugar;

use Module::Packaged::Generator::Module;

extends 'Module::Packaged::Generator::Driver';
with    'Module::Packaged::Generator::Role::Loggable';



# -- private attributes

has _medias => (
    ro, lazy_build,
    isa     => 'HashRef[Str]',
    traits  => ['Hash'],
    handles => {
        medias        => 'keys',
        get_media_url => 'get',
    },
);


# -- public methods

sub list {
    my $self = shift;

    require URPM;

    my $urpm = URPM->new;
    $urpm->parse_synthesis($_) for $self->_get_synthesis;

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


# -- private methods

#
# my @files = $urpmi->_get_synthesis;
#
# download the synthesis files from a mirror and store them locally,
# return the path to the local files. this allows to use latest &
# greatest data instead of (stalled?) local data.
#
sub _get_synthesis {
    my $self = shift;

    my @files;
    (my $driver = ref($self)) =~ s/.*:://;
    foreach my $media ( $self->medias ) {
        my $url  = $self->get_media_url($media);
        my $base = "synthesis.hdlist.$driver.$media.cz";
        push @files, $self->fetch_url( $url, $base );
    }

    return @files;
}

1;
__END__

=head1 DESCRIPTION

This module is the L<Module::Packaged::Generator::Driver> driver
for urpmi-based distributions (such as Mageia and Mandriva).

