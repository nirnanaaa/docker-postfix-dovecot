#!/bin/bash

PATH="/usr/bin:/bin:/usr/local/bin:/sbin:/usr/local/sbin:/usr/sbin"

# use /data as vmail directory if available
if [ -d "/data" ]; then
  ln -nsf /data /var/mail/vmail
fi


case $1 in
  start)
    /bin/bash /bootstrap.sh

    if [ ! -f /etc/postfix/transport.cf ]; then
      echo "you must run the configure task before running"
      exit 1
    fi
    /usr/sbin/service postgrey stop > /dev/null 2>&1
    /usr/sbin/service policyd-weight stop > /dev/null 2>&1

    mkdir -p /etc/dovecot/private
    [ -f /etc/dovecot/dovecot.pem ] || openssl req \
      -new -x509 -days 1000 \
      -newkey rsa:4096 \
      -subj "/C=DE/ST=Bayern/L=Nuernberg/O=Dovecot/OU=$MAILNAME/CN=$MAILNAME" \
      -nodes \
      -out "/etc/dovecot/dovecot.pem" -keyout "/etc/dovecot/private/dovecot.pem"

    supervisord -n
  ;;
  *)
    echo Commands:
    echo "    start       Launch the complete package"
    echo "    configure   Perform the configuration steps"
    echo "    log         Tail the mail log under /var/log/mail.log"
    echo "    shell       Open a shell"
  ;;
esac


wait
