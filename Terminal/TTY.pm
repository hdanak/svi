#!/usr/bin/perl
use strict;
use warnings;

package Terminal::TTY;
@ISA = (Stub);

use Term::ReadKey;


=head2 TTY Terminal Interface

=cut

sub init {
    my ($self, $controller) = @_;

    $self->controller = $controller;
    $self->mode 'raw';
    $self->cursor(0, 0);

	$SIG{'__DIE__'} = sub { print 'Dying at '.caller; $self->quit }; 
	$SIG{'WINCH'} = sub { $self->{controller}->notify_event('resize', [$self->size]) };
	$SIG{'TERM'} = sub { $self->quit };
	$SIG{'KILL'} = $SIG{'TERM'};

    return $self;
}

sub notify_event {
    my ($self, $event, $data) = @_;
}

sub freeze {
    $self->mode 'normal';
}

sub restore {
	my ($self) = @_;
    $self->mode 'raw';
    $self->size;
	$self->draw;
}

sub quit {
	ReadMode 'restore';
	exit;
}

sub get_key {
	return (ReadKey(0), ReadKey(-1));
}

sub mode {
    my ($self, $new_mode) = @_;
    if (defined $new_mode) {
        $self->{mode} = $new_mode;
        ReadMode($new_mode);
    } else { return $self->{mode} }
}

sub cursor {
    my ($self, $line, $col) = @_;
    unless (@_ > 1) {
	    print "\033[6n";
	    my $response = ReadKey(0);
	    while ($_ = ReadKey(-1)) {
	    	$response .= $_;
        }
        my ($junk, $line, $col) = split /[\[;R]/, $response;
	} else {
	    return 0 if !$self->_check_bounds($line, $col);
	    print "\033[".($line).';'.($col).'H';
    }
    return $line, $col;
}

sub size { (GetTerminalSize())[0..1] }
sub lines { ${shift->size}[0]}
sub cols { ${shift->size}[1]}

sub _check_bounds {
	my ($self, $line, $col) = @_;
	return 1 if ($line >= 1 && $col >= 1
                  && $line <= $self->lines
                  && $col <= $self->cols);
	return 0;
}



1
