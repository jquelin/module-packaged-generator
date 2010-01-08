use 5.008;
use strict;
use warnings;

package Module::Packaged::Generator;
# ABSTRACT: build list of modules packaged by a linux distribution

use List::Util qw{ first };
use Module::Pluggable
    require     => 1,
    sub_name    => 'dists',
    search_path => __PACKAGE__.'::Distribution';


# -- public methods

=method create_db();

Fetch the list of available modules, and creates a sqlite database with
this information.

=cut

sub create_db {
    my $self = shift;

    # try to find a module than can provide the list of modules
    my $dist = first { $_->detect } $self->dists;
    if ( not defined $dist ) {
        warn "no driver found for this machine distribution.\n\n",
            "list of existing distribution drivers:\n",
            map { ( my $d = $_ ) =~ s/^.*:://; "\t$d\n" } $self->dists;
        die "\n";
    }

    print "found a distribution driver: $dist\n";
}

1;
__END__

=head1 DESCRIPTION

This module will fetch modules available as native linux distribution
package, and wraps that in a sqlite database. This then allow people to
do analysis, draw CPANTS metrics from it or whatever.

Of course, running the utility shipped in this dist will only create the
database for the current distribution. But that's not our job to do
crazy manipulation with this data, we just provide the data :-)


=head1 SEE ALSO

You can find more information on this module at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/Module-Packaged-Generator>

=item * See open / report bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Packaged-Generator>

=item * Git repository

L<http://github.com/jquelin/module-packaged-generator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Module-Packaged-Generator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Module-Packaged-Generator>

=back
