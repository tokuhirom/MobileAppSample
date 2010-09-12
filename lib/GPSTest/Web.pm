package GPSTest::Web;
use strict;
use warnings;
use parent qw/GPSTest Amon2::Web/;
use HTTP::MobileAgent;
use HTTP::MobileAgent::Plugin::Locator;
use GPSTest::DB;
use HTTP::Session::Store::DBI;
use HTTP::Session::State::Cookie;
use HTTP::Session::State::URI;
use HTTP::Session;

__PACKAGE__->add_config(
    'Text::Xslate' => {
        'syntax'   => 'TTerse',
            module => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
        },
    }
);

__PACKAGE__->setup(
    view_class => 'Text::Xslate',
);

__PACKAGE__->load_plugins('Web::MobileAgent');
sub session {
    my $c = shift;
    $c->{session} //= do {
        my $state = HTTP::Session::State::Cookie->new();
        my $store = HTTP::Session::Store::DBI->new(
            dbh => $c->db->dbh,
        );
        HTTP::Session->new(
            state   => $state,
            store   => $store,
            request => $c->req,
        );
    };
}

sub show_error {
    my ($c, $msg) = @_;
    $c->render('error.tt', {message => $msg});
}

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ($c) = @_;
        if ($c->req->mobile_agent->is_non_mobile) {
            return $c->show_error('this site requires mobile phone :' . $c->req->user_agent);
        }
        if ($c->req->path_info =~ m{^/my/} && !$c->session_user_id) {
            return $c->redirect('/');
        }
    }
);
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ($c, $res) = @_;
        if ($c->{session}) {
            $c->session->response_filter($res);
            $c->session->finalize();
        }
    },
);

sub db {
    my $self = shift;
    $self->{db} //= do {
        my $conf = $self->config->{db} // die "missing configuration for db";
        GPSTest::DB->new($conf);
    };
}

sub session_user_id {
    my ($self) = @_;
    $self->session->get('user_id')
}

sub session_user {
    my ($self) = @_;
    $self->db->single(user => {user_id => $self->session_user_id()});
}

1;
