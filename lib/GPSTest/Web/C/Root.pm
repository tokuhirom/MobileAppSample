package GPSTest::Web::C::Root;
use strict;
use warnings;
use HTML::MobileJp;

sub index {
    my ($class, $c) = @_;
    $c->render("index.tt");
}

sub login {
    my ($class, $c) = @_;
    my $mobile_uid = $c->req->mobile_agent->user_id // return $c->show_error("端末IDが送信されていません");
    my $user = $c->db->find_or_create(
        user => {
            mobile_uid => $mobile_uid,
        },
    );
    $c->session->set('user_id' => $user->user_id);
    return $c->redirect('/my/');
}

1;
