#!/usr/bin/perl
use strict;
use warnings;

package Stub;


=head2 Stub base class

=cut

sub new {
    my $class = shift;
    my $self = {};

    bless $self, $class;
    $self->init(@_)
}

##
#  The 'init' method should be overridden by subclasses. It gets any argument
#  supplied to 'new', and should be used as a constructor.
##
sub init { return shift }

##
#  Override 'notify_event' if you subscribe to events.
##
sub notify_event {
    my ($self, $event, $data) = @_;
}



1
