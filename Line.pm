#!/usr/bin/env perl

package Line;

use strict;
use warnings;

sub new {
	my ($class, $origin, $width, $term) = @_;
	my $self = {
		origin	=> $origin,
		size	=> $width,
		term	=> $term,
		buffer	=> [],
		wrap	=> 0,
		offset	=> 0,
	};
	bless $self, $class;
	return $self;
}

sub set_wrap {
	my ($self, $wrap) = @_;
	$self->{wrap} = $wrap;
}

sub draw {
	my ($self) = @_;
	unless ($self->{wrap}) {
		my $str = substr(join('', $self->buffer),
				 $self->{offset},
				 $self->{size});
		$self->{term}->move_cursor($self->{origin});
		$self->{term}->write($str);
	}
}

sub transpose {
	my ($self, $loc) = @_;
	$self->{origin} = $loc;
}


1
