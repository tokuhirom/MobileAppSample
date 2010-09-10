use inc::Module::Install;
all_from "lib/GPSTest.pm";

requires 'GIS::Distance::Lite';
requires 'HTML::MobileJp';
requires 'Geo::Coordinates::Converter';

tests 't/*.t t/*/*.t t/*/*/*.t';
requires 'Amon2';
recursive_author_tests('xt');

WriteAll;
