package Tk::GraphItems::Circle;


=head1 NAME

Tk::GraphItems::TextBox - Display nodes of relation-graphs on a Tk::Canvas

=head1 SYNOPSIS


  require Tk::GraphItems::Circle;
  ...
  my $node = Tk::GraphItems::Circle->new(canvas => $can,
                                         colour => $a_TkColour,
                                         size   => $pixels,
                                         'x'    => 50,
                                         'y'    => 50);
  $node->move(10,0);
  $node->set_coords(50,50);
  $node->text($node->text()."\nanother_line");
  $node->colour('red');






=head1 DESCRIPTION

Tk::GraphItems::Circle provides objects to display nodes of relation-graphs on a Tk::Canvas widget.

=head1 SEE ALSO

Documentation of Tk::GraphItems::Connector.
Examples in Tk/GraphItems/Examples.

=head1 METHODS

B<Tk::GraphItems::Circle> supports the following methods:

=over 4

=item B<new(>canvas => $a_canvas,
             colour => $a_TkColour,
             x      => $x_coord,
             y      => $y_coord,
             size   => $pixels<)>

Return a new Circle instance and display it on the given 'Canvas'. The canvas-items will be destroyed with the Circle-instance when it goes out of scope.

=item B<set_coords(>$x,$yB<)>

Set the (center)coordinates of this node.
If two references are given as argumnents, the referenced Scalar-variables will get tied to the coordinates properties of the node.

=item B<get_coords>

Return the (center)coordinates of this node.

=item B<move(>$d_x,$d_yB<)>

Move the node by ($d_x,$d_y) pixels.

=item B<size(>$sizeB<)>

Resize the node to $size pixels. Returns the current size, if called without an argument.

=item B<colour(>[$a_Tk_colour]B<)>

Sets the Circles colour to $a_Tk_colour, if the argument is given. Returns the current colour, if called without an argument.

=item B<bind_class(>'event',$coderefB<)>

Binds the given event_sequence to $coderef. This binding will exist for all TextBox instances on the Canvas displaying the object, 'bind_class' was called with.The binding will not exist for TextBox-instances, that are displayed on other Canvas-instances.  The TextBox instance,  which is the 'current' one at the time the event is triggered, will be passed to $coderef as an argument.

=item B<was_dragged>

Returns a true value in case a <B1-Motion> occured after the last <B1>. You may want to check this when binding to <B1-Release>, to make sure the action was a 'click' and not a 'drag'.

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
our $VERSION = '0.05';

#use Data::Dumper;
use Carp;
use warnings;
use strict;
use Scalar::Util (qw/looks_like_number/);
require Tk::GraphItems::GraphItem;
require Tk::GraphItems::TiedCoord;
our @ISA = ('Tk::GraphItems::GraphItem','Tk::GraphItems::Node');


sub new{
    my $class = shift;
    if (ref $class) {
	croak "new has to be called on a class-name!";
    }
    if (@_%2) {
	croak "wrong number of args! ";
    }
    my %args = @_;
    my ($can,$x,$y,$size,$colour) = @args{qw/canvas x y size colour/};
    eval {$can->isa('Tk::Canvas');$can->Exists;};
    croak "something is wrong with this 'canvas':<$can> $@" if $@;
    my $text_id;
    my @center = map {ref($_)?$$_:$_} ($x,$y);
    $size ||= 10;
    my @coords = ($center[0] - $size/2,
		  $center[1] - $size/2,
		  $center[0] + $size/2,
		  $center[1] + $size/2);
    my @colour = (-fill => $colour) if ($colour);
    eval{$text_id = $can->createOval(@coords,
				     -tags =>['Circle',
					      'CircleBind'],
				     @colour,
				 );
     };
    croak "could not create Circle at coords <$x>,<$y>: $@" if $@;

    my $self  = {circle_id  => $text_id,
		 dependents => {},
		 canvas     => $can,
		 size       => $size,
	     };
    bless $self , $class;
    $self->_register_instance;
    $self->_create_canvas_layers;
    $self->_set_layer(2); 
    $self->_set_canvas_bindings;
    if (ref $x and ref $y) {
	$self->_tie_coords($x,$y);
    }
    $self;

}  #end new

{
my %iinfo = (-text=>1);		# item information hash

sub _set_canvas_bindings{
  my ($self) = @_;
  my $can = $self->{canvas};
  return if $can->{CircleBindings_done};
  for my $tag (qw/Circle/){
    $can->bind($tag,'<1>' => sub {
		 my($can) = @_;
		 my $e = $can->XEvent;
		 _items_start_drag ($can, $e->x, $e->y, \%iinfo);
	       }
	      );
    $can->bind($tag,'<B1-Motion>' =>sub {
		 _items_drag ($can,
			     $Tk::event->x,
			     $Tk::event->y,
			     \%iinfo);
	       }
	      );
  }
  $can->{CircleBindings_done}= 1;
}
} #end scope of iinfo

