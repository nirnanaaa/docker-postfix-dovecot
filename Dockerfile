FROM ubuntu:quantal
MAINTAINER Florian Kasper <mosny@zyg.li>

# VMAIL
RUN groupadd --gid 10000 vmail
RUN mkdir -p /var/mail/vmail
RUN useradd -d /var/mail/vmail -M -N --gid 10000 --uid 10000 vmail
RUN chown -R vmail:vmail /var/mail/vmail

RUN apt-get update -yqq
RUN apt-get upgrade -yqq

# Allow postfix to install without interaction.
RUN echo "postfix postfix/mailname string example.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections


# Install packages
RUN apt-get install -yqq sudo postfix postgrey postfix-pcre postfix-pgsql policyd-weight dovecot-common dovecot-core dovecot-gssapi dovecot-imapd dovecot-ldap dovecot-lmtpd dovecot-pgsql dovecot-sieve
# Copy postfix configuration
ADD postfix/master.cf /etc/postfix/master.cf
ADD postfix/body_checks /etc/postfix/body_checks

# Access checks
ADD postfix/access_recipient_rfc /etc/postfix/access_recipient_rfc
ADD postfix/access_recipient /etc/postfix/access_recipient
ADD postfix/access_client /etc/postfix/access_client
ADD postfix/access_helo /etc/postfix/access_helo
ADD postfix/access_sender /etc/postfix/access_sender

RUN postmap /etc/postfix/access_recipient
RUN postmap /etc/postfix/access_recipient_rfc
RUN postmap /etc/postfix/access_helo
RUN postmap /etc/postfix/access_sender
RUN postmap /etc/postfix/access_client

# Dovecot
ADD dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf
ADD dovecot/conf.d/10-director.conf /etc/dovecot/conf.d/10-director.conf
ADD dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
ADD dovecot/conf.d/10-logging.conf /etc/dovecot/conf.d/10-logging.conf
ADD dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf
ADD dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
ADD dovecot/conf.d/15-lda.conf /etc/dovecot/conf.d/15-lda.conf
ADD dovecot/conf.d/15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf
ADD dovecot/conf.d/20-lmtp.conf /etc/dovecot/conf.d/20-lmtp.conf

RUN mkdir /etc/dovecot/dovecot-acls
ADD dovecot/conf.d/90-acl.conf /etc/dovecot/conf.d/90-acl.conf
ADD dovecot/conf.d/90-plugin.conf /etc/dovecot/conf.d/90-plugin.conf
ADD dovecot/conf.d/90-sieve.conf /etc/dovecot/conf.d/90-sieve.conf

ADD dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
ADD dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext




ADD template.sh /template
RUN chmod +x /template

ADD postfix/header_checks /etc/postfix/header_checks
ADD postfix/main.cf /etc/postfix/main.cf
ADD postfix/dynamicmaps.cf /etc/postfix/dynamicmaps.cf

ADD bootstrap.sh /bootstrap.sh
CMD exec "/bootstrap.sh"

RUN chown -R postfix:postfix /etc/postfix


# Port configuration
EXPOSE 25
EXPOSE 143
EXPOSE 993

ADD start.sh /start.sh
entrypoint ["/start.sh"]