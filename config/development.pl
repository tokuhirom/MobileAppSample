+{
    'Text::Xslate' => {
        path => ['tmpl/'],
    },
    'Log::Dispatch' => {
        outputs => [
            ['Screen',
            min_level => 'debug',
            stderr => 1,
            newline => 1],
        ],
    },
    db => {
        'dsn' => 'dbi:mysql:database=dev_GPSTest',
        username => 'root',
        password => '',
        connect_options => +{
            'mysql_enable_utf8' => 1,
            'mysql_read_default_file' => '/etc/mysql/my.cnf',
        },
    },
};
