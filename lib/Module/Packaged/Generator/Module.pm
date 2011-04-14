#
# This file is part of Module-Packaged-Generator
#
# This software is copyright (c) 2010 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Module;
BEGIN {
  $Module::Packaged::Generator::Module::VERSION = '1.111040';
}
# ABSTRACT: a class representing a perl module

use File::HomeDir::PathClass qw{ my_home };
use Moose;
use MooseX::Has::Sugar;
use Parse::CPAN::Packages::Fast;
use Path::Class;


# -- attributes


has name    => ( ro, isa=>'Str',        required   );
has version => ( ro, isa=>'Maybe[Str]'             );
has dist    => ( ro, isa=>'Maybe[Str]', lazy_build );
has pkgname => ( ro, isa=>'Str',        required   );

my $CPAN;
{
    # try to locate cpanplus index
    my $pkgfile = my_home()->file( '.cpanplus', '02packages.details.txt.gz' );
    die "couldn't find a cpanplus index in $pkgfile\n"
        unless -f $pkgfile;
    $CPAN = Parse::CPAN::Packages::Fast->new($pkgfile->stringify);
}

sub _build_dist {
    my $self = shift;
    my $pkg;
    eval { $pkg = $CPAN->package( $self->name ); };
    return unless $pkg;
    return $pkg->distribution->dist;
}

1;


=pod

=head1 NAME

Module::Packaged::Generator::Module - a class representing a perl module

=head1 VERSION

version 1.111040

=head1 DESCRIPTION

This module represent a Perl module with various attributes. It
should be used by the distribution drivers fetching the list of
available modules.

Note that for C<dist> to return a meaningful result, it needs the
L<CPANPLUS> index, which should exist if you already used CPANPLUS at
least once.

=head1 ATTRIBUTES

=head2 name

This is the module name, such as C<Foo::Bar::Baz>. It is required.

=head2 version

This is the module version. It isn't mandatory.

=head2 dist

This is the CPAN distribution the module is part of. It's lazily built
on first access, taken from the C<02packages.details.txt.gz> from
L<CPANPLUS> work directory. It will be eg C<Foo-Bar>.

=head2 pkgname

This is the name of the package holding this module in the Linux
distribution. Chances are that it looks like C<perl-Foo-Bar> on Mageia
or Mandriva, C<libfoo-bar-perl> on Debian, etc. It's required.

=head1 AUTHOR

Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

