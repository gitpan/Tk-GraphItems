# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as
# `perl Tk-GraphItems-Circle.t'.


use Test::More tests => 9;
BEGIN {use_ok ('Tk')};
require_ok ('Tk::GraphItems::Circle');
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
    for my $n (0,1) {
	$obj[$n] = Tk::GraphItems::Circle->new(canvas => $can,
					       size   => 20,
					       colour => 'green',
					       'x'    => 50,
					       'y'    => 50);
    }

    $conn= Tk::GraphItems::Connector->new(
					  source=>$obj[0],
					  target=>$obj[1],
				      );


}
sub move{
	$obj[1]->move(20,0);
}

sub und{
    my $item = pop(@obj);
    undef ($item);
}

sub set_c{
    $obj[1]->set_coords(40,20);
}

sub set_size{
    $obj[0]->size(30);
    die unless $obj[0]->size == 30;
}

sub set_colour{
    $obj[0]->colour('red');
    die unless $obj[0]->colour eq 'red';
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

eval{set_size()};
ok( !$@,"set_size $@");
$mw->update;

eval{und()};
ok( !$@,"undef last $@");
$mw->update;
__END__
