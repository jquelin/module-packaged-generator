use 5.010;
use strict;
use warnings;

package Module::Packaged::Generator::Role::Logging;
# ABSTRACT: role to provide easy logging

use Moose::Role;
use MooseX::Has::Sugar;

use Module::Packaged::Generator::Logger;

# -- private attributes

has _logger => (
    ro,
    isa     => 'Module::Packaged::Generator::Logger',
    default => sub { Module::Packaged::Generator::Logger->instance },
    handles => [ qw{
        log_step log log_fatal log_debug
        set_debug set_muted progress_bar
    } ],
);

=method log

=method log_fatal

=method log_debug

=method set_debug

=method set_muted

=method progress_bar

Those methods are imported from L<Module::Packaged::Generator::Logger> -
refer to this module for more information.

=cut

# provided by mpg:logger

no Moose::Role;

1;
__END__

=head1 DESCRIPTION

This L<Moose> role provides the consuming class with an easy access to
L<Module::Packaged::Generator::Logger>.

