package GPSTest::Web::Dispatcher;
use Amon2::Web::Dispatcher::RouterSimple;

sub c2 {
    my ($path, $dst) = @_;
    if ($dst =~ m{^(\w+)#(\w+)}) {
        connect($path, {controller => $1, action => $2});
    } else {
        connect(@_);
    }
}

c2 '/'                      => 'Root#index';
c2 '/login'                 => 'Root#login';
c2 '/my/'                   => 'My#index';
c2 '/my/checkin/:ticket_id' => 'My#checkin';
c2 '/my/history'            => 'My#history';

1;
