package Parse::Gitignore;
use warnings;
use strict;
use Carp;
use Path::Tiny;
our $VERSION = '0.03';

sub read_gitignore
{
    my ($obj, $gitignore_file) = @_;
    if (! -f $gitignore_file) {
	carp ".gitignore file $gitignore_file doesn't exist";
	return;
    }
    my $file = path ($gitignore_file);
    $obj->{file} = $file;
    my @lines = $file->lines ();
    # Hash of ignored files.
    my %ignored;
    if ($obj->{excludesfile}) {
	push @lines, @{$obj->{excludesfile}};
    }
    for my $line (@lines) {
	if ($line =~ /^\s*#/) {
	    next;
	}
	for my $ignored_file (glob ($line)) {
	    my $pignored_file = path ($ignored_file);
	    $ignored{$pignored_file} = 1;
	}
    }
    for my $k (keys %ignored) {
	$obj->{ignored}{$k} = 1;
    }
}

sub excludesfile
{
    my ($obj, $excludesfile) = @_;
    if (! -f $excludesfile) {
	carp "No such excludesfile: $excludesfile";
	return;
    }
    my $file = path ($excludesfile);
    $obj->{file} = $file;
    my @lines = $file->lines ();
    my @oklines;
    for (@lines) {
	# Skip comments and empty lines.
	if (/^\s*(#|$)/) {
	    next;
	}
	push @oklines, $_;
    }
    $obj->{excludesfile} = \@oklines;
}

sub new
{
    my ($class, $gitignore_file) = @_;
    my $obj = {ignored => {}};
    bless $obj, $class;
    if ($gitignore_file) {
	$obj->read_gitignore ($gitignore_file);
    }
    return $obj;
}

sub ignored
{
    my ($obj, $file) = @_;
    my $pfile = path ($file);
    return $obj->{ignored}{$pfile};
}

1;
