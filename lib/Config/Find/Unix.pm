package Config::Find::Unix;

use 5.006;

our $VERSION = '0.06';

use strict;
use warnings;

use Carp;

use File::HomeDir;
use Config::Find::Any;

our @ISA=qw(Config::Find::Any);

sub app_dir {
    my ($class, $name)=@_;
    $name=$class->guess_script_name
	unless defined $name;

    if (exists $ENV{$name.'_HOME'}) {
	return $ENV{$name.'_HOME'}
    }
    $class->parent_dir($class->guess_script_dir);
}

sub system_temp { '/tmp' }

sub _var_dir {
    my ($class, $name, $more_name, $scope)=@_;

    if ($scope eq 'global') {
	$class->my_catfile('/var', $name, $more_name);
    }
    elsif ($scope eq 'user') {
	File::Spec->catfile(home(), '.'.$name, 'var', $more_name);
    }
    elsif ($scope eq 'app') {
	$class->my_catfile($class->app_dir($name), $more_name);
    }
    else {
	croak "scope '$scope' is not valid for var_dir method";
    }
}

sub _bin_dir {
    my ($class, $name, $more_name, $scope)=@_;
    if ($scope eq 'global') {
	'/usr/bin';
    }
    elsif ($scope eq 'user') {
	File::Spec->catfile(home(), 'bin');
    }
    elsif ($scope eq 'app') {
	File::Spec->catfile($class->app_dir($name), 'bin');
    }
    else {
	croak "scope '$scope' is not valid for bin_dir method";
    }
}


sub look_for_file {
    my ($class, $name, $write, $global)=@_;
    my $fn;
    if ($write) {
	if ($global) {
	    my $fnwe=$class->add_extension($name, 'conf');

	    unless ($class->is_one_liner) {
		my $etc=File::Spec->catfile($class->app_dir($name), 'etc');
		return File::Spec->catfile($etc, $fnwe) if -e $etc;

		$etc=File::Spec->catfile($class->app_dir($name), 'conf');
		return File::Spec->catfile($etc, $fnwe) if -e $etc;
	    }

	    return File::Spec->catfile('/etc', $fnwe);
	}
	else {
	    return File::Spec->catfile(home(), ".$name");
	}

    }
    else {

	# looks in ~/.whatever
	unless ($global) {
	    $fn=File::Spec->catfile(home(), ".$name");
	    return $fn if -f $fn;
	}

	for my $fnwe (map {$class->add_extension($name, $_)}
		      qw(conf cfg)) {
	    unless ($class->is_one_liner) {
		# looks in ./../etc/whatever.conf relative to the running script
		$fn=File::Spec->catfile($class->app_dir($name), 'etc', $fnwe);
		return $fn if -f $fn;
		
		# looks in ./../conf/whatever.conf relative to the running script
		$fn=File::Spec->catfile($class->app_dir($name), 'conf', $fnwe);
		return $fn if -f $fn;
	    }
	    # looks in /etc/whatever.conf
	    $fn=File::Spec->catfile('/etc', $fnwe);
	    return $fn if -f $fn;
	}
    }
    return undef;
}

sub look_for_helper {
    my ($class, $dir, $helper)=@_;
    my $path=File::Spec->catfile($dir, $helper);
    -e $path or
	croak "helper '$helper' not found";
    ((-f $path or -l $path) and -x $path)  or
	croak "helper '$helper' found at '$path' but it is not executable";
    return $path
}

sub look_for_dir_file {
    my ($class, $dir, $name, $write, $global)=@_;
    my $fn;
    if ($write) {
	my $fnwe=$class->add_extension($name, 'conf');
	if ($global) {
	    unless ($class->is_one_liner) {
		my $etc=File::Spec->catfile($class->app_dir($name), 'etc');
		return File::Spec->catfile($etc, $dir, $fnwe) if -e $etc;

		$etc=File::Spec->catfile($class->app_dir($name), 'conf');
		return File::Spec->catfile($etc, $dir, $fnwe) if -e $etc;
	    }

	    return File::Spec->catfile('/etc', $dir, $fnwe);

	}
	else {
	    return File::Spec->catfile(home(), ".$dir", $fnwe);
	}
    }
    else {
	# looks in ~/.whatever
	for my $fnwe (map {$class->add_extension($name, $_)}
		      qw(conf cfg)) {

	    unless ($global) {
		my $fn=File::Spec->catfile(home(), ".$dir", $fnwe);
		return $fn if -f $fn;
	    }

	    unless ($class->is_one_liner) {
		# looks in ./../etc/whatever.conf relative to the running script
		$fn=File::Spec->catfile($class->app_dir($name), 'etc', $dir, $fnwe);
		return $fn if -f $fn;

		# looks in ./../conf/whatever.conf relative to the running script
		$fn=File::Spec->catfile($class->app_dir($name), 'conf', $dir, $fnwe);
		return $fn if -f $fn;
	    }
	
	    # looks in system /etc/whatever.conf
	    $fn=File::Spec->catfile('/etc', $dir, $fnwe);
	    return $fn if -f $fn;
	}
    }
    return undef;
}




1;
__END__

=head1 NAME

Config::Find::Unix - Config::Find plugin for Unixen

=head1 SYNOPSIS

  # don't use Config::Find::Unix;
  use Config::Find;

=head1 ABSTRACT

Config::Find plugin for Unixen

=head1 DESCRIPTION

This module implements Config::Find for Unix

The order for searching the config files is:

  1  ~/.$name                             [user]
  2  /$path_to_script/../etc/$name.conf   [global]
  3  /$path_to_script/../conf/$name.conf  [global]
  4  /etc/$name.conf                      [global]

although if the environment variable C<$ENV{${name}_HOME}> is defined
it does

  1  ~/.$name                             [user]
  2  $ENV{${name}_HOME}/etc/$name.conf    [global]
  3  $ENV{${name}_HOME}/conf/$name.conf   [global]
  4  /etc/$name.conf                      [global]

instead.


When the "several configuration files in one directory" aproach is
used, the order is something different:

  1  ~/.$dir/$name.conf                        [user]
  2  /$path_to_script/../etc/$dir/$name.conf   [global]
  3  /$path_to_script/../conf/$dir/$name.conf  [global]
  4  /etc/$dir/$name.conf                      [global]

(also affected by C<$ENV{${name}_HOME}>)


=head2 EXPORT

None.

=head1 SEE ALSO

L<Config::Find>, L<Config::Find::Any>.

=head1 AUTHOR

Salvador Fandiño García, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Salvador Fandiño García

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
