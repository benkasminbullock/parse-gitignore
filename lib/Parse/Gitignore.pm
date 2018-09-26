package Parse::Gitignore;
use warnings;
use strict;
use Carp;
use File::Slurper 'read_lines';
use File::Spec;

our $VERSION = '0.05';

sub read_gitignore
{
    my ($obj, $gitignore_file) = @_;
    if (! -f $gitignore_file) {
	carp ".gitignore file $gitignore_file doesn't exist";
	return;
    }
    if ($obj->{verbose}) {
	debugmsg ("Reading $gitignore_file.");
    }
    push @{$obj->{files}}, $gitignore_file;
    my @lines = read_lines ($gitignore_file);
    my (undef, $dir, undef) = File::Spec->splitpath ($gitignore_file);
    if ($obj->{verbose}) {
	debugmsg ("Directory is '$dir'.");
    }
    # Hash of ignored files.
    for my $line (@lines) {
	# Skip comment lines and empty lines
	if ($line =~ /^\s*(#|$)/) {
	    next;
	}
	if ($obj->{verbose}) {
	    debugmsg ("Processing '$line' in '$dir'.");
	}
	if ($line =~ m!/$!) {
	    for my $ignored_file (glob ("$line/*")) {
		my $pignored_file = File::Spec->rel2abs ($ignored_file);
		if ($obj->{verbose}) {
		    debugmsg ("Ignoring '$pignored_file' in '$dir'.");
		}
		$obj->{ignored}{$pignored_file} = 1;
	    }
	    next;
	}
	for my $ignored_file (glob ($line)) {
	    my $pignored_file = File::Spec->rel2abs ($ignored_file);
	    if ($obj->{verbose}) {
		debugmsg ("Ignoring '$pignored_file' in '$dir'.");
	    }
	    $obj->{ignored}{$pignored_file} = 1;
	}
    }
}

sub excludesfile
{
    my ($obj, $excludesfile) = @_;
    if (! -f $excludesfile) {
	carp "No such excludesfile: $excludesfile";
	return;
    }
    my @lines = read_lines ($excludesfile);
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
    my ($class, $gitignore_file, %options) = @_;
    my $obj = {
	# The globs which should be ignored.
	ignored => {},
	# The .gitignore files we have read so far.
	file_list => [],
	#
	verbose => $options{verbose},
    };
    bless $obj, $class;
    if ($gitignore_file) {
	if ($obj->{verbose}) {
	    debugmsg ("Reading '$gitignore_file'.");
	}
	$obj->read_gitignore ($gitignore_file);
    }
    return $obj;
}

sub ignored
{
    my ($obj, $file) = @_;
    $file = File::Spec->rel2abs ($file);
    return $obj->{ignored}{$file};
}

sub debugmsg
{
    my (undef, $file, $line) = caller (0);
    $file =~ s!.*/!!;
    print "$file:$line: @_\n";
}

1;
