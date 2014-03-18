# conjure/postgres93:1.0.0

FROM atbaker/sd-postgres
MAINTAINER Brian Auton brianauton@gmail.com

RUN useradd db
RUN /sbin/my_init -- /sbin/setuser postgres sh -c "sleep 1; psql -h localhost -c 'CREATE USER db CREATEDB'"
RUN /sbin/my_init -- /sbin/setuser db sh -c "sleep 1; createdb db"

RUN echo 'local all all  ident' >/usr/local/pgsql/data/pg_hba.conf
RUN echo 'host all all 0.0.0.0/0 md5' >>/usr/local/pgsql/data/pg_hba.conf
RUN echo 'host all all ::1/128 md5' >>/usr/local/pgsql/data/pg_hba.conf
