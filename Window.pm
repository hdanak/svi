#!/usr/bin/env perl

package Window;

use Data::Dumper;
use feature 'switch';
use strict;
use warnings;
require 5.010;

use Term::ReadKey;

use Page;
use Cursor;
use StatusLine;


$SIG{'__DIE__'} = sub { ReadMode('normal') }; 

sub new {
	my ($class, @filenames) = @_;

	my $self = {
		pages	=> [], # list of pages
		front	=> undef, # current page number
		width	=> 0, # term width
		height	=> 0, # term height
		mode	=> 'COMMAND',
		cursor	=> undef,
		status	=> undef,
	};
	bless $self, $class;

	$self->{cursor} = new Cursor(0,0, $self);
	$self->{status} = new StatusLine($self->{cursor}, $self);

	$self->add_page(new Page($self));

	$self->reflow();

	return $self;
}

sub width {
	my ($self) = @_;
	$self->{width};
}

sub height {
	my ($self) = @_;
	$self->{height};
}

sub mode {
	my ($self) = @_;
	$self->{mode};
}

sub add_page {
	my ($self, $page) = @_;
	$self->flip(push(@{$self->{pages}}, $page)-1);
}

sub flip {
	my ($self, $pnum) = @_;
	if ($pnum > @{$self->{pages}}) {
		die "Page $pnum doesn't exist";
	}
	$self->{front} = $pnum;

	$self->draw($pnum);

	# Uncomment if useful
	#return $self->{pages}->[$pnum];
}

sub reflow {
	my ($self) = @_;
	($self->{width}, $self->{height}) = (GetTerminalSize())[0..1];
	foreach my $page (@{$self->{pages}}) {
		$page->resize($self->{width}, $self->{height});
	}
	$self->draw($self->{front});
}

sub visible_lines {
	my ($self) = @_;
	return $self->{height} - 1;
}

sub draw {
	my ($self, $pnum) = @_;
	my $page = $self->{pages}->[$pnum];
	my $visible_lines = $page->get_lines;
	$self->{cursor}->to(0,0);
	my $filler = '';
	for my $line (@$visible_lines) {
		$filler = ' ' x ($self->width - length($line));
		$self->{cursor}->print($line . $filler);
		$self->{cursor}->down;
	}
	$self->{cursor}->to(0,0);
}

sub write_status {
	my ($self, $str) = @_;
}

sub msg_status {
	my ($self, $msg) = @_;
}

sub switch_mode {
	my ($self, $mode) = @_;
	given ($mode) {
		when ('COMMAND') {
			$self->{mode} = 'COMMAND';
			$self->{cursor}->to($self->{pages}->[$self->{front}]->cursor_loc);
		}
		when ('INSERT') {
		}
		when ('STATUS') {
			$self->{mode} = 'STATUS';
			$self->{status}->mode_start;
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

	$SIG{'WINCH'} = sub { $self->reflow };
	$SIG{'TERM'} = sub { $self->quit };
	$SIG{'KILL'} = sub { $self->quit };

	ReadMode 'raw';
	my $key = undef;
	while ($key=ReadKey(0)) {
		if ($self->{mode} eq 'COMMAND') {
			given ($key) {
				when ('') {
					ReadMode 'normal';
					kill 19, $$;
					ReadMode('raw');
					$self->reflow;
				}
				when ('') {
					kill 15, $$;
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
					my $esc_seq = ReadKey(-1);
					unless (defined $esc_seq) {
						$self->{status}->mode_stop;
						$self->switch_mode('COMMAND');
					} else {
					}
				}
				default {
					print ord($key);
				}
			}
		}
	}
}

sub quit {
	my ($self, $code) = @_;
	ReadMode 'normal';
	exit ($code // 0);
}

1
