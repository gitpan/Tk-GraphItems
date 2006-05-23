
package Tk::GraphItems::Connector;

=head1 NAME

Tk::GraphItems::Connector - Display edges of relation-graphs on a Tk::Canvas

=head1 SYNOPSIS


  require Tk::GraphItems::TextBox;
  require Tk::GraphItems::Connector;


  my $conn = Tk::GraphItems::Connector->new(
					    source=>$a_TextBox,
					    target=>$another_TextBox],
					    );
  $conn->colour('red');
  $conn->arrow('both');
  $conn->width(2);
  $conn->detach;
  $conn = undef;




=head1 DESCRIPTION

Tk::GraphItems::Connector provides objects to display edges of relation-graphs on a Tk::Canvas widget.

=head1 SEE ALSO

Documentation of Tk::GraphItems::TextBox .
Examples in Tk/GraphItems/Examples

=head1 METHODS

B<Tk::GraphItems::Connector> supports the following methods:

=over 4

=item B<new(>source      => $a_GraphItems-Node,
             target      => $a_GraphItems-NodeB,
             colour      => $a_TkColour,
             width       => $width_pixels,
             arrow       => $where,
             autodestroy => $bool<)>


Create a new Connector instance and  display it on the Canvas of 'source' and 'target'.
If 'autodestroy' is set to a true value, the Connector will get destroyed when its reference goes out of scope. This is recommended for easy use with Graph.pm or other models which allow to store objects for their edges. See gi-graph.pl for an example. The default for 'autodestroy' is 0. That means the Connector will stay 'alive' until either one of its source/target nodes gets destroyed or Connector->detach is called and references to Connector are deleted.

=item B<colour(>[$a_Tk_colour]B<)>

Sets the colour to $a_Tk_colour, if the argument is given. Returns the current colour, if called without an argument.

=item B<arrow(>'source'|'target'|'none'|'both'B<)>

Sets the style of the Connectors line-endings. Defaults to 'target'.

=item B<width(>$line_widthB<)>

Sets Connectors linewidth in pixels. Defaults to 1.

=item B<detach>

Detach the Connector instance from its source and target so it can be DESTROYED. - It will however stay 'alive' as long as you hold any references to it. If you do not hold a reference to 'Connector' (you don't have to, unless you want to change it's properties...), it will be DESTROYED when either of its 'source'- or 'target'-nodes is destroyed.


=back

=head1 AUTHOR

Christoph Lamprecht, ch.l.ngre@online.de

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Christoph Lamprecht

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.




=cut
use 5.008001;
our $VERSION = '0.04';

use Scalar::Util qw(weaken);
#use Data::Dumper;
require UNIVERSAL;
use warnings;
use strict;
use Carp;
require Tk::GraphItems::GraphItem;
our @ISA = ('Tk::GraphItems::GraphItem');
my %arrow=(source=>'first',
	   first =>'first',
	   target=>'last',
	   last  =>'last',
	   1     =>'last',
	   both  =>'both',
	   all   =>'both',
	   none  =>'none',
	   0     =>'none');
sub new{
  my $class= shift;
  if (@_%2) {
    croak "wrong number of args! ";
  }
  my %args = @_;
  my ($source,$target,$colour,$width,$arrow_type,$autodestroy) = 
    @args{qw/source target colour width arrow autodestroy/};
  $arrow_type ||= 'target';
  for (qw/source target/){
    my $node = $args{$_};
    eval{$node->isa('Tk::GraphItems::Node')}
      ||croak " argument '$_': <$node> is no valid GraphItem::Node! $@ ";};
  my $can =$source->get_canvas ;
  if ($can ne $target->get_canvas){
    croak "Can't connect Nodes on different Canvases!";
  }

  my @coords ;
  for ($source, $target){push @coords, $_->connector_coords()};

  my $id = eval{$can->createLine(@coords,
				 -fill      => $colour||'black',
				 -width     => $width||1,
				 -tags      =>['GraphEdge',
					       'GraphEdgeLine'],
				 -arrow     =>$arrow{$arrow_type}||'last',
				 -arrowshape=>[7,9,3],
				)};
  if ($@){
    croak "Connector creation failed: $@";
  }


  my $self  = {line_id     => $id,
	       dependents  => {},
	       canvas      => $can,
	       source      => $source,
	       target      => $target,
	       autodestroy => $autodestroy ||= 0};
  bless $self , $class;
  $self->_register_instance;
  $self->_set_layer(0);
  for (qw/source target/){
      if ($autodestroy){
	  $self->{$_}->add_dependent_weak($self);
      }else{
	  $self->{$_}->add_dependent($self);
      }
      $self->set_master($_,$self->{$_});
      weaken($self->{$_});}
  for (qw/source target/){
    $self->set_coords($_,$self->{$_}->connector_coords($self))
  };
  $self;
}


