#!/usr/bin/env perl
use strict;
use warnings;

package Container;

sub new {
	my ($class, $type, $parent) = @_;

	my $self = {
		type	=> $type, # 'VERT' or 'HORIZ'
		first	=> undef,
		second	=> undef,
		parent	=> $parent,
	};

	bless $self, $class;
}

1
