# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use Constant;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

eval
	{
	Constant::Scalar $a => 1;
	$b = $a;
	$a = $b;
	};
ok($@, qr/Attempt to modify a read-only scalar/);

eval
	{
	Constant::Array @a => (1, 2, 3, 4);
	$b = $a[0];
	$b = scalar @a;
	$b = shift @a;
	};
ok($@, qr/Attempt to modify a read-only array/);

eval
	{
	Constant::Hash %a => qw/a A b B c C/;
	$b = $a{a};
	$b = $a{A};
	$a{b} = 'x';
	};
ok($@, qr/Attempt to modify a read-only hash/);

