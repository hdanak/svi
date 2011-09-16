#!/usr/bin/env perl

package Window;
use base qw(Container);

use Data::Dumper;
use feature 'switch';
use strict;
use warnings;
require 5.010;

use Container;
use Page;
use Line;
use Terminal;

sub new {
	my ($class, @filenames) = @_;
	my $self = new Container([1,1]);
	bless $self, $class;

	$self->{term}	= new Terminal($self);
	$self->{front}	= undef; # current page number
	$self->{mode}	= 'COMMAND';
	$self->add_child(
		'status',
		new Line([$self->height, 1], $self->width, $self->{term}),
		sub {
			my $child = shift;
			$child->transpose([$self->height, 1]);
		},
		sub {
			my $child = shift;
			$child->resize([0, $self->width]); # 0 means auto
		}
	);
	$self->add_child(
		'pages',
		[],
		sub {
			my $pages = shift;
			$pages->[$self->{front}]->transpose([@$pages>1?2:1, 1])
				if defined $self->{front};
		},
		sub {
			my $pages = shift;
			$pages->[$self->{front}]->resize([$self->height-(@$pages>1?2:1), $self->width])
				if defined $self->{front};
		},
	);

	$self->add_page(new Page($self->{origin}, [$self->height-1, $self->width], $self));

	return $self;
}

sub term {
	my ($self) = @_;
	return $self->{term};
}

sub add_page {
	my ($self, $page) = @_;
	$self->flip(push(@{$self->pages}, $page)-1);
}

sub flip {
	my ($self, $pnum) = @_;
	if ($pnum > @{$self->pages}) {
		die "Page $pnum doesn't exist";
	}
	$self->{front} = $pnum;

	$self->draw;
}

sub draw {
	my ($self) = @_;
	#print "Drawing page $self->{front}";
	$self->pages->[$self->{front}]->draw;
}

sub msg_status {
	my ($self, $msg) = @_;
}

sub update_status {
	my ($self) = @_;
	my $status_line = '';
	$status_line .= '-- INSERT --'
		if $self->{mode} eq 'INSERT';
	$self->status->write($status_line);
}

sub switch_mode {
	my ($self, $mode) = @_;
	given ($mode) {
		when ('COMMAND') {
			$self->{mode} = 'COMMAND';
			$self->update_status;
		}
		when ('INSERT') {
		}
		when ('STATUS') {
			$self->{mode} = 'STATUS';
			$self->status->write(':');
		}
		when ('VISUAL') {
		}
		default {
			die "Mode '$mode' isn't a valid mode";
		}
	}
}

sub run {
	my ($self) = @_;

	$self->flip($self->{front});

	while (my ($key, $esc_seq) = $self->{term}->get_key) {
		if ($self->{mode} eq 'COMMAND') {
			given ($key) {
				when ('') {
					$self->{term}->freeze;
					kill 19, $$;
					$self->{term}->restore;
				}
				when (':') {
					$self->switch_mode('STATUS');
				}
			}
		}
		elsif ($self->{mode} eq 'INSERT') {
			given ($key) {
				when (['', '']) {
					$self->switch_mode('COMMAND');
				}
				when ('') {
				}
				default {
				}
			}
		}
		elsif ($self->{mode} eq 'STATUS') {
			given ($key) {
				when (['', '']) {
					unless (defined $esc_seq) {
						$self->switch_mode('COMMAND');
					} else {
					}
				}
				when (10 == ord $key) {
					given ($self->status->text) {
						when (/q/) {
							kill 15, $$;
						}
					}
					$self->switch_mode('COMMAND');
				}
				default {
					$self->status->append($key);
				}
			}
		}
	}
}


1
