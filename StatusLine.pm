#!/usr/bin/env perl
use strict;
use warnings;

package StatusLine;

sub new {
	my ($class, $cursor, $window) = @_;
	my $self = {
		buffer	=> undef,
		cursor	=> $cursor,
		window	=> $window,
	};
	$self->{buffer} = [];

	bless $self, $class;
}

sub mode_start {
	my ($self) = @_;
	$self->clear;
	$self->{cursor}->print(':');
}

sub clear {
	my ($self) = @_;
	$self->{buffer} = [];
	$self->{cursor}->clear_line($self->{window}->height);
}

sub mode_stop {
	my ($self) = @_;
	$self->update_status;
}

sub update_status {
	my ($self) = @_;
	my $status_line = '';
	$status_line .= '-- INSERT --'
		if $self->{window}->mode eq 'INSERT';
	my $cursor_pos = $self->{cursor}->line.','.$self->{cursor}->col.'        ';
	my $padding = $self->{window}->width - (length($status_line) + length($cursor_pos));
	$status_line .= (' ' x $padding) . $cursor_pos;
	$self->write($status_line);
}

sub write {
	my ($self, $str) = @_;
	my @old_cpos = ($self->{cursor}->col, $self->{cursor}->line);
	$self->{cursor}->to(0,$self->{window}->height)
	               ->print($str)
	               ->to(@old_cpos);
}

1
