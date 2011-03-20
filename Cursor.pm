#!/usr/bin/env perl
use strict;
use warnings;

package Cursor;

sub new {
	my ($class, $col, $line, $window) = @_;
	my $self = {
		col	=> $col // 0,
		line	=> $line // 0,
		window	=> $window,
	};
	bless $self, $class;
	$self->to($self->{col}, $self->{line});
	return $self;
}

sub to {
	my ($self, $col, $line) = @_;
	$self->{col} = $col;
	$self->{line} = $line;
	print "\033[".$line.';'.$col.'H';
	return $self;
}

sub down {
	my ($self, $lines) = @_;
	$lines //= 1;
	return -1 if $lines + $self->{line} > $self->{window}->height;
	$self->to($self->{col}, $self->{line}+$lines);
	return $lines + $self->{line};
}

sub puts {
	my ($self, $str) = @_;
	print $str, "\n";
	$self->{col}++;
	$self->{line} += length($str);
}

sub print {
	my ($self, $str) = @_;
	$self->{line} += length($str);
	print $str;
	return $self;
}

sub col {
	my ($self) = @_;
	$self->{col};
}

sub line {
	my ($self) = @_;
	$self->{line};
}

sub clear_line {
	my ($self, $line) = @_;
	$self->to(0, $line)
	     ->print(' ' x $self->{window}->width)
	     ->to(0, $line);
}


1
