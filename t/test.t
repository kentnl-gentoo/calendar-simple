# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 34;
use_ok('Calendar::Simple');

my @month = calendar(9, 2002);

ok(@month == 5);
ok(@{$month[0]} == 7);
ok($month[0][0] == 1);
ok(not defined $month[-1][-1]);
ok($#{$month[-1]} == 6);

@month = calendar(2, 2009);
ok(@month == 4);
ok($month[0][0] == 1);
ok($month[3][6] == 28);
ok(defined $month[-1][-1]);
ok($#{$month[-1]} == 6);

@month = calendar(1, 2002);
ok(not defined $month[0][0]);
ok($month[0][2] == 1);
ok($month[4][4] == 31);
ok(not defined $month[4][6]);
ok(not defined $month[-1][-1]);
ok($#{$month[-1]} == 6);

@month = calendar(1, 2002, 1);
ok(not defined $month[0][0]);
ok($month[0][1] == 1);
ok($month[4][3] == 31);
ok(not defined $month[4][4]);
ok(not defined $month[-1][-1]);
ok($#{$month[-1]} == 6);

@month = calendar(2, 2004, 3);
ok(@month);

@month = calendar();
ok(@month);

eval { @month = calendar(-1) };
ok($@);

eval { @month = calendar(13) };
ok($@);

eval { @month = calendar(1, 2000, -1) };
ok($@);

eval { @month = calendar(1, 2000, 7) };
ok($@);

@month = calendar(2, 2000);
ok(@month);

@month = calendar(2, 2004);
ok(@month);

my $month = calendar();
ok(ref $month eq 'ARRAY');

SKIP: {
  eval { require DateTime };
  skip "DateTime not installed", 2, if $@ || $ENV{CAL_SIMPLE_NO_DT};
  @month = calendar(1,1500);
  ok(@month);

  @month = calendar(2, 2100);
  ok(@month);
}
