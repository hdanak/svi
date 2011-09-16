#!/usr/bin/env perl
use strict;
use warnings;

package SplitView;
use base qw(Container);

sub new {
	my ($class, $type, $view, $origin, $size, $parent) = @_;
	my $self = new Container($origin, $size, $parent);
	bless $self, $class;

	$self->{type}	= $type; # 'VERT' or 'HORIZ'
	$self->add_child(
		'first',
		$view,
		sub {
			my $child = shift;
			$child->transpose();
		},
		sub {
			my $child = shift;
			$child->resize();
		},
	);
	$view->change_parent($self);
	$self->add_child(
		'second',
		new View($origin, $size, $self, $view->buffer),
		sub {
			my $child = shift;
			$child->transpose();
		},
		sub {
			my $child = shift;
			$child->resize();
		},
	);

	return $self;
}

sub split_view {
	my ($self, $view, $type) = @_;
	if ($view == $self->first) {
		$self->first = new SplitView($type, $view, $self);
		$view->change_parent($self->first);
	} elsif ($view == $self->second) {
		$self->second = new SplitView($type, $view, $self);
		$view->change_parent($self->second);
	}
}
sub close_view {
	my ($self, $view) = @_;
	my $last_view = $view == $self->first ? $self->second
						: $self->first;
	$self->{parent}->unsplit_view($self, $last_view);
	$self->{parent}->unregister_view($view);
	$self->first = undef;
	$self->second = undef;
}
sub unsplit_view {
	my ($self, $container, $view) = @_;
	if ($container == $self->first) {
		$self->first = $view;
	} elsif ($container == $self->second) {
		$self->second = $view;
	}
	$container->change_parent(undef);
}
sub unregister_view {
	my ($self, $view) = @_;
	$self->{parent}->unregister_view($view);
}

sub change_parent {
	my ($self, $parent) = @_;
	$self->{parent} = $parent;
}

sub set_wrap {
	my ($self, $wrap) = @_;
	$self->first->set_wrap($wrap);
	$self->second->set_wrap($wrap);
}


1
