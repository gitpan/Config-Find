package Config::Find::WinAny;

our $VERSION = '0.01';

use strict;
use warnings;

use Config::Find::Any;

our @ISA = qw(Config::Find::Any);

sub app_dir {
    my $class=shift;
    my $script=$class->guess_script_name;
    if (exists $ENV{$script.'_HOME'}) {
	return $ENV{$script.'_HOME'}
    }
    $class->guess_script_dir;
}

sub app_user_dir {
    my $class=shift;
    my $login=getlogin();
    return File::Spec->catfile($class->app_dir,
			       'Users',
			       ( defined($login) ?
				 $login : '_UNKNOW_' ));
}

sub look_for_file {
    my ($class, $name, $write, $global)=@_;
    my $fn;
    my $fnwe=$class->add_extension($name, 'cfg');
    if ($write) {
	if ($global) {
	    return File::Spec->catfile($class->app_dir, $fnwe)
	}
	else {
	    my $login=getlogin();
	    return File::Spec->catfile($class->app_user_dir,
				       $fnwe );
	}
    }
    else {
	unless ($global) {
	    $fn=File::Spec->catfile($class->app_user_dir, $fnwe );
	    return $fn if -f $fn;
	}
	$fn=File::Spec->catfile($class->app_dir(), $fnwe);
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
	    return File::Spec->catfile($class->app_dir, $dir, $fnwe)
	}
	else {
	    my $login=getlogin();
	    return File::Spec->catfile($class->app_user_dir,
				       $dir, $fnwe );
	}
    }
    else {
	unless ($global) {
	    $fn=File::Spec->catfile($class->app_user_dir,
				    $dir, $fnwe );
	    return $fn if -f $fn;
	}
	$fn=File::Spec->catfile($class->app_dir(),
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

Order for config files searching is:

  1  /$path_to_script/Users/$user/$name.cfg    [user]
  2  /$path_to_script/$name.cfg                [global]

unless $ENV{${name}_HOME} is defined, then the order is:

  1  $ENV{${name}_HOME}/Users/$user/$name.cfg  [user]
  2  $ENV{${name}_HOME}/$name.cfg              [global]


When the "several configuration files in one directory" aproach is
used, the order is something different:

  1  /$path_to_script/Users/$user/$dir/$name.cfg  [user]
  2  /$path_to_script/$dir/$name.cfg              [global]

(also affected by C<$ENV{${name}_HOME}>)


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
