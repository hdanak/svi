#!/usr/bin/env perl
use strict;
use warnings;

package Page;

use Buffer;

sub new {
	my ($class, $window) = @_;

	my $self = {
		main	=> undef,
		window	=> $window,
		views	=> [],
	};
	bless $self, $class;

	$self->{main} = new View($buffer, $self);

	$self->set_focus($self->add_buffer(new Buffer));
	return $self;
}

sub split_view {
	my ($self, $type) = @_;
	$self->{main} = new Container($type, $self->{main}, $self);
}

sub set_focus {
	my ($self, $vnum) = @_;
}

sub register_view {
	my ($self, $view) = @_;
	push @{$self->{views}}, $view;
}

sub get_lines {
	my ($self) = @_;
	my @lines = ('x' x ($self->{window}->width/2)) x $self->{window}->visible_lines;
	return \@lines;
#	if (@{$self->{buffers}}) {
#	}
#	for (my $i = 0; $i < $self->{height}-1; $i++) {
#		my $line = $page->get_line($i) // '~';
#		my $padding = $self->{width} - length($line);
#		$self->{cursor}->puts($line . ('x' x $padding));
#	}
#	else {
#		return $lnum;
#	}
}

sub resize {
}

sub cursor_loc {
	my ($self) = @_;
	return (0,0);
}

1
