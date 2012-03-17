#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

package Buffer::Transactional::File;
use Buffer::History;
use base 'Stub';


=head2 Transactional File Buffer

=cut

sub init {
    my ($self, $filename) = @_;
    $self->{filename} = $filename;
    $self->{history} = History->new;
    $self->{buffer} = ['']; # note that this is indexed from 1, not 0
    $self->_load_file($filename) or return 0;
    return
}

sub _load_file {
    my ($self, $filename) = @_;
    open(my $fh, "<", $filename) or return 0;
    $self->{buffer} = ['', <$fh>];
    close $fh;
    $self->{dirty} = 0;
}

sub _save_file {
    my ($self, $filename) = @_;
    $filename //= $self->{filename};
    open(my $fh, ">", $filename) or return 0;
    print $fh join("\n", @{$self->{buffer}});
    close $fh;
}

sub commit { shift->_save_file() }

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

sub edit {
    my ($self, $action, @args) = @_;
    {
        insert => sub { my ($line, $col, $text) = @_;
            my $change = ['insert', $line, $col, $text];
            my $inverse = ['delete', $line, $col, length($text)];
            $self->{history}->change($change, $inverse);
        },
        delete => sub { my ($line, $col, $length) = @_;
            my $change = ['delete', $line, $col, $length];
            my $inverse = ['insert', $line, $col, substr($self->{buffer}->[$line], $col, $length)];
            # TODO: splice out $line from buffer
        }, 
        merge => sub { my ($line) = @_;
            my $change = ['merge', $line];
            my $inverse = ['split', $line, length($line)]; #XXX: off-by-one bug
            # TODO: merge line $line+1 into $line
        },
        split => sub { my ($line, $col) = @_;
            my $change = ['split', $line, $col];
            my $inverse = ['merge', $line];
            # TODO: insert line into buffer after $line, and move $col..-1 to it
        },
    }->{$action}->(@args) or die;
}

sub undo {
    my ($self) = @_;
    return 0;
}



1
