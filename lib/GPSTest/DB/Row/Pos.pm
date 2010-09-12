package GPSTest::DB::Row::Pos;
use strict;
use warnings;
use parent qw/DBIx::Skinny::Row/;
use Geo::Hash::XS;

my $gh = Geo::Hash::XS->new();

sub decode_pos {
    my ($self) = @_;
    $self->{decode_pos} //= do {
        my ($lat, $lng) = $gh->decode($self->geohash);
        Geo::Coordinates::Converter->new(
            lat   => $lat,
            lng   => $lng,
            datum => 'wgs84',
        );
    };
}

1;
