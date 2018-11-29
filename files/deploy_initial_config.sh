#!/bin/sh

INSTALLDIR="/usr/share/centreon/install"
INSTALLWWWDIR="/usr/share/centreon/www/install"

if [ -d $INSTALLWWWDIR ]; then
    mkdir -p $INSTALLDIR
    for SQL in ${INSTALLWWWDIR}/*.sql; do
        /bin/python /tmp/do_replace.py $SQL
    done
else
    exit 0
fi