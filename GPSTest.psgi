use File::Spec;
use File::Basename;
use local::lib File::Spec->catdir(dirname(__FILE__), 'extlib');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use GPSTest::Web;
use Plack::Builder;

builder {
    mount '/gpstest/' => builder {
        enable 'Plack::Middleware::ReverseProxy';
        enable 'Plack::Middleware::Static',
            path => qr{^/static/},
            root => './htdocs/';
        GPSTest::Web->to_app();
    };
};
