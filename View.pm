#!/usr/bin/env perl

package View;
use base qw(Container);

use strict;
use warnings;

use Line;
use Buffer;
use Cursor;

sub new {
	my ($class, $origin, $size, $parent, $buffer) = @_;
	my $self = new Container($origin, $size, $parent);

	$self->add_child(
		'lines',
		[],
		sub {
			my $lines = shift;
			map {$_->transpose([0, $self->{origin}->[1]])} @$lines;
		},
		sub {
			my $lines = shift;
			map {$_->resize([0, $self->width])} @$lines; # 0 means auto
		},
	);
	$self->{cursor}	= new Cursor($origin, $size, $self->term);
	$self->{buffer}	= $buffer // Buffer::DefaultBuffer;
	$self->{start}	= 0;
	bless $self, $class;

	$self->parent->register_view($self);

	$self->init_buffer;

	return $self;
}
sub buffer { (shift)->{buffer} }
sub cursor { (shift)->{cursor} }

sub init_buffer {
	my ($self) = @_;
	my $count = 0;
	splice @{$self->lines}, 0, @{$self->lines};
	for my $row (@{$self->buffer}) {
		my $line = new Line([$self->origin->[0] + $count,
				     $self->origin->[1]],
				    $self->width,
				    $self->term);
		$count += $line->height;
		push @{$self->lines}, $line;
		$line->put($row);
	}
#	print "size: ", $self->width, ',', $self->height, "\n";
#	print @{$self->term->query_size};
#	exit;
}

sub split_vert {
	my ($self) = @_;
	$self->parent->split_view($self, 'VERT');
}
sub split_horiz {
	my ($self) = @_;
	$self->parent->split_view($self, 'HORIZ');
}
sub change_parent {
	my ($self, $parent) = @_;
	$self->{parent} = $parent;
}

sub draw {
	my ($self) = @_;
	for my $l (@{$self->lines}) {
		$l->draw;
	}
	$self->cursor->down;
	while ($self->cursor->down) {
		$self->cursor->print_clear('~');
	}
}

sub set_wrap {
	my ($self, $wrap) = @_;
	$self->{wrap} = $wrap;
	map {$_->set_wrap($wrap)} @{$self->lines};
}


1
