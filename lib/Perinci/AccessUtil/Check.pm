package Perinci::AccessUtil::Check;

our $DATE = '2014-10-23'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(check_riap_res);

sub check_riap_res {
    my $res = shift;

    my $ver = $res->[3]{'riap.v'} // 1.1;
    return [501, "Riap version returned by server ($ver) is not supported, ".
                "only recognize v1.1 and v1.2"]
        unless $ver == 1.1 || $ver == 1.2;

    if ($ver >= 1.2) {
        # check and strip riap.*
        for my $k (keys %{$res->[3]}) {
            next unless $k =~ /\Ariap\./;
            my $val = $res->[3]{$k};
            if ($k eq 'riap.v') {
            } elsif ($k eq 'riap.result_encoding') {
                return [501, "Unknown result_encoding returned by server ".
                            "($val), only base64 is supported"]
                    unless $val eq 'base64';
                require MIME::Base64;
                $res->[2] = MIME::Base64::decode_base64($res->[2]//'');
            } else {
                return [501, "Unknown Riap attribute in result metadata ".
                            "returned by server ($k)"];
            }
            delete $res->[3]{$k};
        }
    }

    $res;
}

1;
# ABSTRACT: Utility module for Riap client/server

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::AccessUtil::Check - Utility module for Riap client/server

=head1 VERSION

This document describes version 0.01 of Perinci::AccessUtil::Check (from Perl distribution Perinci-AccessUtil-Check), released on 2014-10-23.

=head1 SYNOPSIS

 use Perinci::AccessUtil::Check qw(check_riap_res);
 my $res = check_riap_res([200,"OK"]);

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 check_riap_res($envres) => array

Starting in Riap protocol v1.2, client is required to check and strip all
C<riap.*> keys in result metadata (C<< $envres->[3] >>). This routine does just
that.

This routine is used by Riap client libraries, e.g. L<Perinci::Access::Lite>,
L<Perinci::Access::Perl>, and L<Perinci::Access::HTTP::Client>,
L<Perinci::Access::Simple::Client>.

If there is no error, will return C<$envres> with all C<riap.*> keys already
stripped. If there is an error, an error response will be returned instead.
Either way, you can use the response returned by this function to user.

=head1 SEE ALSO

L<Riap>, L<Perinci::Access>.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-AccessUtil-Check>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Perinci-AccessUtil-Check>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-AccessUtil-Check>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
