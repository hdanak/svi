#!/usr/bin/env perl
use strict;
use warnings;

package Page;
use base qw(Container);

use View;
use SplitView;

sub new {
	my ($class, $origin, $size, $parent, $buffer) = @_;
	my $self = new Container($origin, $size, $parent);
	bless $self, $class;

	$self->{views}	= [];
	$self->add_child(
		'main',
		new View($origin, $size, $self, $buffer),
		undef, undef,
	);

	$self->set_focus(0);
	return $self;
}

sub draw {
	my ($self) = @_;
	$self->main->draw;
}

sub split_view {
	my ($self, $type) = @_;
	$self->main = new SplitView($type, $self->main, $self);
}

sub set_focus {
	my ($self, $vnum) = @_;
}

sub register_view {
	my ($self, $view) = @_;
	push @{$self->{views}}, $view;
}


1
