# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Tk-GraphItems.t'


use Test::More tests => 9;
BEGIN {use_ok ('Tk')};
require_ok ('Tk::GraphItems::TextBox');
require_ok ('Tk::GraphItems::Connector');


use strict;
use warnings;
my $mw = tkinit();
my $s_can = $mw -> Scrolled('Canvas',
			    -scrollregion=>[0,0,200,700],
			   )->pack(-fill  =>'both',
				   -expand=>1);
my $can = $s_can->Subwidget('scrolled');

my @obj;
my $conn;
sub create{ 
  my ($x,$y) = (50,20);
  for my $n(1..5){$obj[$n] = Tk::GraphItems::TextBox->new(canvas=>$can,
							  text=>"object $n",
							  'x'=>$x=($x%200)+40,
							  'y'=>$y+=100);
		}
  for my $n(1..5){Tk::GraphItems::Connector->new(
						 source=>$obj[$n],
						 target=>$obj[($n%5)+1],
						 colour =>'red',
						 
						);
		}


$conn= Tk::GraphItems::Connector->new(
				source=>$obj[5],
				target=>$obj[3],
				
					   );


}
sub move{
  for (1..2){$obj[$_]->move(20,0)}
}
sub und{
  my $item = pop(@obj);
  undef ($item);
}
sub set_c{
  $obj[1]->set_coords(40,20);
}
sub set_text{
  for my $n(2..4){
    my $node = $obj[$n];
    $node->text($node->text . "\nand more");
  }
}
sub set_colour{
  for my $n(1..3){
    my $node = $obj[$n];
    $node->colour($node->colour eq 'red'? 'white':'red');
  }
  $conn->arrow('both');
}

$mw->update;
eval{create()};
ok( !$@,"instantiation $@");
$mw->update;

eval{move()};
ok( !$@,"method move $@");
$mw->update;


eval{set_c()};
ok( !$@,"method set_coords $@");
$mw->update;

eval{set_colour()};
ok( !$@,"method set_colour $@");
$mw->update;

eval{set_text()};
ok( !$@,"set_text $@");
$mw->update;

eval{und()};
ok( !$@,"undef last $@");
$mw->update;

__END__
