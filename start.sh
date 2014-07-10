#!/bin/bash

PATH="/usr/bin:/bin:/usr/local/bin:/sbin:/usr/local/sbin:/usr/sbin"

# use /data as vmail directory if available
if [ -d "/data" ]; then
  ln -nsf /data /var/mail/vmail
fi

function initdb(){
  if [ ! -d /var/lib/postgresql/9.1/main ]; then
    cd /var/lib/postgresql
    mkdir 9.1
    chown -R postgres:postgres /var/lib/postgresql
    su -c '/usr/lib/postgresql/9.1/bin/initdb /var/lib/postgresql/9.1/main' postgres
  fi
}

case $1 in
  import)
    initdb
    sudo -u postgres psql < /import/$2
    ;;
  import_http)
    initdb
    apt-get install -yqq wget
    mkdir /pg_dumps
    cd /pg_dumps
    wget $2 --no-check-certificate
    su postgres -c "/usr/lib/postgresql/9.1/bin/pg_ctl start -D /var/lib/postgresql/9.1/main"
    sleep 5
    chown -R postgres:postgres /pg_dumps
    su -c 'psql -f *' postgres
    su postgres -c "/usr/lib/postgresql/9.1/bin/pg_ctl stop -D /var/lib/postgresql/9.1/main"
    ;;
  start)
    /usr/sbin/service postgrey stop > /dev/null 2>&1
    /usr/sbin/service policyd-weight stop > /dev/null 2>&1

    mkdir -p /etc/dovecot/private
    [ -f /etc/dovecot/dovecot.pem ] || openssl req \
      -new -x509 -days 1000 \
      -newkey rsa:4096 \
      -subj "/C=DE/ST=Bayern/L=Nuernberg/O=Dovecot/OU=$MAILNAME/CN=$MAILNAME" \
      -nodes \
      -out "/etc/dovecot/dovecot.pem" -keyout "/etc/dovecot/private/dovecot.pem"

    initdb

    /bin/bash /bootstrap.sh
    supervisord -n
  ;;
  *)
    echo Commands:
    echo "    start             Launch the complete package"
    echo "    import <Filename> Imports a database dump from file /import/<Filename>"
    echo "    import_http <URL> Improts a database dump from url"
  ;;
esac


wait
