package GPSTest::Web::C::My::Pos;
use strict;
use warnings;

sub show {
    my ($class, $c) = @_;
    my $pos_id = $c->req->param('pos_id') // die "missing mandatory parameter 'pos_id'";
    my $pos = $c->db->single(
        'pos' => {
            pos_id => GPSTest::UUID->str2bin($pos_id)
        }
    ) // die "pos not found: $pos_id";
    my $zoom = $c->req->param('zoom') || 19;
    return $c->render( 'my/pos/show.tt',
        { 'pos' => $pos, zoom => $zoom, zzz => [ 1 .. 21 ], } )
      ->fillin_form( {zoom => $zoom} );
}

1;
