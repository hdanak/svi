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
    my $res = $self->init(@_);
    return $res if defined $res;
    return $self;
}

##
#  The 'init' method should be overridden by subclasses. It gets any argument
#  supplied to 'new', and should be used as a constructor.
##
sub init { return shift }

##
#  Override 'notify' if you subscribe to events.
##
sub notify {
    my ($self, $event, $data) = @_;
}



1
