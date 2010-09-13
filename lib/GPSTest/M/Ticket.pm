package GPSTest::M::Ticket;
use strict;
use warnings;
use GPSTest::UUID;
use Amon2::Declare;
use Params::Validate qw/:all/;

# create new ticket
sub create {
    my $id = GPSTest::UUID->create();
    c->db->insert(
        ticket => {
            ticket_uuid => $id,
            ctime       => time(),
        },
    );
    return GPSTest::UUID->bin2str($id);
}

1;
