use strict;
use warnings;

use Test::More tests => 3*2;

use String::RewritePrefix ();


my $rewriter_num = 0;

sub test_rewrite
{
  my ($prefixes, $in, $expected) = @_;

  my $rewriter_name = "rewriter_".(++$rewriter_num);
  String::RewritePrefix->import(
    rewrite => {
      -as => $rewriter_name,
      prefixes => $prefixes,
    }
  );
  my $rewriter = __PACKAGE__->can($rewriter_name);
  is_deeply([ $rewriter->(@$in) ], $expected, $rewriter_name);
  is_deeply([ String::RewritePrefix->rewrite($prefixes, @$in) ], $expected);
}


test_rewrite({
    '-' => 'Tet::',
    '@' => 'KaTet::',
    '+' => sub { $_[0] . '::Foo::' },
    '!' => sub { return undef },
  },
  [ qw(    -Corporation       @Roller Plinko     -@Oops          +Bar !None)],
  [ qw(Tet::Corporation KaTet::Roller Plinko Tet::@Oops Bar::Foo::Bar  None) ],
);

test_rewrite(
  { '' => 'MyApp::', '+' => '' },
  [ qw(       Plugin        Mixin        Addon +Corporate::Thinger) ],
  [ qw(MyApp::Plugin MyApp::Mixin MyApp::Addon  Corporate::Thinger) ],
);


test_rewrite({
    '-' => 'minus ',
    '+' => 'plus ',
    ''  => 'plus ',
  },
  [ qw(  +10         10         -10         0) ],
  [ 'plus 10', 'plus 10', 'minus 10', 'plus 0' ],
);

