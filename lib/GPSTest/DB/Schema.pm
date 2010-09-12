package GPSTest::DB::Schema;
use DBIx::Skinny::Schema;

install_table pos => schema {
    pk qw/pos_id/;
    columns qw/pos_id user_id geohash timestamp/;
};

install_table session => schema {
    pk qw/sid/;
    columns qw/sid data expires/;
};

install_table ticket => schema {
    pk qw/ticket_uuid/;
    columns qw/ticket_uuid/;
};

install_table user => schema {
    pk qw/user_id/;
    columns qw/user_id mobile_uid total_distance/;
};

1;