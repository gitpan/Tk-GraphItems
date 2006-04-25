#!/usr/bin/perl

=head1 DESCRIPTION

'topo.pl' is an example for the usage of Tk::GraphItems with 'Graph' and 'Graph::Layout::Aesthetic'. It creates a graph of 10 nodes and displays it on a 'Canvas'. It's possible to arrange the nodes manually (simply dragging them) . Enter configuration parameters into the entries and start the layout process. If you want to rearrange nodes, press stop first and continue (restart) afterwards.

=cut

use strict;
use warnings;
use Tk;
use Data::Dumper;
require Tk::GraphItems::TextBox;
require Tk::GraphItems::Connector;
use Graph;
use Graph::Layout::Aesthetic::Topology;
use Graph::Layout::Aesthetic;

my $mw = tkinit();
my $s_can = $mw -> Scrolled('Canvas',
			    -scrollregion=>[-400,-400,400,400],
			   )->pack(
				   -fill  =>'both',
				   -expand=>1);
my $can = $s_can->Subwidget('scrolled');


my $repeat;
my ($temp,$centrip,$rep,$min_len)=(20,1,10000,0.01);

my $f1 = $mw->Frame()->pack;
my @frames= map {$f1->Frame()->pack(-side=>'left');} (0..2);
$frames[0]->Label(-text=>$_)->pack for ('temperature',
					'centripetal',
					'node_repulsion',
					'min_edge_length');

$frames[1]->Entry(-textvariable=>$_)->pack for (\$temp,
						\$centrip,
						\$rep,
						\$min_len);

{#scope of $g, $aglo
my $g = create_graph($can);
my $aglo;

$frames[2]->Button(-text=>'start',
		   -width=>20,
		   -command=>sub{ 
		     $aglo = convert($g);
		     set_aglo_coords($aglo,$g);
		     if ($repeat){$repeat ->cancel}
		     $repeat = $mw->repeat(100,sub{iterate($aglo,$g)})
		   }
	   )->pack;
$frames[2]->Button(-text=>'continue',
		   -width=>20,
		   -command=>sub{
		     set_aglo_coords($aglo,$g);
		     if ($repeat){$repeat ->cancel}
		     $repeat = $mw->repeat(100,sub{iterate($aglo,$g)})
		   }
	   )->pack;
$frames[2]->Button(-text=>'stop',
	    -width=>20,
	    -command=>sub{ if ($repeat){$repeat ->cancel;
					undef $repeat;
				      }
			 }
	   )->pack;
}#end scope of $g, $aglo
MainLoop; 


sub iterate{
  my ($aglo,$g) = @_;
  $aglo->_gloss(0);
  $aglo->coordinates_to_graph( $g,
			       pos_attribute => ["x_end", "y_end"]);
}
sub convert{
  my $topo = Graph::Layout::Aesthetic::Topology->from_graph($_[0]);
  my $aglo = Graph::Layout::Aesthetic->new($topo);
  $aglo->add_force(node_repulsion  => $rep);
  $aglo->add_force(min_edge_length => $min_len);
  $aglo->add_force("Centripetal", => $centrip);
  $aglo->init_gloss($temp,0.0001,1000,0);
  return $aglo;
}
sub set_aglo_coords{
  my ($aglo,$graph) = @_;
  for my $v($graph->vertices){
    my $id = $graph->get_vertex_attribute($v,'layout_id');
    $aglo->coordinates($id,$v->get_coords);
  }
}
sub create_graph{
  my $can = shift;
  my @vert;
  my $g = Graph->new(refvertexed=>1,);
  for (0..4){
    push @vert,new_vertex($g,$can,"node_$_");
  }

  $g->add_path(@vert);
  $g->add_edge($vert[0],$vert[-1]);
  #some leaf- nodes:
  for (0..4){
    my $l =  new_vertex($g,$can,"leaf:\nnode_$_");
    $g->add_edge ($vert[$_],$l);
  }

  for ($g->edges){
    Tk::GraphItems::Connector->new(source=>$_->[0],
				   target=>$_->[1]);
  }
$g;
}
sub new_vertex{
  my ($g,$can,$text) = @_;
  my $v = Tk::GraphItems::TextBox->new(canvas=>$can,
				       text=>$text,
				       'x' =>0,
				       'y' =>0
				      );
  $g->add_vertex($v);
  $g->set_vertex_attribute($v,$_,0)for qw/x_end y_end/;

# yes, I know! the following line is a dirty trick and it should 
# *never* be done that way!
  $v->set_coords(\$g->[2][4]{$v}[2]{x_end},\$g->[2][4]{$v}[2]{y_end});
  $g->set_vertex_attribute($v,$_,(int rand 200)-100)for qw/x_end y_end/;
  return $v;
}