sub bind_class{#this should go to GraphItem.pm
  my ($self,$event,$code) = @_;
  my $can = $self->{canvas};
  $self->SUPER::bind_class($event,'CircleBind',$code);
}


sub _items_drag {
    my($can, $x, $y, $iinfo) = @_;
   # $x = $can->canvasx($x);
   # $y = $can->canvasy($y);
    my $id= ($can->find(withtag => 'current'))[0];
    my $self = Tk::GraphItems::GraphItem::_get_inst_by_id($can,$id);
    my ($d_x,$d_y) = ($x-$iinfo->{lastX},$y-$iinfo->{lastY});
    $self->_move($d_x ,$d_y);
    $self->{was_dragged}=1;

    $iinfo->{lastX} = $x;
    $iinfo->{lastY} = $y;

} # end items_drag

sub _items_start_drag {

    my($can, $x, $y, $iinfo) = @_;
    $iinfo->{lastX} = $x;
    $iinfo->{lastY} = $y;
    my $id= ($can->find(withtag => 'current'))[0];
    my $self = Tk::GraphItems::GraphItem::_get_inst_by_id($can,$id);
    $self->{was_dragged}=0;

} # end items_start_drag

sub canvas_items{
    my $self = shift;
    return (@$self{qw/ circle_id /});
}

sub connector_coords{
    my ($self,$dependent) = @_;
    my ($x,$y) = $self->get_coords;
    if (!defined $dependent) {
	return($x,$y);
    }
    my $where = $dependent->{master}{$self};
    my $other = $where eq 'source'? 'target':'source';
    my $c_c = $dependent->get_coords($other); 
    my $c_r= ($c_c->[1]-$y)/(($c_c->[0]-$x)||0.01);
    my $radius = $self->{ size } / 2;

    my $dx = sqrt($radius**2 /(1+$c_r**2));
    $dx = - $dx if ($c_c->[0] > $x);
    my $dy = $dx * $c_r;

    return ( $x-$dx , $y - $dy );

}
sub move{
    my $self = shift;
    looks_like_number($_)||
	croak "method 'move' failed: args <$_[0]>,<$_[1]> have to be numbers!"
	    for (@_[0,1]);
    $self->_move(@_);
}

sub _move{
    my ($self,$d_x,$d_y ) = @_;
    my ($x,$y) = $self->get_coords;
    $self->_set_coords($x+$d_x,$y+$d_y);
}
sub set_coords{
    my $self = shift;
    if (ref $_[0]&& ref$_[1]){
	$self->_tie_coords(@_);
	return;
    }
    looks_like_number($_)||
      croak "method 'set_coords' failed: args <$_[0]>,<$_[1]> have to be numbers!"
	 for(@_[0,1]);
    $self->_set_coords(@_);
}
sub _set_coords{
    my ($self,$x,$y)=@_;
    my ($can,$circle_id,$size) = @$self{qw/canvas circle_id size/};
    my $radius = $size/2;
    $can->coords($circle_id,
		 $x - $radius,
		 $y - $radius,
		 $x + $radius,
		 $y + $radius);

    for ($self->dependents){
	$_->position_changed($self);
    }
}
sub _tie_coords{
    my $self = shift;
    $self ->_untie_coords;
  tie ${$_[0]}, 'Tk::GraphItems::TiedCoord',$self,0 if ref $_[0];
  tie ${$_[1]}, 'Tk::GraphItems::TiedCoord',$self,1 if ref $_[1];
    @$self{qw/tiedx tiedy/}= @_[0,1];
}
sub _untie_coords{
  my $self = shift;
  for (@$self{qw/tiedx tiedy/}){
    untie ${$_} ;#if tied $$_
  }
}

sub colour{
    my $self = shift;
    my $can = $self->get_canvas;
    if (@_){
	eval{$can->itemconfigure($self->{circle_id},-fill=>$_[0]);};
	croak " setting colour to <$_[0]> not possible: $@" if $@;
	return $self;
    }else{
	return $can->itemcget($self->{circle_id},'-fill');
    }
}

sub size{
    my $self = shift;
    if (@_) {
	$self->{size} = $_[0];
	$self->set_coords( $self->get_coords );
    } else {
	return $self->{size};
    }
}
sub get_coords{
    my$self = shift;
    my $can = $self->get_canvas;
    my @circle_co = $can->coords($self->{circle_id});
    my @coords = (( $circle_co[0] + $circle_co[2] )/2 ,
		  ( $circle_co[1] + $circle_co[3] )/2 );
    return wantarray ? @coords:\@coords;
}

sub was_dragged{
    my $self = shift;
    return $self->{was_dragged} ||0;
}





package Tk::GraphItems::Node;


1;

__END__




