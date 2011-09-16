#!/usr/bin/env perl

package Cursor;

use strict;
use warnings;

sub new {
	my ($class, $origin, $size, $term) = @_;
	my $self = {
		origin	=> $origin,
		size	=> $size,
		term	=> $term,
		offset	=> [0,0],
	};
	bless $self, $class;
	return $self;
}
sub origin:lvalue { (shift)->{origin} }
sub offset:lvalue { (shift)->{offset} }
sub line { (shift)->{offset}->[0] }
sub col { (shift)->{offset}->[1] }
sub size:lvalue { (shift)->{size} }
sub height { (shift)->{size}->[0] }
sub width { (shift)->{size}->[1] }
sub term { (shift)->{term} };

sub to {
	my ($self, $point) = @_;
	return 0 if !$self->_check_bounds($point);
	$self->offset = $point;
	$self->term->move_cursor([$self->origin->[0] + $self->offset->[0],
				  $self->origin->[1] + $self->offset->[1]]);
	return 1;
}

sub restore {
	my ($self) = @_;
	$self->to($self->offset);
}
sub adopt {
	my ($self) = @_;
	$self->offset = $self->_abs_to_rel($self->term->query_cursor);
	return $self;
}

sub up {
	my ($self, $n) = @_;
	$n //= 1;
	$self->to([$self->line - $n, $self->col]);
}
sub down {
	my ($self, $n) = @_;
	$n //= 1;
	$self->to([$self->line + $n, $self->col]);
}
sub right {
	my ($self, $n) = @_;
	$n //= 1;
	$self->to([$self->line, $self->col + $n]);
}
sub left {
	my ($self, $n) = @_;
	$n //= 1;
	$self->to([$self->line, $self->col - $n]);
}

sub print {
	my ($self, @str) = @_;
	my $joined = join '', @str;
	$joined = substr($joined, 0, $self->width);
	if ((my $nl_index = index($joined, "\n")) > 0) {
		$joined = substr($joined, 0, $nl_index);
	}
	print $joined;
#	my $final_str = '';
#	for my $s (@str) {
#		last if length($final_str) >= $self->width;
#		if (my $p = index($s, "\n")) {
#			$final_str .= substr($s, 0, $p);
#		}
#	}
#	print substr($final_str, 0, $self->width);
	return length($joined);
}
sub print_clear {
	my ($self, @str) = @_;
	$self->print(' ' x ($self->width - $self->col - $self->print(@str)));
}

sub _check_bounds {
	my ($self, $point) = @_;
	return 1 if ($point->[0] < $self->{size}->[0]
		  && $point->[0] >= 0
		  && $point->[1] < $self->{size}->[1]
		  && $point->[1] >= 0);
	return 0;
}

sub _abs_to_rel {
	my ($self, $point) = @_;
	return [$point->[0] - $self->{origin}->[0],
		$point->[1] - $self->{origin}->[1]];
}


1
