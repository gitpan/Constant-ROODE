# Package for defining constants of various types

use strict;
$Constant::VERSION = 0.04;    # Also change in the documentation!


# ----------------
# Constant scalars
# ----------------
package Constant::Scalar;
use Carp;

sub TIESCALAR
	{
	my $class = shift;
	unless (@_)
		{
		croak "No value specified for constant scalar";
		}
	unless (@_ == 1)
		{
		croak "Too many values specified for constant scalar";
		}
	my $value = shift;

	return bless \$value, $class;
	}

sub FETCH
	{
	my $self = shift;
	return $$self;
	}

sub STORE
	{
	croak "Attempt to modify a read-only scalar";
	}

# ----------------
# Constant arrays
# ----------------
package Constant::Array;
use Carp;

sub TIEARRAY
	{
	my $class = shift;
	my @self = @_;

	return bless \@self, $class;
	}

sub FETCH
	{
	my $self  = shift;
	my $index = shift;
	return $self->[$index];
	}

sub STORE
	{
	croak "Attempt to modify a read-only array";
	}

sub FETCHSIZE
	{
	my $self = shift;
	return scalar @$self;
	}

sub STORESIZE
	{
	croak "Attempt to modify a read-only array";
	}

sub EXTEND
	{
	croak "Attempt to modify a read-only array";
	}

sub EXISTS
	{
	my $self  = shift;
	my $index = shift;
	return exists $self->[$index];
	}

sub CLEAR
	{
	croak "Attempt to modify a read-only array";
	}

sub PUSH
	{
	croak "Attempt to modify a read-only array";
	}

sub UNSHIFT
	{
	croak "Attempt to modify a read-only array";
	}

sub POP
	{
	croak "Attempt to modify a read-only array";
	}

sub SHIFT
	{
	croak "Attempt to modify a read-only array";
	}

sub SPLICE
	{
	croak "Attempt to modify a read-only array";
	}

# ----------------
# Constant hashes
# ----------------
package Constant::Hash;
use Carp;

sub TIEHASH
	{
	my $class = shift;

	# must have an even number of values
	unless (@_ %2 == 0)
		{
		croak "May not store an odd number of values in a hash";
		}
	my %self = @_;
	return bless \%self, $class;
	}

sub FETCH
	{
	my $self = shift;
	my $key  = shift;

	return $self->{$key};
	}

sub STORE
	{
	croak "Attempt to modify a read-only hash";
	}

sub DELETE
	{
	croak "Attempt to modify a read-only hash";
	}

sub CLEAR
	{
	croak "Attempt to modify a read-only hash";
	}

sub EXISTS
	{
	my $self = shift;
	my $key  = shift;
	return exists $self->{$key};
	}

sub FIRSTKEY
	{
	my $self = shift;
	my $dummy = keys %$self;
	return scalar each %$self;
	}

sub NEXTKEY
	{
	my $self = shift;
	return scalar each %$self;
	}


package Constant;
use Carp;
use Exporter;
use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS/;
push @ISA, 'Exporter';
push @EXPORT_OK, qw/Scalar Array Hash/;

sub Scalar ($$)
	{
	return tie $_[0], 'Constant::Scalar', $_[1];
	}

sub Array (\@;@)
	{
	my $aref = shift;
	return tie @$aref, 'Constant::Array', @_;
	}

sub Hash (\%;%)
	{
	my $href = shift;

	# must have an even number of values
	unless (@_ %2 == 0)
		{
		croak "May not store an odd number of values in a hash";
		}

	return tie %$href, 'Constant::Hash', @_;
	}

1;
__END__

=head1 NAME

Constant - Facility for creating read-only scalars, arrays, hashes.

=head1 VERSION

This documentation describes version 0.04 of Constant.pm, Mar 7, 2002.

=head1 SYNOPSIS

 use Constant;

 # Constant scalar
 Constant::Scalar     $sca => $initial_value;
 Constant::Scalar  my $sca => $initial_value;

 # Constant array
 Constant::Array      @arr => @values;
 Constant::Array   my @arr => @values;

 # Constant hash
 Constant::Hash       %has => (key => value, key => value, ...);
 Constant::Hash    my %has => (key => value, key => value, ...);

 # You can use the constant variables like any regular variables:
 print $sca;
 $something = $sca + $arr[2];
 next if $has{$some_key};

 # But if you try to modify a value, your program will die:
 $sca = 7;            # "Attempt to modify read-only scalar"
 push @arr, 'seven';  # "Attempt to modify read-only array"
 delete $has{key};    # "Attempt to modify read-only hash"

=head1 DESCRIPTION

This is a facility for creating non-modifiable variables.
This is useful for configuration files, headers, etc.


=head1 COMPARISON WITH "use constant" OR TYPEGLOB CONSTANTS

=over 1

=item *

Perl provides a facility for creating constant scalars, via the "use
constant" pragma.  This built-in pragma works only with Perl 5.5 or
later, creates only scalars and lists, and creates variables that have
no leading $ character, and which cannot be interpolated into strings.
Also, it works only at compile time.

=item *

Another popular way to create constant scalars is to modify the symbol
table entry for the variable by using a typeglob:

 *a = \"value";

This works fine, but it only works for global variables ("my"
variables have no symbol table entry).  Also, the following similar
constructs do B<not> work:

 *a = [1, 2, 3];      # Does NOT create a constant array
 *a = { a => 'A'};    # Does NOT create a constant hash

=item *

Constant.pm, on the other hand, will work with global variables and
with lexical ("my") variables.  It will create scalars, arrays, or
hashes, all of which look and work like normal, non-constant Perl
variables.  And Constant.pm works with Perl version 5.004 or greater.

However, Constant.pm does impose a performance penalty.  This is
probably not an issue for most configuration variables.  If this is a
concern, however, you should use typeglob constants for scalar
constants.

=back 1

=head1 EXAMPLES

 # SCALARS: 

 # A plain old constant value
 Constant::Scalar $a => "A string value";

 # The value need not be a compile-time constant:
 Constant::Scalar $a => $computed_value;


 # ARRAYS:

 # A constant array:
 Constant::Array @a => (1, 2, 3, 4);

 # The parentheses are optional:
 Constant::Array @a => 1, 2, 3, 4;

 # You can use Perl's built-in array quoting syntax:
 Constant::Array @a => qw/1 2 3 4/;

 # You can initialize a constant array from a variable one:
 Constant::Array @a => @computed_values;

 # A constant array can be empty, too:
 Constant::Array @a => ();
 Constant::Array @a;        # equivalent


 # HASHES

 # Typical usage:
 Constant::Hash %a => (key1 => 'value1', key2 => 'value2');
 # Note: those are parentheses up there, not curly braces.

 # A constant hash can be initialized from a variable one:
 Constant::Hash %a => %computed_values;

 # A constant hash can be empty:
 Constant::Hash %a => ();
 Constant::Hash %a;        # equivalent

 # If you pass an odd number of values, the program will die:
 Constant::Hash %a => (key1 => 'value1', key2);
     --> dies with "May not store an odd number of values in a hash"

=head1 EXPORTS

By default, this module exports no symbols into the calling program's
namespace.  The following symbols are available for import into your
program, if you like:

 Scalar
 Array
 Hash

=head1 REQUIREMENTS

 Carp.pm (included with Perl)

=head1 AUTHOR / COPYRIGHT

Eric J. Roode, eric@myxa.com

Copyright (c) 2001-2002 by Eric J. Roode. All Rights Reserved.  This module
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

If you have suggestions for improvement, please drop me a line.  If
you make improvements to this software, I ask that you please send me
a copy of your changes. Thanks.


=cut
