package Config::Find::Any;

use 5.006;

our $VERSION = '0.06';

use strict;
use warnings;

use Carp;
use File::Spec;
use File::Which;
use IO::File;


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

sub _open {
    my ($class, $write, $global, $fn)=@_;
    if ($write) {
	$class->create_parent_dirs($fn);
	return IO::File->new($fn, 'w');
    }
    defined($fn) ? IO::File->new($fn, 'r') : undef;
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

sub _temp_dir {
    my ($class, $name, $more_name, $scope)=@_;

    my $stemp=$class->system_temp;

    if ($scope eq 'global') {
	$class->my_catdir($stemp, $name, $more_name)
    }
    elsif ($scope eq 'user') {
	$class->my_catdir($stemp, $class->my_getlogin, $name, $more_name)
    }
    elsif ($scope eq 'app') {
	$class->my_catdir($class->app_dir($name), 'tmp', $more_name)
    }
    elsif ($scope eq 'process') {
	$class->my_catdir($stemp, $class->my_getlogin, $name, $$, $more_name)
    }
    else {
	croak "scope '$scope' is not valid for temp_dir method";
    }
}

sub guess_full_script_name {
    my $path = (File::Spec->splitpath($0))[1];
    if ($path eq '') {
        if (my $script=File::Which::which($0)) {
	    return File::Spec->rel2abs($script);
	}
    }
    return File::Spec->rel2abs($0) if -e $0;

    carp "unable to determine script '$0' location";
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
    my ($unit, $dir)=File::Spec->splitpath($script, 0);
    File::Spec->catdir($unit, $dir);
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

sub create_dir {
    my ($class, $dir)=@_;
    if (-e $dir) {
	-d $dir or croak "'$dir' exists but is not a directory";
    }
    else {
	$class->create_parent_dirs($dir);
	mkdir $dir or
	    die "unable to create directory '$dir' ($!)";
    }
    $dir;
}

sub look_for_file {
    my $class=shift;
    die "unimplemented virtual method $class->look_for_file() called";
}

sub look_for_dir_file {
    my $class=shift;
    die "unimplemented virtual method $class->look_for_dir_file() called";
}

sub my_catfile {
    my $class=shift;
    pop @_ unless defined $_[-1];
    File::Spec->catfile(@_);
}

sub my_catdir {
    my $class=shift;
    pop @_ unless defined $_[-1];
    File::Spec->catdir(@_);
}

sub my_getlogin {
    my $login=getlogin();
    $login = '_UNKNOW_' unless defined $login;
    $login;
}

1;

__END__

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
