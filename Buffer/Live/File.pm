#!/usr/bin/perl
use strict;
use warnings;

package Buffer::Live::File;
@ISA = (Stub);

use Error qw(:try);


=head2 Transactional File Buffer

=cut

sub init {
    my ($self) = @_;
    $self->{file} = undef;
    $self->{dirty} = 0;
    return $self
}

sub open_file {
    my ($self, $file) = @_;
    try {
    my $self->{file} = open 
    $self->{dirty} = 0;
}

sub notify_event {
    my ($self, $event, $data) = @_;
}



1

