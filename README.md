# Docker images with Postfix, Dovecot, Postgrey, Policyd

Build the image:

```
> docker build -t mailserver .
```

The image provides three commands:

* start
* log


# TODO
* run postfix as user postfix with correct permissions for
  /var/lib/postfix and /var/spool/postfix
* support etcd
* document postgres usage
* test
