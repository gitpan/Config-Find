package Config::Find::Win32;

our $VERSION = '0.01';

use strict;
use warnings;

our @ISA;

use Win32;
use Carp;

BEGIN {
    my $OS=uc Win32::GetOSName();
    if ($OS eq 'WIN95') {
	require Config::Find::Win95;
	@ISA=qw(Config::Find::Win95);
     }
     elsif ($OS eq 'WIN98') {
         require Config::Find::Win98;
         @ISA=qw(Config::Find::Win98);
    }
    elsif ($OS eq 'WINME') {
        require Config::Find::WinME;
        @ISA=qw(Config::Find::WinME);
    }
    elsif ($OS eq 'WINNT') {
        require Config::Find::WinNT;
        @ISA=qw(Config::Find::WinNT);
    }
    elsif ($OS eq 'WIN2000') {
	require Config::Find::Win2k;
	@ISA=qw(Config::Find::Win2k);
    }
    elsif ($OS eq 'WINXP') {
	require Config::Find::WinXP;
	@ISA=qw(Config::Find::WinXP);
    }
    elsif ($OS eq 'WINCE') {
	require Config::Find::WinCE;
	@ISA=qw(Config::Find::WinCE);
    }
    else {
	croak "Unknow MSWin32 OS '$OS'";
    }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Config::Find::Win32 - Autoload convenient Config::Find module for specific Win32 OS

=head1 SYNOPSIS

  # don't use Config::Find::Win32;
  use Config::Find

=head1 ABSTRACT

Autoload convenient Config::Find module for specific Win32 OS

=head1 DESCRIPTION

Stub documentation for Config::Find::Win32, created by h2xs.

=head2 EXPORT

None by default.



=head1 SEE ALSO

-

=head1 AUTHOR

Salvador Fandiño, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Salvador Fandiño

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
