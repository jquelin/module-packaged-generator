use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator::Module;
# ABSTRACT: a class representing a perl module

use Moose;
use MooseX::Has::Sugar;

has name    => ( ro, isa=>'Str', required );
has version => ( ro, isa=>'Maybe[Str]' );
has dist    => ( ro, isa=>'Str', lazy_build );
has pkgname => ( ro, isa=>'Str', required );

1;
__END__

=head1 DESCRIPTION

This module represent a Perl module with various attributes. It
should be used by the distribution drivers fetching the list of
available modules.
