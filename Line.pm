#!/usr/bin/env perl

package Line;

use strict;
use warnings;

sub new {
	my ($class, $origin, $width, $term) = @_;
	my $self = {
		origin	=> $origin,
		size	=> [1, $width],
		term	=> $term,
		buffer	=> '',
		pos	=> 0,
		wrap	=> 0,
	};
	bless $self, $class;
	return $self;
}
sub origin:lvalue { (shift)->{origin} }
sub size:lvalue { (shift)->{size} }
sub height { (shift)->{size}->[0] }
sub width { (shift)->{size}->[1] }
sub term { (shift)->{term} }
sub buffer:lvalue{ (shift)->{buffer} }
sub pos:lvalue{ (shift)->{pos} }

sub put {
	my ($self, $text) = @_;
	$text =~ s/\n//g;
	$self->buffer = $text;
	return $self;
}
sub text {
	my ($self) = @_;
	return $self->buffer;
}
sub write {
	my ($self, $text) = @_;
	$text =~ s/\n//g;
	$self->buffer = $text;
	$self->draw;
	return $self;
}
sub append {
	my ($self, $text) = @_;
	$text =~ s/\n//g;
	$self->buffer .= $text;
	$self->draw;
	return $self;
}
sub bs {
	my ($self, $text) = @_;
	substr($self->buffer, length($self->buffer)-1, 1, '');
	$self->draw;
	return $self;
}

sub set_wrap {
	my ($self, $wrap) = @_;
	$self->{wrap} = $wrap;
}

sub draw {
	my ($self) = @_;
	unless ($self->{wrap}) {
		my $str = substr($self->buffer, $self->pos, $self->width);
		my $padding = $self->width - length($str);
		$self->term->write($str . (' ' x $padding))
			if $self->term->move_cursor($self->origin);
		return 1;
	}
}

sub resize {
	my ($self, $size) = @_;
	$self->{size} = [1, $size->[1]];
}
sub transpose {
	my ($self, $loc) = @_;
	$self->origin = $loc;
}


1
