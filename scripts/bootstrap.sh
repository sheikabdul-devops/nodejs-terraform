#! /bin/bash

dest=$4
dbuser=$2
dbpass=$3

cd $dest/scripts

tar xzvf myapp.tar.gz

cd $dest/scripts/myfirstapp/

endpoint=`echo $1 | cut -d ':' -f 1`

echo "RDS_HOSTNAME=$endpoint" >> $dest/scripts/myfirstapp/.env
echo "RDS_USERNAME=$dbuser" >> $dest/scripts/myfirstapp/.env
echo "RDS_PASSWORD=$dbpass" >> $dest/scripts/myfirstapp/.env

/usr/bin/mysql --host=$endpoint --user=$2 --password=$3 << EOF
USE innodb;
DROP TABLE IF EXISTS devices;
CREATE TABLE IF NOT EXISTS devices ( id int(11) NOT NULL, devicename varchar(200) NOT NULL, brand varchar(200) NOT NULL,  devicetype varchar(200) NOT NULL);
ALTER TABLE devices ADD PRIMARY KEY (id);
ALTER TABLE devices MODIFY id int(11) NOT NULL AUTO_INCREMENT;
INSERT INTO devices (devicename, brand,devicetype) VALUES('Samsung A3','Samsung','Mobile');
INSERT INTO devices (devicename, brand,devicetype) VALUES('Iphone 7','Apple','Mobile');
INSERT INTO devices (devicename, brand,devicetype) VALUES('Samsung Galaxy 7','Samsung','Mobile');
EOF


