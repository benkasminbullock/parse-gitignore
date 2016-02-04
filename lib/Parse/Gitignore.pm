package Parse::Gitignore;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw//;
%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
use warnings;
use strict;
use Carp;
use Path::Tiny;
our $VERSION = '0.02';

sub read_gitignore
{
    my ($obj, $gitignore_file) = @_;
    if (! -f $gitignore_file) {
	carp ".gitignore file $gitignore_file doesn't exist";
	return undef;
    }
    my $file = path ($gitignore_file);
    $obj->{file} = $file;
    my @lines = $file->lines ();
    my %ignored;
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

sub new
{
    my ($class, $gitignore_file) = @_;
    my $obj = {ignored => {}};
    bless $obj, $class;
    if ($gitignore_file) {
	$obj->read_gitignore ();
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
