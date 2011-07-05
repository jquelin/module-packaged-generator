use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::Utils;
# ABSTRACT: various subs and constants used in the dist

use Exporter::Lite;
use File::HomeDir::PathClass;

our @EXPORT_OK = qw{ $DATADIR };


# -- public vars

our $DATADIR = File::HomeDir::PathClass->my_dist_data(
    'Module-Packaged-Generator', { create => 1 } );


1;
__END__

=head1 DESCRIPTION

This module exports some subs & variables used in the dist.

The following variables are available:
=over 4

=item * $DATADIR

    my $file = $DATADIR->file( ... );

A L<Path::Class> object containing the data directory for the
distribution. This directory will be created if needed.

=back

