# Copyright (c) 2006 by Christoph Lamprecht. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# ch.l.ngre@online.de
package Tk::GraphItems::GraphItem;
use Scalar::Util qw(weaken);

use strict;
use warnings;
use 5.008;
our $VERSION = '0.01';

sub add_dependent{
  my ($self,$dependent) = @_;
  $self->{dependents}{$dependent} = $dependent;
}

sub remove_dependent{
  my ($self,$dependent) = @_;
  delete $self->{dependents}{$dependent};
}

sub dependents{
  my $self = shift;
  return values %{$self->{dependents}};
}

sub _set_layer{
  my ($self,$layer)=@_;
  my $can = $self->get_canvas;
  
  my $l_id = $can->{GraphItem_layers}[$layer];
  $can->lower($_,$l_id)for $self->canvas_items;
}
sub _create_canvas_layers{
  my $self = shift;
  return if ($self->get_canvas)->{GraphItem_layers};
  my $can = $self->get_canvas;
  my @layers;
  $layers[$_]= $can->createLine(10,10,10,10) for (0..2);
  $can->{GraphItem_layers} = \@layers;
}
sub get_canvas{
  my $self = shift;
  $self->{canvas};
  
}

sub _register_instance{
  my $self = shift;
  my $can = $self->get_canvas;
   for ($self->canvas_items){
     my $obj_map = $can->{GraphItemsMap}||={};
     $obj_map->{$_} = $self;
     weaken ($obj_map->{$_});
  }
}

sub DESTROY{ 
  my $self = shift;
  my $can = $self->{canvas};
  my $obj_map = $can->{GraphItemsMap};

  for ($self->canvas_items){
    $can->delete($_);
    delete $obj_map->{$_};
  }
  # destroy dependents...?
  for ($self->dependents){
    eval{$_->destroy_myself}
  }
  my $text = $self->{text}||'a GraphItem';
  print "destroying $text\n";
}


1;
