use 5.010;
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

=method log

=method log_debug

=method log_fatal

    $logger->log( $message );
    $logger->log_debug( $message );
    $logger->log_fatal( $message );

Those methods allow to log a message, with various degrees of
importance. Check L<Log::Dispatchouli> for more information.


=method set_muted

=method set_debug

    $logger->set_debug( $bool );
    $logger->set_muted( $bool );

Sets whether the logger object will log debug messages, or will log
regular messages at all. Check L<Log::Dispatchouli> for more
information.

=cut

# methods provided by the _logger attribute


=method log_step

    $logger->log_step( $msg );

Record C<$msg> as a new step in the application.

=cut

sub log_step {
    my ($self, $msg) = @_;
    $self->log( "\n** $msg" );
}


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

