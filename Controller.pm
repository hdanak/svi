#!/usr/bin/perl
use strict;
use warnings;

package Controller;
use base 'Stub';


=head2 SVI Controller

=cut

sub init {
    my ($self) = @_;
    $self->{events} = {};
}

##
#  Add the client to the specified event's notification list. When an event of
#  that type is received, every client in the notification list will be
#  notified via their notify_event method.
##
sub event_subscribe {
    my ($self, $event, $client) = @_;
    push @{$self->{events}->{$event}}, $client;
}

##
#  Send an event to be relayed to all subscribed clients, along with some data.
##
sub notify_event {
    my ($self, $event, $data) = @_;
    my @subscribers = @{$self->{events}->{$event}};
    for (@subscribers) {
        $_->notify_event($event, $data);
    }
}



1
