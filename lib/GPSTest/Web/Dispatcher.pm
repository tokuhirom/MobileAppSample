package GPSTest::Web::Dispatcher;
use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => {controller => 'Root', action => 'index'};

1;
