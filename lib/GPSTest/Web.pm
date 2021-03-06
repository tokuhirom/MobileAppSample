package GPSTest::Web;
use strict;
use warnings;
use parent qw/GPSTest Amon2::Web/;
use HTTP::MobileAgent;
use HTTP::MobileAgent::Plugin::Locator;
use GPSTest::DB;
use HTTP::Session::Store::DBI;
use GPSTest::HTTP::Session::State;
use HTTP::Session;

__PACKAGE__->add_config(
    'Text::Xslate' => {
        'syntax'   => 'TTerse',
            module => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            commify  => sub {
                local $_  = shift;
                1 while s/((?:\A|[^.0-9])[-+]?\d+)(\d{3})/$1,$2/s;
                return $_;
            },
        },
    }
);

__PACKAGE__->setup(
    view_class => 'Text::Xslate',
);

__PACKAGE__->load_plugins('Web::MobileAgent');
__PACKAGE__->load_plugins('Web::FillInFormLite');
__PACKAGE__->load_plugins('Web::NoCache');
sub session {
    my $c = shift;
    $c->{session} //= do {
        my $state = GPSTest::HTTP::Session::State->new(
            session_id_name => 'gsid',
        );
        my $store = HTTP::Session::Store::DBI->new( dbh => $c->db->dbh, );
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
        if ($c->req->path_info =~ m{^/my/}) {
            if (!$c->session_user()) {
                return $c->redirect('/');
            }
        } else {
            if ($c->session_user) {
                return $c->redirect('/my/');
            }
        }
    }
);
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ($c, $res) = @_;
        $c->session->response_filter($res);
        $c->session->finalize();
        if ($res->content_type =~ /html/ && !ref $res->content) {
            $res->content_length(length $res->content);
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
