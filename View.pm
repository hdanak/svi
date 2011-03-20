#!/usr/bin/env perl
use strict;
use warnings;

package View;

sub new {
	my ($class, $buffer, $parent) = @_;

	my $self = {
		buffer	=> $buffer,
		parent	=> $parent,
	};
	bless $self, $class;

	$self->{parent}->register_view($self);

	return $self;
}

sub split_vert {
	my ($self) = @_;
	$self->{parent}->split_view($self, 'VERT');
}

sub split_horiz {
	my ($self) = @_;
	$self->{parent}->split_view($self, 'HORIZ');
}

sub change_parent {
	my ($self, $parent) = @_;
	$self->{parent} = $parent;
}

1
