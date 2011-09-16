#!/usr/bin/env perl

package Terminal;

use strict;
use warnings;

use Term::ReadKey;

sub new {
	my ($class, $window) = @_;
	my $self = {
		size	=> undef,
		window	=> $window,
	};
	bless $self, $class;

	$SIG{'__DIE__'} = sub { print "Dying at ", caller; $self->quit }; 
	$SIG{'WINCH'} = sub { $self->resize($self->query_size) };
	$SIG{'TERM'} = sub { $self->quit };
	$SIG{'KILL'} = sub { $self->quit };

	$self->init;

	return $self;
}
sub size:lvalue { (shift)->{size} }
sub height:lvalue { (shift)->{size}->[0] }
sub width:lvalue { (shift)->{size}->[1] }
sub term { shift }

sub init {
	my ($self) = @_;
	ReadMode 'raw';
	$self->resize($self->query_size);
}
sub freeze {
	ReadMode 'normal';
}
sub restore {
	my ($self) = @_;
	ReadMode('raw');
	$self->resize($self->query_size);
	$self->{window}->draw;
}
sub quit {
	ReadMode 'normal';
	exit;
}

sub write {
	my ($self, @str) = @_;
	print @str;
}

sub get_key {
	return (ReadKey(0), ReadKey(-1));
}

sub query_cursor {
	print "\033[6n";
	my $response = ReadKey(0);
	while ($_ = ReadKey(-1)) {
		$response .= $_;
	}
	my ($junk, $line, $col) = split /[\[;R]/, $response;
	return [$line, $col];
}
sub move_cursor {
	my ($self, $point) = @_;
	return 0 if !$self->_check_bounds($point);
	print "\033[".($point->[0]).';'.($point->[1]).'H';
	return 1;
}

sub query_size {
	my @term_size = (GetTerminalSize())[0..1];
	return [$term_size[1], $term_size[0]];
}
sub resize {
	my ($self, $size) = @_;
	$self->size = $size;
	$self->{window}->resize($size);
}

sub _check_bounds {
	my ($self, $point) = @_;
	return 1 if ($point->[0] <= $self->height
		  && $point->[0] >= 1
		  && $point->[1] <= $self->width
		  && $point->[1] >= 1);
	return 0;
}


1