sub canvas_items{
  my $self = shift;
  return ($self->{line_id});
}

sub destroy_myself{
  my $self = shift;
  $self->detach;
}
sub detach{
  my $self = shift;
  for (@$self{qw/source target/}){
    if (UNIVERSAL::can($_ , 'remove_dependent')){
     # print"d_f_m $_\n";
      $_->remove_dependent($self);
    }
  }
}
sub _move{
  my ($self,$where,$d_x,$d_y) = @_;
  if ($where !~ /source|target/){
    return;
  }
  $self->set_coords($self->{$where.'_x'}+$d_x,$self->{$where.'_y'}+$d_y);
}
sub get_coords{
  my ($self,$where) = @_;
  my ($can,$id) = @$self{qw/canvas line_id/};
  my @coords = $can->coords($id);
  if (($where||'') eq 'source'){splice (@coords,-2)}
  if (($where||'') eq 'target'){splice (@coords,0,2)}
  return wantarray ? @coords : \@coords;
}

sub set_coords{
  my ($self,$where,$x,$y)=@_;
  my ($can,$l_id) = @$self{qw/canvas line_id/};
  if ($where !~ /source|target/){
    return;
  }
  my @coords = $can->coords($l_id);
  if ($where eq 'source'){
    @coords[0,1] = ($x,$y);
  }
  else{
    @coords[2,3] = ($x,$y);
  }
  $can->coords($l_id,@coords);
}

sub set_master{
  my ($self,$where,$master) = @_;
  return unless $where =~ /source|target/;
  $self->{master}{$master}=$where;
}

sub colour{
  my $self = shift;
  my $can = $self->get_canvas;
  if (@_){
    eval{$can->itemconfigure($self->{line_id},-fill=>$_[0]);};
      croak " setting colour to <$_[0]> not possible: $@" if $@;
    return $self;
  }else{
    return $can->itemcget($self->{line_id},'-fill');
  }
}
sub arrow{
  my ($self,$arr_type) = @_;
  my $can = $self->get_canvas;
  $can->itemconfigure($self->{line_id},-arrow=>$arrow{$arr_type}||'last');
  $self;
}
sub width{
  my $self = shift;
  my $can = $self->get_canvas;
  if (@_){
    eval{$can->itemconfigure($self->{line_id},-width=>$_[0]);};
      croak " setting width to <$_[0]> not possible: $@" if $@;
    return $self;
  }else{
    return $can->itemcget($self->{line_id},'-width');
  }
}
sub position_changed{
  my ($self,$master) = @_;
  my  $first = $self->{master}{$master};
  my  $second= $first eq 'source'?'target':'source';
  for my $where ($first,$second){
    $master = $self->{$where};
    my ($x,$y) = $master->connector_coords($self);
    $self->set_coords($where,$x,$y);
  }
}



sub _get_inst_by_id{
  my ($can,$id) = @_;
  my $obj_map = $can->{GraphItemsMap};
  return $obj_map->{$id}||undef;
}

sub DESTROY {
    my $self = shift;
    $self -> detach;
    $self -> SUPER::DESTROY;
}


1;




__END__
