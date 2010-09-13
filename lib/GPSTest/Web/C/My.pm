package GPSTest::Web::C::My;
use strict;
use warnings;
use HTML::MobileJp::Plugin::GPS qw/gps_a/;
use Text::Xslate qw/mark_raw/;
use GPSTest::M::Ticket;
use Geo::Hash::XS;
use GIS::Distance::Lite;
use Geo::Coordinates::Converter::iArea;
use URI::WithBase;

sub index {
    my ($class, $c) = @_;
    my $agent = $c->req->mobile_agent;
    my $carrier = $agent->carrier;
    my $ticket = GPSTest::M::Ticket->create();
    my $sid = $c->session->session_id();
    my $callback = URI::WithBase->new($c->uri_for("/my/checkin/$sid/$ticket"), $c->req->base);
    my $is_gps = do {
        if ($agent->is_docomo) {
            0;
        } else {
            $c->req->mobile_agent->gps_compliant ? 1 : 0
        }
    };
    my $tag = gps_a(
        carrier      => $carrier,
        is_gps       => $is_gps,
        callback_url => $callback->abs->as_string(),
    );
    $c->render('my/index.tt', {
        a_tag => mark_raw($tag),
    });
}

sub checkin {
    my ($class, $c) = @_;
    my $txn = $c->db->txn_scope;

    my $ticket_id = $c->{args}->{ticket_id} // die 'missing ticket_id';
    my $ticket = $c->db->single(
        ticket => { ticket_uuid => GPSTest::UUID->str2bin($ticket_id) } )
      // return $c->show_error(
        "戻るボタンをおしたり、リロードしたりしてはだめです"
      );
    my $locator = do {
        if ($c->req->mobile_agent->is_docomo) {
            $HTTP::MobileAgent::Plugin::Locator::LOCATOR_BASIC;
        } else {
            $HTTP::MobileAgent::Plugin::Locator::LOCATOR_AUTO_FROM_COMPLIANT;
        }
    };
    my $location_raw = $c->req->mobile_agent->get_location($c->req, {locator => $locator}) // return $c->show_error("cannot get location info");
    my $location =
      Geo::Coordinates::Converter->new( point => $location_raw->clone )
      ->convert('degree' => 'wgs84');

    my $gh = Geo::Hash::XS->new();
    my $geohash = $gh->encode($location->lat, $location->lng);

    my ($last_geohash) = $c->db->dbh->selectrow_array(
        q{SELECT geohash FROM pos WHERE user_id=? ORDER BY pos_id DESC LIMIT 1},
        {},
        $c->session_user_id,
    );

    my $distance;
    if ($last_geohash) {
        my ($last_lat, $last_lng) = $gh->decode($last_geohash);
        my $distance_in_meters = GIS::Distance::Lite::distance($last_lat, $last_lng, $location->lat, $location->lng);
        $distance = $distance_in_meters / 1000;
        $c->db->do(q{UPDATE user SET total_distance = total_distance + ? WHERE user_id=?}, {}, $distance, $c->session_user_id);
    }

    my $areacode = point2areacode($location);

    my $user_id = $c->session_user_id // die;
    my $pos = $c->db->insert(
        'pos' => {
            user_id => $user_id,
            geohash => $geohash,
            areacode => $areacode,
        },
    );

    $ticket->delete();

    $txn->commit;

    $c->render(
        'my/checkin.tt',
        {
            location => $location,
            distance => $distance,
            areaname => areacode2areaname($areacode) || undef,
            pos      => $pos,
        }
    );
}
*post_checkin = *checkin;

sub history {
    my ($class, $c) = @_;

    my $page = 0+($c->req->param('page') || 1);
    my $entries_per_page = 10;
    my $offset = $entries_per_page*($page-1);
    my @rows = $c->db->search_by_sql(q{SELECT * FROM pos WHERE user_id=? ORDER BY pos_id DESC LIMIT ? OFFSET ?}, [$c->session_user_id, $entries_per_page+1, $offset], 'pos');
    my $has_next =  ($entries_per_page+1 == @rows);
    if ($has_next) { pop @rows }

    $c->render(
        'my/history.tt',
        {
            rows     => \@rows,
            has_next => $has_next,
            page     => $page,
        }
    );
}

sub point2areacode {
    my ($point) = @_;
    my $geo = Geo::Coordinates::Converter->new(
        formats => [qw/ iArea /],
        point   => $point->clone,
    );
    my $np = $geo->convert('iarea');
    return $np->{areacode};
}

sub areacode2areaname {
    my ($areacode) = @_;
    Geo::Coordinates::Converter::iArea->get_name($areacode);
}

1;
