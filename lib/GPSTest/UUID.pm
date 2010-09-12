package GPSTest::UUID;
use strict;
use warnings;
use Data::UUID;

my $uuid = Data::UUID->new();

sub create { $uuid->create() }

sub bin2str {
    my $b64 = $uuid->to_b64string( $_[1] );
    $b64 =~ tr|+/=|\-_|d;
    return $b64;
}

sub str2bin {
    my $b64 = $_[1];
    $b64 =~ tr|\-_\t-\x0d |+/|d;
    return $uuid->from_b64string($b64);
}

1;
