use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Module;
# ABSTRACT: a class representing a perl module

use File::HomeDir qw{ my_home };
use Moose;
use MooseX::Has::Sugar;
use Parse::CPAN::Packages;
use Path::Class;


# -- attributes

has name    => ( ro, isa=>'Str', required          );
has version => ( ro, isa=>'Maybe[Str]'             );
has dist    => ( ro, isa=>'Maybe[Str]', lazy_build );
has pkgname => ( ro, isa=>'Str', required          );


# -- initializers & builders

{
    my $pkgfile = file( my_home(), '.cpanplus', '02packages.details.txt.gz' );
    if ( -f $pkgfile ) {
        my $cpan = Parse::CPAN::Packages->new("$pkgfile");
        *_build_dist = sub {
            my $self = shift;
            my $pkg = $cpan->package( $self->name );
            return unless $pkg;
            return $pkg->distribution->dist;
        }
    } else {
        warn "couldn't find a cpanplus index in $pkgfile\n";
        *_build_dist = sub { return };
    }
}

1;
__END__

=head1 DESCRIPTION

This module represent a Perl module with various attributes. It
should be used by the distribution drivers fetching the list of
available modules.
