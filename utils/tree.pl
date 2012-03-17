#!/usr/bin/perl
use strict;
use warnings;
use feature 'state';


sub run {
    my @files = split("\n", qx{ git ls-files });
    my $dirtree = { '.' => '.', '..' => undef};
    for (@files) {
        my @parts = split '/';
        my $curdir = $dirtree;
        my $prevdir;
        while (@parts > 1) {
            my $dir = shift @parts;
            $curdir->{$dir} = { '.' => $dir, '..' => $curdir }
                unless exists $curdir->{$dir};
            $curdir = $curdir->{$dir};
        }
        $curdir->{$parts[0]} = $parts[0];
    }
    print draw_tree($dirtree);
    exit 0;
}
sub file_mtime {
    my ($filename) = @_;
    state %cache;
    if ($cache{$filename}) {
        return $cache{$filename};
    } else {
        my @fstat = stat $filename;
        $cache{$filename} = $fstat[9];
        return $fstat[9];
    }
}
sub annotate {
    my ($dirtree, $filename) = @_;
    my $filepath = abs_path($dirtree, $filename);
    my $output = $filename;
    my $pod_info = (split "\n", `pod2text $filepath`)[0];
    if (defined $pod_info) {
        $pod_info =~ s/^\s*(.*?)\s*$/$1/;
        $output .= " - $pod_info";
        
    }
    return $output;
}
sub draw_tree {
    my ($dirtree) = @_;
    my $drawing = '';
    my @dirstack = ($dirtree);
    my @prefix;
    while (@dirstack) {
        my $foo = pop @dirstack;
        if ('HASH' eq ref $foo) {
            $drawing .= $foo->{'.'} . "\n";
            my @children = map {
                [ join('', @prefix)
                , '├── '
                , 'HASH' eq ref $foo->{$_} ? $foo->{$_} : annotate($foo, $_)
                ]
            } sort {
                file_mtime(abs_path($foo, 'HASH' eq ref $a ? $a->{'.'} : $a))
            cmp file_mtime(abs_path($foo, 'HASH' eq ref $b ? $b->{'.'} : $b))
            } grep { $_ ne '.' and $_ ne '..' } keys %$foo;
            $children[0]->[1] = '└── '; # 'last child' marker
            push @dirstack, @children;
            push @prefix, '│   ';
        } elsif ('ARRAY' eq ref $foo) {
            my ($indent, $symbol, $foo) = @$foo;
            if ($symbol eq '└── ') {
                pop @prefix;
                push @prefix, '    ' if 'HASH' eq ref $foo;
            }
            $drawing .= $indent.$symbol;
            push @dirstack, $foo;
        } else {
            $drawing .= $foo . "\n";
        }
    }
    return $drawing;
}
sub abs_path {
    my ($dirtree, $filename) = @_;
    my $curdir = $dirtree;
    my @path = ($filename);
    while (defined $curdir) {
        unshift @path, $curdir->{'.'};
        $curdir = $curdir ->{'..'};
    }
    my $uri = join '/', @path;
    return $uri;
}

run() unless caller;
