use inc::Module::Install;
all_from "lib/GPSTest.pm";

requires 'GIS::Distance::Lite';
requires 'HTML::MobileJp';
requires 'Geo::Coordinates::Converter';
requires 'Data::UUID';
requires 'Geo::Hash::XS';
requires 'HTTP::MobileAgent';
requires 'HTTP::MobileAgent::Locator';
requires 'HTTP::Session::Store::DBI';
requires 'Geo::Coordinates::Converter::IArea';
requires 'Plack::Middleware::ReverseProxy';
requires 'URI::WithBase';

tests 't/*.t t/*/*.t t/*/*/*.t';
requires 'Amon2';
recursive_author_tests('xt');

WriteAll;
