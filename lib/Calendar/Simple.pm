# $Id: Simple.pm 32 2006-09-10 10:47:26Z  $

=head1 NAME

Calendar::Simple - Perl extension to create simple calendars

=head1 SYNOPSIS

  use Calendar::Simple;

  my @curr      = calendar;             # get current month
  my @this_sept = calendar(9);          # get 9th month of current year
  my @sept_2002 = calendar(9, 2002);    # get 9th month of 2002
  my @monday    = calendar(9, 2002, 1); # get 9th month of 2002,
                                        # weeks start on Monday

=cut

package Calendar::Simple;

use strict;
use vars qw(@ISA @EXPORT $VERSION);

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw(calendar);
$VERSION = '1.14';

use Time::Local;
use Carp;

eval 'use DateTime';
my $dt = ! $@;
$dt = 0 if $ENV{CAL_SIMPLE_NO_DT};

my @days = qw(31 xx 31 30 31 30 31 31 30 31 30 31);

=head1 DESCRIPTION

A very simple module that exports one function called C<calendar>.

=head2 calendar

This function returns a data structure representing the dates in a month.
The data structure returned is an array of array references. The first
level array represents the weeks in the month. The second level array
contains the actual days. By default, each week starts on a Sunday and
the value in the array is the date of that day. Any days at the beginning
of the first week or the end of the last week that are from the previous or
next month have the value C<undef>.

If the month or year parameters are omitted then the current month or
year are assumed.

A third, optional parameter, start_day, allows you to set the day each
week starts with, with the same values as localtime sets for wday
(namely, 0 for Sunday, 1 for Monday and so on).

=cut

sub calendar {
  my ($mon, $year, $start_day) = @_;

  my @now = (localtime)[4, 5];

  $mon = ($now[0] + 1) unless $mon;
  $year = ($now[1] + 1900) unless $year;
  $start_day = 0 unless defined $start_day;

  croak "Year $year out of range" if $year < 1970 && !$dt;
  croak "Month $mon out of range" if ($mon  < 1 || $mon > 12);
  croak "Start day $start_day out of range"
    if ($start_day < 0 || $start_day > 6);

  my $first;

  if ($dt) {
    $first = DateTime->new(year => $year,
			   month => $mon,
			   day => 1)->day_of_week % 7;
  } else {
    $first = (localtime timelocal 0, 0, 0, 1, $mon -1, $year - 1900)[6];
  }

  $first -= $start_day;
  $first += 7 if ($first < 0);

  my @mon = (1 .. _days($mon, $year));

  my @first_wk = (undef) x 7;
  @first_wk[$first .. 6] = splice @mon, 0, 6 - $first + 1;

  my @month = (\@first_wk);

  while (my @wk = splice @mon, 0, 7) {
    push @month, \@wk;
  }

  $#{$month[-1]} = 6;

  return wantarray ? @month : \@month;
}

sub _days {
  my ($mon, $yr) = @_;

  return $days[$mon - 1] unless $mon == 2;
  return _isleap($yr) ? 29 : 28;
}

sub _isleap {
  return 1 unless $_[0] % 400;
  return   unless $_[0] % 100;
  return 1 unless $_[0] % 4;
  return;
}

1;
__END__

=head2 EXAMPLE

A simple C<cal> replacement would therefore look like this:

  #!/usr/bin/perl -w

  use strict;
  use Calendar::Simple;

  my @months = qw(January February March April May June July August
                  September October November December);

  my $mon = shift || (localtime)[4] + 1;
  my $yr = shift || ((localtime)[5] + 1900);

  my @month = calendar($mon, $yr);

  print "\n$months[$mon -1] $yr\n\n";
  print "Su Mo Tu We Th Fr Sa\n";
  foreach (@month) {
    print map { $_ ? sprintf "%2d ", $_ : '   ' } @$_;
    print "\n";
  }

=head2 Date Range

This module will make use of DateTime.pm if it is installed. By using
DateTime.pm it can use any date that DateTime can represent. If DateTime
is not installed it uses Perl's built-in date handling and therefore
can't deal with dates before 1970 and it will also have problems with dates
after 2038 on a 32-bit machine.

=head2 EXPORT

C<calendar>

=head1 AUTHOR

Dave Cross <dave@mag-sol.com>

=head1 ACKNOWLEDGEMENTS

With thanks to Paul Mison <cpan@husk.org> for the start day patch.

=head1 COPYRIGHT

Copyright (C) 2002-2006, Magnum Solutions Ltd..  All Rights Reserved.

This script is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<perl>, L<localtime>, L<DateTime>

=cut
