#!/usr/bin/env perl
use strict;
use warnings;

package Container;

sub new {
	my ($class, $type, $view, $parent) = @_;

	my $self = {
		type	=> $type, # 'VERT' or 'HORIZ'
		first	=> undef,
		second	=> undef,
		parent	=> $parent,
	};
	bless $self, $class;

	$self->{first} = $view;
	$view->change_parent($self);
	$self->{second} = new View($view->buffer, $self);

}

sub split_view {
	my ($self, $view, $type) = @_;
	if ($view == $self->{first}) {
		$self->{first} = new Container($type, $view, $self);
		$view->change_parent($self->{first});
	} elsif ($view == $self->{second}) {
		$self->{second} = new Container($type, $view, $self);
		$view->change_parent($self->{second});
	}
}

sub view_close {
	my ($self, $view) = @_;
	my $last_view = $view == $self->{first} ? $self->{second}
						: $self->{first};
	$self->{parent}->unsplit_view($self, $last_view);
	$self->{parent}->unregister_view($view);
	$self->{first} = undef;
	$self->{second} = undef;
}

sub unsplit_view {
	my ($self, $container, $view) = @_;
	if ($container == $self->{first}) {
		$self->{first} = $view;
	} elsif ($container == $self->{second}) {
		$self->{second} = $view;
	}
	$container->change_parent(undef);
}

sub change_parent {
	my ($self, $parent) = @_;
	$self->{parent} = $parent;
}

sub unregister_view {
	my ($self, $view) = @_;
	$self->{parent}->unregister_view($view);
}

sub first {
	return $self->{first};
}

1
