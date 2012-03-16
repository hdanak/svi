#!/usr/bin/perl
use strict;
use warnings;

package Element::Container;
@ISA = (Stub);

use feature 'given';


=head2 Editor View Container

=cut

sub new {
    my $class = shift;
    my $self = {
        controller => undef,
		loc        => [0, 0],
		size	   => [0, 0],
	};

    bless $self, $class;
    $self->init(@_)
}
sub init {
    my ($self, $loc, $size, $controller) = @_;

    $self->{controller} = $controller;
    $self->move @$loc;
    $self->size @$size;

    return $self
}

sub notify_event {
    my ($self, $event, $data) = @_;
    given ($event) {
        case 'resize' {
            $self->size(@{$data->{size}})
        }
    }
}

sub size {
	my ($self, $lines, $cols) = @_;
    if (@_ > 1) {
        $self->{size}->[0] = $lines;
        $self->{size}->[1] = $cols;
    } else {
        return @{$self->{size}};
    }
}

sub move {
	my ($self, $line, $col) = @_;
	$self->{origin} = [$line, $col];
}



1
