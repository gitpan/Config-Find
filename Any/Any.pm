package Config::Find::Any;

use 5.006;

our $VERSION = '0.05';

use strict;
use warnings;

use Carp;
use File::Spec;
use File::Which;
use IO::File;


sub find {
    my $class=shift;
    my ($write, $global, $fn, @names)=$class->parse_opts(@_);
    if (defined $fn) {
      return ($write or -f $fn) ? $fn : undef;
    }
    $class->_find($write, $global, @names);
}

sub _find {
    my ($class, $write, $global, @names)=@_;
    for my $n (@names) {
	my $fn;
	if ($n=~/^(.*?)\/(.*)$/) {
	    my ($dir, $file)=($1, $2);
	    $fn=$class->look_for_dir_file($dir, $file, $write, $global);
	}
	else {
	    $fn=$class->look_for_file($n, $write, $global);
	}
	return $fn if defined $fn;
    }
    return undef;
}

sub open {
    my $class=shift;
    my ($write, $global, $fn, @names)=$class->parse_opts(@_);
    defined($fn) or $fn=$class->_find($write, $global, @names);
    $class->_open($write, $global, $fn);
}

sub _open {
    my ($class, $write, $global, $fn)=@_;
    if ($write) {
	$class->create_parent_dirs($fn);
	return IO::File->new($fn, 'w');
    }
    defined($fn) ? IO::File->new($fn, 'r') : undef;
}

sub install {
    my $class=shift;
    my $orig=shift;
    my ($write, $global, $fn, @names)=$class->parse_opts( mode => 'w',
							  @_);
    defined($fn) or $fn=$class->_find($write, $global, @names);
    $class->_install($orig, $write, $global, $fn);
}

sub _install {
    my ($class, $orig, $write, $global, $fn)=@_;
    croak "install mode has to be 'write'" unless $write;
    my $oh=IO::File->new($orig, 'r')
	or croak "unable to open '$orig'";
    my $fh=$class->_open($write, $global, $fn)
	or croak "unable to create config file '$fn'";
    while(<$oh>) { $fh->print($_) }
    close $fh
	or die "unable to write config file '$fn'";
    close $oh
	or die "unable to read '$orig'";
    return $fn;
}

sub parse_opts {
    my ($class, %opts)=@_;
    my $fn=$opts{file};
    my @names;
    if (exists $opts{name}) {
	@names=$opts{name};
    }
    elsif (exists $opts{names}) {
	UNIVERSAL->isa($opts{names}, 'ARRAY')
	    or croak "invalid argument for 'names', expecting an array ref";
	@names=@{$opts{names}}
    }
    else {
	@names=$class->guess_script_name();
    }
    my $write;
    if (exists $opts{mode}) {
	if ($opts{mode}=~/^r(ead)?$/i) {
	    # yes, do nothing!
	}
	elsif ($opts{mode}=~/w(rite)?$/i) {
	    $write=1;
	}
	else {
	    croak "invalid option mode => '$opts{mode}'";
	}
    }
    my $global;
    if (exists $opts{scope}) {
	if ($opts{scope}=~/^u(ser)?$/i) {
	    # yes, do nothing!
	}
	elsif ($opts{scope}=~/g(lobal)?$/i) {
	    $global=1;
	}
	else {
	    croak "invalid option mode => '$opts{scope}'";
	}
    }
    return ($write, $global, $fn, @names)
}

sub guess_full_script_name {
    my $path = (File::Spec->splitpath($0))[1];
    if ($path eq '') {
        if (my $script=File::Which::which($0)) {
	    return File::Spec->rel2abs($script);
	}
    }
    return File::Spec->rel2abs($0) if -e $0;

    die "unable to determine script '$0' location";
}

sub guess_script_name {
    my $name;
    (undef, undef, $name)=File::Spec->splitpath($0);
    $name=~/^(.+)\..*$/ and return $1;
    return undef if $name eq '';
    return $name;
}

sub guess_script_dir {
    my $class=shift;
    my $script=$class->guess_full_script_name;
    File::Spec->catfile((File::Spec->splitpath($script, 0))[0,1]);
}

sub is_one_liner { return $0 eq '-e' }

sub add_extension {
    my ($class, $name, $ext)=@_;
    return $name if ($name=~/\./);
    return $name.'.'.$ext;
}

sub create_parent_dirs {
    my ($class, $fn)=@_;
    my $parent=$class->parent_dir($fn);
    if (-e $parent) {
	-d $parent or
	    croak "'$parent' exists but is not a directory";
	-W $parent or
	    croak "not allowed to write in directory '$parent'";
    }
    else {
	$class->create_parent_dirs($parent);
	mkdir $parent or
	    die "unable to create directory '$parent' ($!)";
    }
}

sub parent_dir {
    my ($class, $dir)=@_;
    my @dirs=File::Spec->splitdir($dir);
    pop(@dirs) eq '' and pop(@dirs);
    File::Spec->catfile(@dirs);
}

sub look_for_file {
    my $class=shift;
    die "unimplemented virtual method $class->look_for_file() called";
}

sub look_for_dir_file {
    my $class=shift;
    die "unimplemented virtual method $class->look_for_dir_file() called";
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Config::Find::Any - Perl base class for Config::Find

=head1 SYNOPSIS

  # don't use Config::Find::Any;
  use Config::Find;

=head1 ABSTRACT

This module implements basic methods for L<Config::Find>.

=head1 DESCRIPTION

Every L<Config::Find> class has to be derived from this one and two
methods have to be redefined:

=over 4

=item $class->look_for_file($name, $write, $global)

=item $class->look_for_dir_file($dir, $name, $write, $global)

=back

=head2 EXPORT

None.

=head1 SEE ALSO

L<Config::Find>, L<Config::Find::Unix>, L<Config::Find::Win32>.

=head1 AUTHOR

Salvador Fandiño, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Salvador Fandiño

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
