#!/usr/bin/env perl
use strict;
use warnings;

package View;

sub new {
	my ($class, $parent) = @_;

	my $self = {
		parent	=> $parent,
	};

	bless $self, $class;
}

1
