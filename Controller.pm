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
    return
}

##
#  Add the client to the specified event's notification list. When an event of
#  that type is received, every client in the notification list will be
#  notified via their notify method.
##
sub subscribe {
    my ($self, $event, $client) = @_;
    push @{$self->{events}->{$event}}, $client;
    return
}

##
#  Send an event to be relayed to all subscribed clients, along with some data.
##
sub notify {
    my ($self, $event, $data) = @_;
    my @subscribers = @{$self->{events}->{$event}};
    for (@subscribers) {
        $_->notify_event($event, $data);
    }
}



1
