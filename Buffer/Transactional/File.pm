#!/usr/bin/perl
use strict;
use warnings;

package Buffer::Transactional::File;
@ISA = (Stub);

use Try::Tiny;

=head2 Transactional File Buffer

=cut

sub init {
    my ($self, $filename) = @_;
    $self->{filename} = $filename;
    $self->_open_file($filename) or return 0;
    return $self
}

sub _open_file {
    my ($self, $filename) = @_;
    open($fh, "<", $filename) or return 0;
    $self->{buffer} = [<$fh>];
    close $fh;
    $self->{dirty} = 0;
}

sub _save_file {
    my ($self, $filename) = @_;
    $filename //= $self->{filename}
    open(my $fh, ">", $filename) or return 0;
    print $fh join("\n", @{$self->{buffer}});
    close $fh;
}

sub lines { int(@{shift->{buffer}}) }

##
#  Get lines of text from the buffer
#  'start' and 'end' are line numbers, and both are inclusive.
##
sub text {
    my ($self, $start, $end) = @_;
    return [@{$self->{buffer}}[$start..$end]] if $start and $end
                and $self->lines > $start and $self->lines > $end;
    return 0;
}

##
#  Edit the buffer by passing in a change described by
#  the list [action, line, col, data].
#  'action' can be one of ( 'insert' | 'delete' ).
#  'line' and 'col' and the position of the start of the change.
#  'data' is either text to insert or number of characters to delete.
##
sub edit {
    my ($self, $action, $line, $col, $data) = @_;
    {
        'insert' => sub {
            my ($line, $col, $text) = @_;
        },
        'delete' => sub {
            my ($line, $col, $count) = @_;
        }, 
    }->{$action}->($line, $col, $data) or die;
}

sub commit { shift->_save_file() }

sub notify_event {
    my ($self, $event, $data) = @_;
}



1
