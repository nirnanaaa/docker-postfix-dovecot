#!/bin/bash
echo "Executing template"


USER=$1
PASS=$2
NAME=$3
HOST=$4


function template {
  case $1 in
    virtual)
      echo "user=$USER
password=$PASS
dbname=$NAME
table=postfix_virtual
select_field=userid
where_field=address
hosts=$HOST" > $PF_DIR/virtual.cf
      ;;
    transport)
     echo "user=$USER
password=$PASS
dbname=$NAME
table=transport
select_field=transport
where_field=domain
hosts=$HOST" > $PF_DIR/transport.cf
      ;;
    mailboxes)
     echo "user=$USER
password=$PASS
dbname=$NAME
table=postfix_mailboxes
select_field=mailbox
where_field=userid
hosts=$HOST" > $PF_DIR/mailboxes.cf
      ;;
    dovecot_sql)
      echo "driver = pgsql
connect = host=$HOST dbname=$NAME user=$USER password=$PASS
default_pass_scheme = CRYPT
password_query = SELECT userid as user, password FROM users WHERE userid = '%u'
user_query = SELECT home, uid, gid FROM users WHERE userid = '%u'" > $DC_DIR/dovecot-sql.conf.ext
      ;;
    domain_cnf)
      echo "[ req ]
default_bits       = 4096
default_md         = sha512
default_keyfile    = key.pem
prompt             = no
encrypt_key        = no

# base request
distinguished_name = req_distinguished_name

# extensions
req_extensions     = v3_req

# distinguished_name
[ req_distinguished_name ]
countryName            = 'DE'                     # C=
stateOrProvinceName    = 'bayern'                 # ST=
localityName           = 'Keller'                 # L=
postalCode             = '12345'                 # L/postalcode=
streetAddress          = 'Crater 1621'            # L/street=
organizationName       = 'Dovecot'        # O=
organizationalUnitName = 'IT Department'          # OU=
commonName             = '$MAILNAME'            # CN=
emailAddress           = 'postmaster@$MAILNAME'  # CN/emailAddress=

# req_extensions
[ v3_req ]
# The subject alternative name extension allows various literal values to be
# included in the configuration file
# http://www.openssl.org/docs/apps/x509v3_config.html
subjectAltName  = DNS:www.example.com,DNS:www2.example.com # multidomain certificate

# vim:ft=config" > /domain_ssl.cnf
      ;;
    *)
      ;;
  esac

}

template virtual
template transport
template mailboxes
template dovecot_sql
template domain_cnf
