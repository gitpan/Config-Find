package Config::Find::Unix;

use 5.006;

our $VERSION = '0.01';

use strict;
use warnings;

use File::HomeDir;
use Config::Find::Any;

our @ISA=qw(Config::Find::Any);

sub app_dir {
    my $class=shift;
    my $script=$class->guess_script_name;
    if (exists $ENV{$script.'_HOME'}) {
	return $ENV{$script.'_HOME'}
    }
    $class->parent_dir($class->guess_script_dir);
}

sub look_for_file {
    my ($class, $name, $write, $global)=@_;
    my $fn;
    if ($write) {
	if ($global) {
	    my $fnwe=$class->add_extension($name, 'conf');

	    my $etc=File::Spec->catfile($class->app_dir(), 'etc');
	    return File::Spec->catfile($etc, $fnwe) if -e $etc;

	    $etc=File::Spec->catfile($class->app_dir(), 'conf');
	    return File::Spec->catfile($etc, $fnwe) if -e $etc;

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
	# looks in ./../etc/whatever.conf relative to the running script
	my $fnwe=$class->add_extension($name, 'conf');
	$fn=File::Spec->catfile($class->app_dir(), 'etc', $fnwe);
	return $fn if -f $fn;

	# looks in ./../conf/whatever.conf relative to the running script
	$fn=File::Spec->catfile($class->app_dir(), 'conf', $fnwe);
	return $fn if -f $fn;

	# looks in /etc/whatever.conf
	$fn=File::Spec->catfile('/etc', $fnwe);
	return $fn if -f $fn;

    }
    return undef;
}

sub look_for_dir_file {
    my ($class, $dir, $name, $write, $global)=@_;
    my $fn;
    my $fnwe=$class->add_extension($name, 'conf');
    if ($write) {
	if ($global) {
	    my $etc=File::Spec->catfile($class->app_dir(), 'etc');
	    return File::Spec->catfile($etc, $dir, $fnwe) if -e $etc;

	    $etc=File::Spec->catfile($class->app_dir(), 'conf');
	    return File::Spec->catfile($etc, $dir, $fnwe) if -e $etc;

	    return File::Spec->catfile('/etc', $dir, $fnwe);

	}
	else {
	    return File::Spec->catfile(home(), ".$dir", $fnwe);
	}
    }
    else {
	# looks in ~/.whatever
	unless ($global) {
	    my $fn=File::Spec->catfile(home(), ".$dir", $fnwe);
	    return $fn if -f $fn;
	}

	# looks in ./../etc/whatever.conf relative to the running script
	$fn=File::Spec->catfile($class->app_dir(), 'etc', $dir, $fnwe);
	return $fn if -f $fn;

	# looks in ./../conf/whatever.conf relative to the running script
	$fn=File::Spec->catfile($class->app_dir(), 'conf', $dir, $fnwe);
	return $fn if -f $fn;

	# looks in system /etc/whatever.conf
	$fn=File::Spec->catfile('/etc', $dir, $fnwe);
	return $fn if -f $fn;

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
