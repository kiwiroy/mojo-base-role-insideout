## no critic (MultiplePackages, RequireFilenameMatchesPackage)
use Mojo::Base -strict;

package Test::File::Parser;
use Mojo::Base -base;

has fh => undef;

sub next_record {
  my $self = shift;
  local $/ = $self->separator;
  my $fh = $self->fh;
  return undef if eof($fh);
  my $result = <$fh>;
  chomp($result);
  return $result;
}

sub reset {
  my ($self, $force) = (shift, shift);
  seek $self->fh, 0, 0 if $force or eof($self->fh);
  return $self;
}

has separator => "//\n";

package Test::File;

use Mojo::Base qw{Mojo::File};
use Role::Tiny::With;
with 'Mojo::Base::Role::InsideOut';

__PACKAGE__->attr(parser => sub { Test::File::Parser->new(fh => $_[0]->open) });

sub array {
  my ($self, @result) = (shift);
  $self->parser->reset($_[0]) if $_[0];
  while (my $rec = $self->next_record) {
    push @result, $rec;
  }
  return \@result;
}

sub hash {
  my ($self, %result) = (shift);
  $self->parser->reset($_[0]) if $_[0];
  while (my $rec = $self->next_record) {
    $result{lc substr($rec, 0, 1)} = $rec;
  }
  return \%result;
}

sub next_record {
  shift->parser->next_record;
}

package main;
use Test::More;

my $io = new_ok('Test::File', ['t/data/test.fmt']);

isa_ok $io->parser, 'Test::File::Parser', 'type check';

is $io->next_record, <<'EOF', 'match';
Alpha
a
and
another
EOF

is_deeply $io->array, [
  "beta\nbest\nbegin\n",
  "child\nchildren\n"], 'array of remaining records';

is_deeply $io->array(1), [
  "Alpha\na\nand\nanother\n",
  "beta\nbest\nbegin\n",
  "child\nchildren\n"], 'array of all records';

is_deeply $io->hash(1), {
  a => "Alpha\na\nand\nanother\n",
  b => "beta\nbest\nbegin\n",
  c => "child\nchildren\n"
}, 'hash';


done_testing;


=pod

=head1 NAME

mojo-file.t - basic example

=head1 DESCRIPTION

Basic example where it is nice to have a parser object attached to the file
object

=head1 SYNOPSIS

  my $path = "t/data/some/file";

Now

  my $file = Test::File->new($path);
  while (my $rec = $file->next_record) {
    # ...
  }

Compared to

  my $file = Mojo::File->new($path);
  my $parser = TypeParser->new(path => "$file");
  while (my $rec = $parser->next_record) {
    # ...
  }


=cut
