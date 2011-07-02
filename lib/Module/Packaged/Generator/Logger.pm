use 5.012;
use strict;
use warnings;

package Module::Packaged::Generator::Logger;
# ABSTRACT: simple logger for the dist

use Log::Dispatchouli;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Singleton;
use Term::ProgressBar::Quiet;
use Test::MockObject;


# -- private attributes

has _logger => (
    rw, lazy_build,
    isa => 'Log::Dispatchouli',
    handles => [ qw{ log log_fatal log_debug set_debug set_muted } ],
);

sub _build__logger {
    return Log::Dispatchouli->new( {
        ident       => 'pkgcpan',
        to_stdout   => 1,
        log_pid     => 0,
        quiet_fatal => [ qw{ stdout stderr } ],
    } );
}

# --

=method progress_bar

    my $progress = $logger->progress_bar( @options );

Return an object to be used as a L<Term::ProgressBar> object. It won't
do anything if we're currently in a quiet mode.

=cut

sub progress_bar {
    my $self = shift;

    # real progress bar if not muted
    return Term::ProgressBar::Quiet->new( @_ )
        unless $self->_logger->get_muted;

    # fake object otherwise
    my $mock = Test::MockObject->new();
    $mock->set_true($_) for qw{ update message minor };
    return $mock;
}

1;
__END__

=head1 DESCRIPTION

This module implements everything needed to log stuff for this
distribution.

