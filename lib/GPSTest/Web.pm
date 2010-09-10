package GPSTest::Web;
use strict;
use warnings;
use parent qw/GPSTest Amon2::Web/;
__PACKAGE__->add_config(
    'Text::Xslate' => {
        'syntax'   => 'TTerse',
        'function' => {
            c => sub { Amon2->context() },
        },
    }
);
__PACKAGE__->setup(
    view_class => 'Text::Xslate',
);
1;
