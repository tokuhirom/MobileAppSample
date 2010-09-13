create table user (
    user_id int unsigned not null auto_increment primary key,
    mobile_uid varchar(255) BINARY NOT NULL,
    total_distance bigint not null default 0,
    UNIQUE (mobile_uid)
) engine=innodb;

create table pos (
    pos_id int unsigned not null auto_increment primary key,
    user_id int unsigned not null,
    geohash varchar(12) binary not null,
    areacode   INT UNSIGNED DEFAULT NULL,
    timestamp timestamp not null,
    index (user_id, pos_id)
) engine=innodb;

create table ticket (
    ticket_uuid binary(16) not null,
    ctime       INT UNSIGNED NOT NULL,
    primary key (ticket_uuid),
    index (ctime) ## for deleting old tickets
) engine=innodb;

CREATE TABLE session (
    sid          VARCHAR(32) PRIMARY KEY,
    data         TEXT,
    expires      INTEGER UNSIGNED NOT NULL,
    UNIQUE(sid)
);

