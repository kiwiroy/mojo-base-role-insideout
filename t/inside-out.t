use Mojo::Base -strict;

package Test::InsideOut;

use Mojo::Base -base;
use Role::Tiny::With;

with 'Mojo::Base::Role::InsideOut';

__PACKAGE__->attr(foo => sub { return 'bar' });

__PACKAGE__->attr(bar => 'foobar');

package Test::Again;
use Mojo::Base -base;
use Role::Tiny::With;

with 'Mojo::Base::Role::InsideOut';

__PACKAGE__->attr(rate => 1.5);

package main;

use Test::More;

my $io = new_ok('Test::InsideOut');

is $io->foo, 'bar', 'foo == bar';
is $io->foo('foo'), $io, 'chaining';
is $io->foo, 'foo', 'foo';

is $io->bar, 'foobar', 'bar == foobar';
is $io->bar('bar'), $io, 'chaining';
is $io->bar, 'bar', 'set';

is $io->_count_objects->{'Mojo::Base::Role::InsideOut'}, 1, 'one object';

my $again = new_ok('Test::Again');
is $again->rate, 1.5, 'rate default';
is $again->rate(2.0)->rate, 2.0, 'set rate';

is $again->_count_objects->{'Mojo::Base::Role::InsideOut'}, 2, 'two objects';

undef $io;
is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  1, 'one object';

undef $again;
is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  0, 'no object';

my @iolist;
for (1 .. 100) {
  push @iolist, new_ok('Test::InsideOut')->foo('foo')->bar('bar');
  push @iolist, new_ok('Test::InsideOut');
  is $iolist[-1]->foo, 'bar', 'default';
}

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  @iolist, 'more objects';

@iolist = ();
is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  @iolist, 'no objects';

for (1 .. 100) {
  push @iolist, new_ok('Test::InsideOut');
}

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  0, 'none have property values objects';

is $_->foo, 'bar', 'default' for (@iolist);

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  @iolist, 'no objects';

$io = new_ok('Test::InsideOut');

is $io->foo, 'bar', 'foo == bar';
is $io->foo('foo'), $io, 'chaining';
is $io->foo, 'foo', 'foo';

is $io->bar, 'foobar', 'bar == foobar';
is $io->bar('bar'), $io, 'chaining';
is $io->bar, 'bar', 'set';

@iolist = ();

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  1, 'one object';



done_testing;
