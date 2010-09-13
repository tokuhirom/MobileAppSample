package GPSTest::HTTP::Session::State;
use strict;
use warnings;
use parent qw/HTTP::Session::State::URI/;

sub get_session_id {
    my ($self, $req) = @_;
    Carp::croak "missing req" unless $req;
    if ($req->path_info =~ m{^/my/checkin/(\w+)/.+$}) {
        return "$1";
    } else {
        return $req->param($self->session_id_name);
    }
}

1;
