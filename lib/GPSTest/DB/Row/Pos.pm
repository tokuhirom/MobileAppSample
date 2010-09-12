package GPSTest::DB::Row::Pos;
use strict;
use warnings;
use parent qw/DBIx::Skinny::Row/;
use Geo::Hash::XS;
use GPSTest::UUID;

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

sub areaname {
    my ($self) = @_;
    return unless $self->areacode;
    Geo::Coordinates::Converter::iArea->get_name( sprintf '%05d',
        $self->areacode );
}

sub pos_id_str {
    my ($self, ) = @_;
    GPSTest::UUID->bin2str($self->pos_id);
}

1;
