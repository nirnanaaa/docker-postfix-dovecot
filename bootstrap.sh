#!/bin/bash

[ -d /var/mail/vmail/sieve ] || mkdir -p /var/mail/vmail/sieve
chown -R vmail:vmail /var/mail/vmail/sieve

echo "$HOSTNAME" > /etc/hostname
echo "$MAILNAME" > /etc/mailname
postconf -e "myhostname=$HOSTNAME"

echo "postmaster_address = postmaster@$MAILNAME" >> /etc/dovecot/conf.d/15-lda.conf

PF_DIR=/etc/postfix DC_DIR=/etc/dovecot /template $PF_DB_USER $PF_DB_PASS $PF_DB_NAME $PF_DB_HOST

