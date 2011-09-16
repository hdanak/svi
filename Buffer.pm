#!/usr/bin/env perl
use strict;
use warnings;

package Buffer;

sub new {
	my ($class) = @_;

	my $self = [];

	bless $self, $class;
}

sub DefaultBuffer {
	my $lines = [
		"This is a new buffer",
		"Stuff goes here"
	];
	bless $lines, 'Buffer';
}

1
