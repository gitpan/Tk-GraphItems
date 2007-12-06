# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Tk-GraphItems-Tie.t'

use  Test::More;

eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
plan tests => 3;
my $private = { also_private => [qr/^(canvas_items|connector_coords)$/] };

for (qw/Tk::GraphItems::TextBox Tk::GraphItems::Circle/){
    pod_coverage_ok($_, $private);
}

$private = {also_private => [qr/^( canvas_items
                                 | destroy_myself
                                 | get_coords
                                 | set_coords
                                 | position_changed
                                 | set_master
                                 )$/x ]
        };

pod_coverage_ok('Tk::GraphItems::Connector', $private);

__END__
