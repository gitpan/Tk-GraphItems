# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Tk-GraphItems-Tie.t'


use Test::More tests => 11;
BEGIN {use_ok ('Tk');}
require_ok ('Tk::GraphItems');


use strict;
use warnings;
my $mw = tkinit();
my $s_can = $mw -> Scrolled('Canvas',
			    -scrollregion=>[0,0,200,700],
			)->pack(-fill  =>'both',
				-expand=>1);
my $can = $s_can->Subwidget('scrolled');

my @obj;
my $connector;
my @coords = (20,20,50,50);
sub create_circle{ 
    $obj[0] = Tk::GraphItems->Circle(canvas => $can,
                                     size   => 20,
                                     colour => 'green',
                                     'x'    => \$coords[0],
                                     'y'    => \$coords[1]);
}
sub create_circle_direct{ 
    $obj[0] = Tk::GraphItems::Circle->new(canvas => $can,
                                          size   => 20,
                                          colour => 'green',
                                          'x'    => \$coords[0],
                                          'y'    => \$coords[1]);
} 
sub create_textbox{
    $obj[1] = Tk::GraphItems->TextBox(canvas => $can,
		 		        text => 't',
				      'x'    => \$coords[2],
				      'y'    => \$coords[3]);
} 
sub create_textbox_direct{
    $obj[1] = Tk::GraphItems::TextBox->new(canvas => $can,
					   text => 't',
					   'x'    => \$coords[2],
					   'y'    => \$coords[3]);
}
sub create_connector_direct{
    Tk::GraphItems::Connector->new(
				   source=>$obj[0],
				   target=>$obj[1],
			       );
}
sub create_connector{
    Tk::GraphItems->Connector(
				   source=>$obj[1],
				   target=>$obj[0],
			       );
}


$mw->update;
eval{create_circle()};
ok( !$@,"instantiation circle $@");
isa_ok($obj[0], 'Tk::GraphItems::Circle');
$mw->update;
eval{create_circle_direct()};
ok( !$@,"instantiation circle direct $@");
isa_ok($obj[0], 'Tk::GraphItems::Circle');
$mw->update;
eval{create_textbox()};
ok( !$@,"instantiation textbox $@");
isa_ok($obj[1],'Tk::GraphItems::TextBox');
$mw->update;
eval{create_textbox_direct()};
ok( !$@,"instantiation textbox direct $@");
isa_ok($obj[1],'Tk::GraphItems::TextBox');
$mw->update;
eval{create_connector()};
ok( !$@,"instantiation connector $@");
$mw->update;
__END__
