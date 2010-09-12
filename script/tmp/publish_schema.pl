use DBIx::Skinny::Schema::Loader qw/make_schema_at/;
BEGIN { $ENV{PLACK_ENV} //= 'development' }
use GPSTest;

my $c = GPSTest->bootstrap;
my $conf = $c->config->{db} // die "missing configuration for db";
print make_schema_at(
    'GPSTest::DB::Schema',
    +{},
    [ $conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{connect_options} ]
);
