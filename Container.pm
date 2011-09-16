#!/usr/bin/env perl
use strict;
use warnings;

package Container;

sub new {
	my ($class, $origin, $size, $parent) = @_;

	my $self = {
		origin	=> $origin,
		size	=> $size,
		children=> {},
		parent	=> $parent,
	};
	bless $self, $class;
}
sub origin:lvalue { (shift)->{origin} }
sub size:lvalue { (shift)->{size} }
sub height { (shift)->{size}->[0] }
sub width { (shift)->{size}->[1] }
sub parent { (shift)->{parent} }

sub resize {
	my ($self, $size) = @_;
	$self->{size} = $size;
	map {$_->[2]->($_->[0])} values(%{$self->{children}});
}
sub transpose {
	my ($self, $loc) = @_;
	$self->{origin} = $loc;
	map {$_->[1]->($_->[0])} values(%{$self->{children}});
}

sub add_child {
	no strict 'refs';
	my ($self, $name, $child, $origin_funct, $size_funct) = @_;
	$origin_funct //= sub {(shift)->transpose($self->{origin})};
	$size_funct //= sub {(shift)->resize($self->{size})};
	$self->{children}->{$name} = [$child, $origin_funct, $size_funct];
	*{$name} = sub {(shift)->{children}->{$name}->[0]};
}
sub get_child {
	my ($self, $name) = @_;
	return $self->{children}->{$name};
}

sub term {
	my ($self) = @_;
	return $self->parent->term;
}



1
