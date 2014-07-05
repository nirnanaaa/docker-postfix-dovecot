# Docker images with Postfix, Dovecot, Postgrey, Policyd

Build the image:

```
> docker build -t mailserver .
```

The image provides three commands:

* configure
* start
* log

`configure` is used to configure postfix dovecot and postgrey for your
needs. It takes one argument.

```
> docker run mailserver configure <mailname> <dbhost> <dbname> <dbuser> <dbpass>
```
