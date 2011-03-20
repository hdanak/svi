#!/usr/bin/env perl
use strict;
use warnings;

package Page;

use Buffer;

sub new {
	my ($class, $window) = @_;

	my $self = {
		view	=> undef,
		window	=> $window,
	};

	$self->{view} = 

	bless $self, $class;
	$self->set_focus($self->add_buffer(new Buffer));
	return $self;
}

sub add_buffer {
	my ($self, $buf) = @_;
}

sub set_focus {
	my ($self, $bnum) = @_;
}

sub keystroke {
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
