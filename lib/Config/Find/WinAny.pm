package Config::Find::WinAny;

our $VERSION = '0.03';

use strict;
use warnings;

use Carp;

use Config::Find::Any;

our @ISA = qw(Config::Find::Any);

sub app_dir {
    my ($class, $name)=@_;

    $name=$class->guess_script_name
	unless defined $name;

    if (exists $ENV{$name.'_HOME'}) {
	return $ENV{$name.'_HOME'}
    }
    $class->guess_script_dir;
}

sub app_user_dir {
    my ($class, $name)=@_;
    return File::Spec->catfile($class->app_dir($name),
			       'Users',
			       $class->my_getlogin);
}

sub system_temp {
    my $class=shift;

    return $ENV{TEMP}
	if defined $ENV{TEMP};

    return $ENV{TMP}
	if defined $ENV{TMP};

    return File::Spec->catfile($ENV{windir}, 'Temp')
	if defined $ENV{windir};

    return 'C:\Temp';
}

sub _var_dir {
    my ($class, $name, $more_name, $scope)=@_;
    if ($scope eq 'user') {
	File::Spec->catfile($class->app_user_dir($name), $name, 'Data', $more_name)
    }
    else {
	File::Spec->catfile($class->app_dir($name), 'Data', $more_name);
    }
}

sub _bin_dir {
    my ($class, $name, $more_name, $scope)=@_;
    if ($scope eq 'app') {
	$class->app_dir($name);
    }
    else {
	die "unimplemented option scope => $scope";
    }
}

sub look_for_file {
    my ($class, $name, $write, $global)=@_;
    my $fn;
    my $fnwe=$class->add_extension($name, 'cfg');
    if ($write) {
	if ($global) {
	    return File::Spec->catfile($class->app_dir($name), $fnwe)
	}
	else {
	    # my $login=getlogin();
	    return File::Spec->catfile($class->app_user_dir($name),
				       $fnwe );
	}
    }
    else {
	unless ($global) {
	    $fn=File::Spec->catfile($class->app_user_dir, $fnwe );
	    return $fn if -f $fn;
	}
	$fn=File::Spec->catfile($class->app_dir($name), $fnwe);
	return $fn if -f $fn;
    }
    return undef;
}

sub look_for_dir_file {
    my ($class, $dir, $name, $write, $global)=@_;
    my $fn;
    my $fnwe=$class->add_extension($name, 'cfg');
    if ($write) {
	if ($global) {
	    return File::Spec->catfile($class->app_dir($name), $dir, $fnwe)
	}
	else {
	    # my $login=getlogin();
	    return File::Spec->catfile($class->app_user_dir($name),
				       $dir, $fnwe );
	}
    }
    else {
	unless ($global) {
	    $fn=File::Spec->catfile($class->app_user_dir($name),
				    $dir, $fnwe );
	    return $fn if -f $fn;
	}
	$fn=File::Spec->catfile($class->app_dir($name),
				$dir, $fnwe);
	return $fn if -f $fn;
    }
    return undef;
}

1;
__END__

=head1 NAME

Config::Find::WinAny - Behaviours common to any Win32 OS for Config::Find

=head1 SYNOPSIS

  # don't use Config::Find::WinAny;
  use Config::Find;

=head1 ABSTRACT

Implements features common to all the Win32 OS's

=head1 DESCRIPTION

This module implements Config::Find for Win32 OS's.

Order for config files searching is...

  1  /$path_to_script/Users/$user/$name.cfg    [user]
  2  /$path_to_script/$name.cfg                [global]

unless when C<$ENV{${name}_HOME}> is defined. That changes the search
paths to...

  1  $ENV{${name}_HOME}/Users/$user/$name.cfg  [user]
  2  $ENV{${name}_HOME}/$name.cfg              [global]


When the "several configuration files in one directory" aproach is
used, the order is something different...

  1  /$path_to_script/Users/$user/$dir/$name.cfg  [user]
  2  /$path_to_script/$dir/$name.cfg              [global]

(it is also affected by C<$ENV{${name}_HOME}> variable)


=head2 EXPORT

None by default.

=head1 SEE ALSO

L<Config::Find>, L<Config::Find::Any>

=head1 AUTHOR

Salvador Fandiño, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Salvador Fandiño

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
