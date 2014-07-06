#!/bin/bash
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
      ls -lah /etc/postfix
      cat /etc/postfix/mailboxes.cf
      ;;
    dovecot_sql)
      echo "driver = pgsql
connect = host=$HOST dbname=$NAME user=$USER password=$PASS
default_pass_scheme = CRYPT
password_query = SELECT userid as user, password FROM users WHERE userid = '%u'
user_query = SELECT home, uid, gid FROM users WHERE userid = '%u'" > $DC_DIR/dovecot-sql.conf.ext
      ls -lah /etc/dovecot
      cat /etc/dovecot/dovecot-sql.conf.ext
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
