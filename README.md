# Customers API Lite microservice prototype :small_blue_diamond: <img src="https://blog.lfe.io/assets/images/posts/LispFlavoredErlang-medium-square.png" style="border:0;width:32px" alt="LFE (Lisp Flavoured Erlang)" />

**A daemon written in LFE (Lisp Flavoured Erlang), designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[LFE](https://lfe.io "Lisp Flavoured Erlang | or simply Lisp-2+ dialect for the Erlang VM")** port of the earlier developed **Customers API Lite microservice prototype**, written in Clojure using **[http-kit](https://http-kit.github.io "Simple, high-performance event-driven HTTP client+server for Clojure")** web client/server library, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-clojure-httpkit/blob/main/README.md)** almost as is, without any principal modifications or adjustment.

This repo is dedicated to develop a microservice that implements a prototype of REST API service for ordinary Customers operations like adding/retrieving a Customer to/from the database, also doing the same ops with Contacts (phone or email) which belong to a Customer account.

The data scheme chosen is very simplified and consisted of only three SQL database tables, but that's quite sufficient because the service operates on only two entities: a **Customer** and a **Contact** (phone or email). And a set of these operations is limited to the following ones:

* Create a new customer (put customer data to the database).
* Create a new contact for a given customer (put a contact regarding a given customer to the database).
* Retrieve from the database and list all customer profiles.
* Retrieve profile details for a given customer from the database.
* Retrieve from the database and list all contacts associated with a given customer.
* Retrieve from the database and list all contacts of a given type associated with a given customer.

As it is clearly seen, there are no *mutating*, usually expected operations like *update* or *delete* an entity and that's made intentionally.

The microservice incorporates the **[SQLite](https://sqlite.org "A small, fast, self-contained, high-reliability, full-featured, SQL database engine")** database as its persistent store. It is located in the `data/db/` directory as an XZ-compressed database file with minimal initial data&mdash;actually having two Customers and by six Contacts for each Customer. The database file is automatically decompressed during build process of the microservice and ready to use as is even when containerized with Docker.

Generally speaking, this project might be explored as a PoC (proof of concept) on how to amalgamate LFE/OTP REST API service backed by SQLite database, running standalone as a conventional daemon in host or VM environment, or in a containerized form as usually widely adopted nowadays.

Surely, one may consider this project to be suitable for a wide variety of applied areas and may use this prototype as: (1) a template for building similar microservices, (2) for evolving it to make something more universal, or (3) to simply explore it and take out some snippets and techniques from it for *educational purposes*, etc.

---

## Table of Contents

* **[Building](#building)**
* **[Running](#running)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**

## Building

The microservice might be built and run successfully under **Ubuntu Server (Ubuntu 26.04.1 LTS x86-64)** and **Arch Linux** (both proven).&mdash;First install the necessary dependencies (`rebar3`, `make`, `docker-buildx`):

* In Ubuntu Server:

```
$ sudo apt-get update && \
  sudo apt-get install rebar3 make docker-buildx -y
...
```

* In Arch Linux:

```
$ sudo pacman -Syu rebar3 make docker docker-buildx
...
```

~~Rebar3. Whilst in Arch Linux it is regularly updated and hence can be normally installed from its official repositories, in Ubuntu Server LTS it is quite outdated in stock Ubuntu repositories. Therefore, the preferred method of installing a fresh Rebar3 version is [as described](https://rebar3.org/docs/getting-started/#installing-from-the-rebar3-escript) on its official website.~~

~~But prior to that the Erlang/OTP installation in Ubuntu Server LTS *must be* upgraded to one of modern releases (26, 27, 28) because the latest Rebar3 is not compatible with OTP packages installed from stock Ubuntu repositories (25) and will most likely crash during install. To achieve this, one can use a third-party PPA like [this one](https://launchpad.net/~rabbitmq/+archive/ubuntu/rabbitmq-erlang-27 "Recent Erlang 27.x packages for Ubuntu : Team RabbitMQ") and upgrade currently installed OTP packages:~~

```
$ sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang-27 && \
  sudo apt-get update && \
  sudo apt-get upgrade -y
...
```

~~Now Rebar3 can simply be installed by executing the following compound command:~~

```
$ curl -sO https://s3.amazonaws.com/rebar3/rebar3 && \
  chmod -v 700 rebar3 && ./rebar3 local install && \
  export PATH=/home/<username>/.cache/rebar3/bin:$PATH && \
  rm -vf rebar3
...
```

---

Then pull and install all the necessary plugins and third-party libraries:

```
$ rebar3 tree
===> Fetching rebar3_lfe v0.4.12
===> Fetching lfe v2.2.2
===> Analyzing applications...
===> Compiling lfe
===> Compiling rebar3_lfe
src/cl.lfe:472: Warning: redefining core function car/1
src/cl.lfe:479: Warning: redefining core function cdr/1
===> Verifying dependencies...
===> Fetching cowboy v2.19.0
===> Fetching sqlite3 v1.1.15
===> Fetching pc v1.15.0
===> Analyzing applications...
===> Compiling pc
===> Fetching syslog v1.1.0
===> Fetching cowlib v2.20.0
===> Fetching ranch v2.3.0
└─ api-lite─0.1.10 (project app)
   ├─ cowboy─2.19.0 (hex package)
   │  ├─ cowlib─2.20.0 (hex package)
   │  └─ ranch─2.3.0 (hex package)
   ├─ sqlite3─1.1.15 (hex package)
   └─ syslog─1.1.0 (hex package)
```

---

**Build** the microservice using **Rebar3** (and the LFE plugin):

```
$ rebar3 lfe clean
===> Cleaning out api-lite...
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-helper.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-handler.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite.app
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-model.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-app.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-sup.beam
$
$ rebar3 lfe compile
===> Verifying dependencies...
===> Compiling c_src/sqlite3_drv.c
===> Linking $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/sqlite3/priv/sqlite3_drv.so
===> Analyzing applications...
===> Compiling sqlite3
===> Compiling cowlib
===> Compiling syslog
===> Compiling ranch
===> Compiling cowboy
===> Compiling c_src/syslog_drv.c
===> Linking priv/syslog_drv.so
===> Analyzing applications...
===> Compiling api-lite
$
$ rebar3 lfe release && \
  DB_PATH="data/db"; \
  DB_FILE="customers-api-lite.db.xz"; \
  if [ -f ${DB_PATH}/${DB_FILE} ]; then \
     unxz ${DB_PATH}/${DB_FILE}; \
  fi
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling api-lite
===> Assembling release 'api-lited'-0.1.10...
===> Release successfully assembled: _build/default/rel/api-lited
```

**Beware:** Executing the `lfe clean` task for the first time (when there is no subdirectory `_build/default/lib/api-lite/ebin/` yet exist) will probably lead to the error from Rebar3: `===> Uncaught error in rebar_core. Run with DIAGNOSTIC=1 to see stacktrace or consult rebar3.crashdump` and the appropriate crash report `rebar3.crashdump` will be generated in the current working directory. This can simply be ignored because after executing either `lfe compile` or `lfe release` tasks, any consequent `lfe clean` task will succeed.

One can also **build** the microservice using **GNU Make** (optional, but for convenience&mdash;it covers the same **Rebar3** build workflow under the hood):

```
$ make clean
...
$ make      # <== Compilation only phase (Erlang BEAMs).
...
$ make all  # <== Building the daemon (OTP release).
...
```

## Running

**Run** the microservice using **Rebar3**/LFE plugin (recompiling sources on-the-fly, if required):

```
$ rebar3 lfe run-release daemon; echo $?
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling api-lite
<empty_line>
0
```

It will be launched in the background as a daemon but also can be started up as a regular app: `$ rebar3 lfe run-release foreground`. The daemonized microservice then can be stopped at any time by issuing the following command:

```
$ rebar3 lfe run-release stop; echo $?
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling api-lite
<empty_line>
0
```

**Run** the microservice using its startup script along with the `foreground` command, that is meant "*Start release with output to stdout*":

```
$ ./_build/default/rel/api-lited/bin/api-lited foreground; echo $?
...
```

The microservice then can be stopped, again by using its startup script but along with the `stop` command, that is meant "*Stop the running node*". It should be issued in another terminal session, not the current one of course:

```
$ ./_build/default/rel/api-lited/bin/api-lited stop; echo $?
0
```

To identify, which particular commands are available and what they mean, the startup script can be run without specifying any command at all:

```
$ ./_build/default/rel/api-lited/bin/api-lited
Usage: api-lited [COMMAND] [ARGS]

Commands:

  foreground              Start release with output to stdout
...
  stop                    Stop the running node
  restart                 Restart the applications but not the VM
  reboot                  Reboot the entire VM
...
  daemon                  Start release in the background with run_erl (named pipes)
...
```

Thus, to run the microservice as a daemon, i.e. in the background, the `daemon` command should be used instead:

```
$ ./_build/default/rel/api-lited/bin/api-lited daemon; echo $?
0
```

Note that the startup script will become available and might be used only after building a complete OTP release of the microservice.

## Consuming

The microservice should expose **six REST API endpoints** to web clients. They are all intended to deal with customer entities and/or contact entities that belong to customer profiles. The following table displays their syntax:

No. | Endpoint name                                      | Request method and REST URI                                   | Request body
--: | -------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------
1   | Create customer                                    | **PUT** `/v1/customers`                                       | `{"name":"{customer_name}"}`
2   | Create contact                                     | **PUT** `/v1/customers/contacts`                              | `{"customer_id":"{customer_id}","contact":"{customer_contact}"}`
3   | List customers                                     | **GET** `/v1/customers`                                       | &ndash;
4   | Retrieve customer                                  | **GET** `/v1/customers/{customer_id}`                         | &ndash;
5   | List contacts for a given customer                 | **GET** `/v1/customers/{customer_id}/contacts`                | &ndash;
6   | List contacts of a given type for a given customer | **GET** `/v1/customers/{customer_id}/contacts/{contact_type}` | &ndash;

* The `{customer_name}` placeholder is a string&mdash;it usually means the full name given to a newly created customer.
* The `{customer_id}` placeholder is a decimal positive integer number, greater than `0`.
* The `{customer_contact}` placeholder is a string&mdash;it denotes a newly created customer contact (phone or email).
* The `{contact_type}` placeholder is a string and can take one of two possible values, case-insensitive: `phone` or `email`.

The following command-line snippets display the exact usage for these endpoints (the **cURL** utility is used as an example to access them)^:

1. **Create customer**

```
$ curl -vXPUT http://localhost:8765/v1/customers \
       -H 'content-type: application/json' \
       -d '{"name":"Jamison Palmer"}'
...
> PUT /v1/customers HTTP/1.1
...
> content-type: application/json
> Content-Length: 25
...
< HTTP/1.1 204 No Content
< allow: PUT, GET, HEAD
...
< server: Cowboy
...
```

2. **Create contact**

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"+12197654320"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 44
...
< HTTP/1.1 204 No Content
< allow: PUT
...
< server: Cowboy
...
```

Or create **email** contact:

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"jamison.palmer@example.com"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 58
...
< HTTP/1.1 204 No Content
< allow: PUT
...
< server: Cowboy
...
```

3. **List customers**

```
$ curl -v http://localhost:8765/v1/customers
...
> GET /v1/customers HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: PUT, GET, HEAD
< content-length: 66
< content-type: application/json
...
< server: Cowboy
...
[{"id":1,"name":"Jammy Jellyfish"},{"id":2,"name":"Noble Numbat"}]
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/2
...
> GET /v1/customers/2 HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 30
< content-type: application/json
...
< server: Cowboy
...
{"id":2,"name":"Noble Numbat"}
```

5. **List contacts for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/2/contacts
...
> GET /v1/customers/2/contacts HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 2
< content-type: application/json
...
< server: Cowboy
...
{}
```

6. **List contacts of a given type for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/2/contacts/phone
...
> GET /v1/customers/2/contacts/phone HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 2
< content-type: application/json
...
< server: Cowboy
...
{}
```

Or list **email** contacts:

```
$ curl -v http://localhost:8765/v1/customers/2/contacts/email
...
> GET /v1/customers/2/contacts/email HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 2
< content-type: application/json
...
< server: Cowboy
...
{}
```

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `logger-debug-enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Ubuntu Server or Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2026-10-02|22:40:00.332650+02:00] [debug] [Customers API Lite]
[2026-10-02|22:40:00.335669+02:00] [debug] [<0.501.0>]
[2026-10-02|22:40:00.337619+02:00] [info] Server started on port 8765
[2026-10-02|22:40:20.889817+02:00] [debug] [PUT]
[2026-10-02|22:40:20.893443+02:00] [debug] [r-put-get-cust]
[2026-10-02|22:40:20.894418+02:00] [debug] [PUT]
[2026-10-02|22:40:20.894912+02:00] [debug] [<0.501.0>]
[2026-10-02|22:40:20.895486+02:00] [debug] pid: <0.541.0>, port: 8765, ...
[2026-10-02|22:40:40.294704+02:00] [debug] [PUT]
[2026-10-02|22:40:40.297251+02:00] [debug] [r-put-cont]
[2026-10-02|22:40:40.297822+02:00] [debug] [PUT]
[2026-10-02|22:40:40.298347+02:00] [debug] [<0.501.0>]
[2026-10-02|22:40:40.298794+02:00] [debug] pid: <0.543.0>, port: 8765, ...
[2026-10-02|22:45:10.642925+02:00] [debug] [PUT]
[2026-10-02|22:45:10.646668+02:00] [debug] [r-put-cont]
[2026-10-02|22:45:10.649824+02:00] [debug] [PUT]
[2026-10-02|22:45:10.650582+02:00] [debug] [<0.501.0>]
[2026-10-02|22:45:10.651030+02:00] [debug] pid: <0.546.0>, port: 8765, ...
[2026-10-02|22:45:30.090516+02:00] [debug] [GET]
[2026-10-02|22:45:30.093622+02:00] [debug] [r-put-get-cust]
[2026-10-02|22:45:30.094445+02:00] [debug] [GET]
[2026-10-02|22:45:30.094948+02:00] [debug] pid: <0.548.0>, port: 8765, ...
[2026-10-02|22:45:30.108794+02:00] [debug] [1|Jammy Jellyfish]
[2026-10-02|22:45:30.109439+02:00] [debug] [[#{id => 1,name => <<"Jammy Jellyfish">>},#{id => 2,name => <<"Noble Numbat">>}]]
[2026-10-02|22:45:50.716747+02:00] [debug] [GET]
[2026-10-02|22:45:50.717441+02:00] [debug] [r-get-cust]
[2026-10-02|22:45:50.717873+02:00] [debug] [GET]
[2026-10-02|22:45:50.720619+02:00] [debug] pid: <0.550.0>, port: 8765, ...
[2026-10-02|22:45:50.724827+02:00] [debug] columns: idname, rows: [{2,<<"Noble Numbat">>}]
[2026-10-02|22:45:50.725512+02:00] [debug] []
[2026-10-02|22:50:00.698736+02:00] [debug] [GET]
[2026-10-02|22:50:00.700158+02:00] [debug] [r-get-cont]
[2026-10-02|22:50:00.703714+02:00] [debug] [GET]
[2026-10-02|22:50:00.704272+02:00] [debug] pid: <0.552.0>, port: 8765, ...
[2026-10-02|22:50:00.709579+02:00] [debug] columns: contact, rows: [{<<"+35760X123456">>},{<<"+35760Y1234578">>},{<<"+35790Z12345890">>},{<<"nn@example.org">>},{<<"nnumbat@example.com">>},{<<"noble.numbat@example.com">>}]
[2026-10-02|22:50:00.710676+02:00] [debug] []
[2026-10-02|22:50:20.418515+02:00] [debug] [GET]
[2026-10-02|22:50:20.419331+02:00] [debug] [r-get-cont-type]
[2026-10-02|22:50:20.420456+02:00] [debug] [GET]
[2026-10-02|22:50:20.421298+02:00] [debug] pid: <0.554.0>, port: 8765, ...
[2026-10-02|22:50:20.427301+02:00] [debug] columns: contact, rows: [{<<"+35760X123456">>},{<<"+35760Y1234578">>},{<<"+35790Z12345890">>}]
[2026-10-02|22:50:20.428114+02:00] [debug] []
[2026-10-02|22:50:40.586627+02:00] [debug] [GET]
[2026-10-02|22:50:40.587454+02:00] [debug] [r-get-cont-type]
[2026-10-02|22:50:40.590438+02:00] [debug] [GET]
[2026-10-02|22:50:40.592706+02:00] [debug] pid: <0.556.0>, port: 8765, ...
[2026-10-02|22:50:40.596998+02:00] [debug] columns: contact, rows: [{<<"+35760X123456">>},{<<"+35760Y1234578">>},{<<"+35790Z12345890">>}]
[2026-10-02|22:50:40.597898+02:00] [debug] []
[2026-10-02|22:55:00.473664+02:00] [info] Server stopped
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Oct 02 22:40:00 <hostname> api-lited[<pid>]: [Customers API Lite]
Oct 02 22:40:00 <hostname> api-lited[<pid>]: [<0.501.0>]
Oct 02 22:40:00 <hostname> api-lited[<pid>]: Server started on port 8765
Oct 02 22:40:20 <hostname> api-lited[<pid>]: [PUT]
Oct 02 22:40:20 <hostname> api-lited[<pid>]: [r-put-get-cust]
Oct 02 22:40:20 <hostname> api-lited[<pid>]: [PUT]
Oct 02 22:40:20 <hostname> api-lited[<pid>]: [<0.501.0>]
Oct 02 22:40:40 <hostname> api-lited[<pid>]: [PUT]
Oct 02 22:40:40 <hostname> api-lited[<pid>]: [r-put-cont]
Oct 02 22:40:40 <hostname> api-lited[<pid>]: [PUT]
Oct 02 22:40:40 <hostname> api-lited[<pid>]: [<0.501.0>]
Oct 02 22:45:10 <hostname> api-lited[<pid>]: [PUT]
Oct 02 22:45:10 <hostname> api-lited[<pid>]: [r-put-cont]
Oct 02 22:45:10 <hostname> api-lited[<pid>]: [PUT]
Oct 02 22:45:10 <hostname> api-lited[<pid>]: [<0.501.0>]
Oct 02 22:45:30 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:45:30 <hostname> api-lited[<pid>]: [r-put-get-cust]
Oct 02 22:45:30 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:45:30 <hostname> api-lited[<pid>]: [1|Jammy Jellyfish]
Oct 02 22:45:50 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:45:50 <hostname> api-lited[<pid>]: [r-get-cust]
Oct 02 22:45:50 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:50:00 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:50:00 <hostname> api-lited[<pid>]: [r-get-cont]
Oct 02 22:50:00 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:50:20 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:50:20 <hostname> api-lited[<pid>]: [r-get-cont-type]
Oct 02 22:50:20 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:50:40 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:50:40 <hostname> api-lited[<pid>]: [r-get-cont-type]
Oct 02 22:50:40 <hostname> api-lited[<pid>]: [GET]
Oct 02 22:55:00 <hostname> api-lited[<pid>]: Server stopped
```

**TBD** :cd:

---

**WIP** :dvd:
