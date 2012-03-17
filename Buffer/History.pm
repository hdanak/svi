#!/usr/bin/perl
use strict;
use warnings;

package Buffer::History;
use base 'Stub';


=head2 History Tree Structure

=cut

sub init {
    my ($self) = @_;
    $self->{root} = Node->new;
    $self->{head} = $self->{root};
}

sub change {
    my ($self, $change, $inverse) = @_;
    $self->{head} = $self->{head}->branch($change, $inverse);
}

sub undo {
    my ($self) = @_;
    my $inverse = $self->{head}->{inverse};
    $self->{head} = $self->{head}->{parent};
    return $inverse
}

##
#  'branch_num' is the branch number in the current head
##
sub redo {
    my ($self, $branch_num) = @_;
    my $branch= $self->{head}->{branches}->[$branch_num];
    $self->{head} = $branch;
    return $branch->{change};
}


package Node;
use base 'Stub';


=head2 History Node

=cut

sub init {
    my ($self, $parent, $change, $inverse) = @_;
    $self->{parent} = $parent;
    $self->{branches} = [];
    $self->{change} = $change;
    $self->{inverse} = $inverse;
    $self->{timestamp} = time;
}

sub branch {
    my ($self, $change, $inverse) = @_;
    if (@_ > 1) {
        my $new_node = Node->new($self, $change, $inverse);
        push (@{$self->{branches}}, $new_node);
        return $new_node
    }
}
sub branches { @{shift->{branches}} }

sub last_branch { shift->{branches}->[-1] }


1
