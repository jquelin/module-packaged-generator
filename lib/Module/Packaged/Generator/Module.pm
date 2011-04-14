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

=attr name

This is the module name, such as C<Foo::Bar::Baz>. It is required.

=attr version

This is the module version. It isn't mandatory.

=attr dist

This is the CPAN distribution the module is part of. It's lazily built
on first access, taken from the C<02packages.details.txt.gz> from
L<CPANPLUS> work directory. It will be eg C<Foo-Bar>.

=attr pkgname

This is the name of the package holding this module in the Linux
distribution. Chances are that it looks like C<perl-Foo-Bar> on Mageia
or Mandriva, C<libfoo-bar-perl> on Debian, etc. It's required.

=cut

has name    => ( ro, isa=>'Str',        required   );
has version => ( ro, isa=>'Maybe[Str]'             );
has dist    => ( ro, isa=>'Maybe[Str]', lazy_build );
has pkgname => ( ro, isa=>'Str',        required   );


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

Note that for C<dist> to return a meaningful result, it needs the
L<CPANPLUS> index, which should exist if you already used CPANPLUS at
least once.

