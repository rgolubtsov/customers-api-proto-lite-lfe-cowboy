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
  * **[Creating a Docker image](#creating-a-docker-image)**
* **[Running](#running)**
  * **[Running a Docker image](#running-a-docker-image)**
  * **[Exploring a Docker image payload](#exploring-a-docker-image-payload)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**
  * **[Error handling](#error-handling)**

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
===> Fetching cowboy v2.20.0
===> Fetching sqlite3 v1.1.15
===> Fetching pc v1.15.0
===> Analyzing applications...
===> Compiling pc
===> Fetching syslog v1.1.0
===> Fetching cowlib v2.21.0
===> Fetching ranch v2.3.0
└─ api-lite─0.3.0 (project app)
   ├─ cowboy─2.20.0 (hex package)
   │  ├─ cowlib─2.21.0 (hex package)
   │  └─ ranch─2.3.0 (hex package)
   ├─ sqlite3─1.1.15 (hex package)
   └─ syslog─1.1.0 (hex package)
```

---

**Build** the microservice using **Rebar3** (and the LFE plugin):

```
$ rebar3 lfe clean
===> Cleaning out api-lite...
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-app.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-helper.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-sup.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-model.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-404dler.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-handler.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite-controller.beam
===> Deleted $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/api-lite/ebin/api-lite.app
$
$ rebar3 lfe compile
===> Verifying dependencies...
===> Compiling c_src/sqlite3_drv.c
===> Linking $HOME/customers-api-proto-lite-lfe-cowboy/_build/default/lib/sqlite3/priv/sqlite3_drv.so
===> Analyzing applications...
===> Compiling sqlite3
===> Compiling cowlib
===> Compiling ranch
===> Compiling cowboy
===> Compiling syslog
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
===> Assembling release 'api-lited'-0.3.0...
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

### Creating a Docker image

**Build** a Docker image for the microservice:

```
$ # Pull the Erlang image first (based on Alpine Linux), if not already there:
$ sudo docker pull erlang:alpine
...
$ # Then build the microservice image:
$ sudo docker build -tcustomersapi/api-lite-lfe .
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

### Running a Docker image

**Run** a Docker image of the microservice, deleting all stopped containers prior to that (if any):

```
$ sudo docker rm `sudo docker ps -aq`; \
  export PORT=8765 && sudo docker run -dp${PORT}:${PORT} --name api-lite-lfe customersapi/api-lite-lfe; echo $?
...
```

### Exploring a Docker image payload

The following is not necessary but might be considered somewhat interesting&mdash;to look into the running container and check out that the microservice's OTP release startup script, compiled BEAMs, configs, logfile, and accompanied SQLite database are at their expected places and in effect:

```
$ sudo docker ps -a
CONTAINER ID   IMAGE                       COMMAND                    CREATED              STATUS              PORTS                                         NAMES
<container_id> customersapi/api-lite-lfe   "_build/default/rel/..."   About a minute ago   Up About a minute   0.0.0.0:8765->8765/tcp, [::]:8765->8765/tcp   api-lite-lfe
$
$ sudo docker exec -it api-lite-lfe sh; echo $?
/var/tmp/api-lite $
/var/tmp/api-lite $ uname -a
Linux <container_id> 7.0.0-43-generic #43-Ubuntu SMP PREEMPT_DYNAMIC Fri Oct 23 13:25:25 UTC 2026 x86_64 Linux
/var/tmp/api-lite $
/var/tmp/api-lite $ cat /etc/os-release /etc/alpine-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.24.4
PRETTY_NAME="Alpine Linux v3.24"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://gitlab.alpinelinux.org/alpine/aports/-/issues"
3.24.4
/var/tmp/api-lite $
/var/tmp/api-lite $ _build/default/rel/api-lited/erts-17.1.1/bin/erl -version
Erlang (SMP,ASYNC_THREADS) (BEAM) emulator version 17.1.1
/var/tmp/api-lite $
/var/tmp/api-lite $ rebar3 -v
rebar 3.27.0 on Erlang/OTP 29 Erts 17.1.1
/var/tmp/api-lite $
/var/tmp/api-lite $ ls -al
total 80
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 19:22 .
drwxrwxrwt    1 root     root          4096 Nov 11 18:30 ..
-rw-------    1 daemon   daemon         124 Nov 11 19:25 .ash_history
drwxr-xr-x    3 daemon   daemon        4096 Nov 11 18:31 .cache
-rw-rw-r--    1 daemon   daemon        1304 Nov 11 18:00 Makefile
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:31 _build
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:30 config
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:31 data
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:30 etc
drwxr-xr-x    2 daemon   daemon        4096 Nov 11 18:50 log
-rw-rw-r--    1 daemon   daemon        1397 Nov 11 18:00 rebar.config
-rw-r--r--    1 daemon   daemon        1191 Nov 11 18:36 rebar.lock
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:30 src
/var/tmp/api-lite $
/var/tmp/api-lite $ ls -al _build/default/rel/api-lited/bin/ _build/default/rel/api-lited/lib/api-lite-0.3.0/ebin/ config/ data/db/ etc/ log/
_build/default/rel/api-lited/bin/:
total 112
drwxr-xr-x    2 daemon   daemon        4096 Nov 11 18:39 .
drwxr-xr-x    6 daemon   daemon        4096 Nov 11 18:39 ..
-rwxr-xr-x    1 daemon   daemon       36171 Nov 11 18:39 api-lited
-rwxr-xr-x    1 daemon   daemon       36171 Nov 11 18:39 api-lited-0.3.0
-rw-r--r--    1 daemon   daemon       14232 Nov 11 18:39 install_upgrade.escript
-rw-r--r--    1 daemon   daemon        7064 Nov 11 18:39 no_dot_erlang.boot
-rw-r--r--    1 daemon   daemon        7578 Nov 11 18:39 nodetool

_build/default/rel/api-lited/lib/api-lite-0.3.0/ebin/:
total 40
drwxr-xr-x    2 daemon   daemon        4096 Nov 11 18:39 .
drwxr-xr-x    3 daemon   daemon        4096 Nov 11 18:39 ..
-rw-r--r--    1 daemon   daemon         803 Nov 11 18:39 api-lite-404dler.beam
-rw-r--r--    1 daemon   daemon        1675 Nov 11 18:39 api-lite-app.beam
-rw-r--r--    1 daemon   daemon        3227 Nov 11 18:39 api-lite-controller.beam
-rw-r--r--    1 daemon   daemon        1576 Nov 11 18:39 api-lite-handler.beam
-rw-r--r--    1 daemon   daemon        1075 Nov 11 18:39 api-lite-helper.beam
-rw-r--r--    1 daemon   daemon        1020 Nov 11 18:39 api-lite-model.beam
-rw-r--r--    1 daemon   daemon         631 Nov 11 18:39 api-lite-sup.beam
-rw-r--r--    1 daemon   daemon         811 Nov 11 18:39 api-lite.app

config/:
total 24
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:30 .
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 19:22 ..
-rw-rw-r--    1 daemon   daemon        2004 Nov 11 18:00 logger.config
-rw-rw-r--    1 daemon   daemon         648 Nov 11 18:00 sys.config

data/db/:
total 40
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:39 .
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:31 ..
-rw-r--r--    1 daemon   daemon       24576 Nov 11 18:39 customers-api-lite.db

etc/:
total 20
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 18:30 .
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 19:22 ..
-rw-rw-r--    1 daemon   daemon         835 Nov 11 18:10 settings.conf

log/:
total 16
drwxr-xr-x    2 daemon   daemon        4096 Nov 11 18:50 .
drwxr-xr-x    1 daemon   daemon        4096 Nov 11 19:22 ..
-rw-r--r--    1 daemon   daemon         189 Nov 11 18:50 customers-api-lite.log
/var/tmp/api-lite $
/var/tmp/api-lite $ netstat -plunt
netstat: showing only processes with your user ID
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:32899           0.0.0.0:*               LISTEN      1/api-lited
tcp        0      0 0.0.0.0:4369            0.0.0.0:*               LISTEN      50/epmd
tcp        0      0 0.0.0.0:8765            0.0.0.0:*               LISTEN      1/api-lited
tcp        0      0 :::4369                 :::*                    LISTEN      50/epmd
/var/tmp/api-lite $
/var/tmp/api-lite $ ps aux
PID   USER     TIME  COMMAND
    1 daemon    0:03 {beam.smp} /var/tmp/api-lite/_build/default/rel/api-lited/bin/api-lited -Bd -C multi_time_warp -- -root /var/tmp/api-lite/_build/default/rel/api-lited -bindir /var/tmp/api-lite/_build/default/rel/api-lited/erts-17.1.1/bin -progname default/rel/api-lited/bin/api-lited -- -home . -- -noshell -noinput -boot /var/tmp/api-lite/_build/default/rel/api-lited/releases/0.3.0/start -mode embedded -boot_var SYSTEM_LIB_DIR /var/tmp/api-lite/_build/default/rel/api-lited/lib -config /var/tmp/api-lite/_build/default/rel/api-lited/releases/0.3.0/sys.config -sname api-lited -setcookie api-lited -- -- foreground --
   50 daemon    0:00 /var/tmp/api-lite/_build/default/rel/api-lited/erts-17.1.1/bin/epmd -daemon
   78 daemon    0:00 [epmd]
   79 daemon    0:00 [epmd]
   83 daemon    0:00 erl_child_setup 1024
  102 daemon    0:00 sh
  161 daemon    0:00 ps aux
/var/tmp/api-lite $
/var/tmp/api-lite $ exit # Or simply <Ctrl-D>.
0
```

To stop a running container of the microservice gracefully at any time, simply issue the following command:

```
$ sudo docker stop api-lite-lfe; echo $?
api-lite-lfe
0
```

## Consuming

The microservice exposes **six REST API endpoints** to web clients. They are all intended to deal with customer entities and/or contact entities that belong to customer profiles. The following table displays their syntax:

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
< HTTP/1.1 201 Created
< allow: PUT, GET, HEAD
< content-length: 32
< content-type: application/json
...
< location: /v1/customers/3
< server: Cowboy
...
{"id":3,"name":"Jamison Palmer"}
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
< HTTP/1.1 201 Created
< allow: PUT
< content-length: 26
< content-type: application/json
...
< location: /v1/customers/3/contacts/phone
< server: Cowboy
...
{"contact":"+12197654320"}
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
< HTTP/1.1 201 Created
< allow: PUT
< content-length: 40
< content-type: application/json
...
< location: /v1/customers/3/contacts/email
< server: Cowboy
...
{"contact":"jamison.palmer@example.com"}
```

3. **List customers**

```
$ curl -v http://localhost:8765/v1/customers
...
> GET /v1/customers HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: PUT, GET, HEAD
< content-length: 136
< content-type: application/json
...
< server: Cowboy
...
[{"id":1,"name":"Jammy Jellyfish"},{"id":2,"name":"Noble Numbat"},{"id":3,"name":"Jamison Palmer"},{"id":4,"name":"Sarah Kitteringham"}]
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/3
...
> GET /v1/customers/3 HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 32
< content-type: application/json
...
< server: Cowboy
...
{"id":3,"name":"Jamison Palmer"}
```

5. **List contacts for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts
...
> GET /v1/customers/3/contacts HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 186
< content-type: application/json
...
< server: Cowboy
...
[{"contact":"+12197654320"},{"contact":"+12197654321"},{"contact":"+12197654322"},{"contact":"jamison.palmer@example.com"},{"contact":"jp@example.com"},{"contact":"jpalmer@example.com"}]
```

6. **List contacts of a given type for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/phone
...
> GET /v1/customers/3/contacts/phone HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 82
< content-type: application/json
...
< server: Cowboy
...
[{"contact":"+12197654320"},{"contact":"+12197654321"},{"contact":"+12197654322"}]
```

Or list **email** contacts:

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/email
...
> GET /v1/customers/3/contacts/email HTTP/1.1
...
< HTTP/1.1 200 OK
< allow: GET, HEAD
< content-length: 105
< content-type: application/json
...
< server: Cowboy
...
[{"contact":"jamison.palmer@example.com"},{"contact":"jpalmer@example.com"},{"contact":"jp@example.com"}]
```

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `logger-debug-enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Ubuntu Server or Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2026-11-09|11:40:00.228356+03:00] [debug] [Customers API Lite]
[2026-11-09|11:40:00.229816+03:00] [debug] [<0.544.0>]
[2026-11-09|11:40:00.231473+03:00] [info] Server started on port 8765
[2026-11-09|11:40:30.045556+03:00] [debug] [PUT]
[2026-11-09|11:40:30.046309+03:00] [debug] [Saturday Sunday]
[2026-11-09|11:40:30.292237+03:00] [debug] [5|Saturday Sunday]
[2026-11-09|11:40:50.405258+03:00] [debug] [PUT]
[2026-11-09|11:40:50.406077+03:00] [debug] customer_id=5
[2026-11-09|11:40:50.406615+03:00] [debug] [Saturday.Sunday@example.com]
[2026-11-09|11:40:50.924434+03:00] [debug] [email|Saturday.Sunday@example.com]
[2026-11-09|11:45:20.511753+03:00] [debug] [GET]
[2026-11-09|11:45:20.512285+03:00] [debug] customer_id=5
[2026-11-09|11:45:20.512887+03:00] [debug] [5|Saturday Sunday]
[2026-11-09|11:45:40.204722+03:00] [debug] [GET]
[2026-11-09|11:45:40.204998+03:00] [debug] customer_id=5 | contact_type=email
[2026-11-09|11:45:40.205507+03:00] [debug] [Saturday.Sunday@example.com]
[2026-11-09|11:50:00.011550+03:00] [info] Server stopped
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Nov 09 11:40:00 <hostname> api-lited[<pid>]: [Customers API Lite]
Nov 09 11:40:00 <hostname> api-lited[<pid>]: [<0.544.0>]
Nov 09 11:40:00 <hostname> api-lited[<pid>]: Server started on port 8765
Nov 09 11:40:30 <hostname> api-lited[<pid>]: [PUT]
Nov 09 11:40:30 <hostname> api-lited[<pid>]: [Saturday Sunday]
Nov 09 11:40:30 <hostname> api-lited[<pid>]: [5|Saturday Sunday]
Nov 09 11:40:50 <hostname> api-lited[<pid>]: [PUT]
Nov 09 11:40:50 <hostname> api-lited[<pid>]: customer_id=5
Nov 09 11:40:50 <hostname> api-lited[<pid>]: [Saturday.Sunday@example.com]
Nov 09 11:40:50 <hostname> api-lited[<pid>]: [email|Saturday.Sunday@example.com]
Nov 09 11:45:20 <hostname> api-lited[<pid>]: [GET]
Nov 09 11:45:20 <hostname> api-lited[<pid>]: customer_id=5
Nov 09 11:45:20 <hostname> api-lited[<pid>]: [5|Saturday Sunday]
Nov 09 11:45:40 <hostname> api-lited[<pid>]: [GET]
Nov 09 11:45:40 <hostname> api-lited[<pid>]: customer_id=5 | contact_type=email
Nov 09 11:45:40 <hostname> api-lited[<pid>]: [Saturday.Sunday@example.com]
Nov 09 11:50:00 <hostname> api-lited[<pid>]: Server stopped
```

Inside the running container logs might be queried also by `tail`ing the `log/customers-api-lite.log` logfile:

```
/var/tmp/api-lite $ tail -f log/customers-api-lite.log
[2026-11-13|09:50:10.423118+00:00] [debug] [Customers API Lite]
[2026-11-13|09:50:10.667378+00:00] [debug] [<0.541.0>]
[2026-11-13|09:50:10.673285+00:00] [info] Server started on port 8765
[2026-11-13|09:50:40.095438+00:00] [debug] [PUT]
[2026-11-13|09:50:40.097485+00:00] [debug] [Saturday Sunday]
[2026-11-13|09:50:40.390855+00:00] [debug] [5|Saturday Sunday]
[2026-11-13|09:55:00.105809+00:00] [debug] [PUT]
[2026-11-13|09:55:00.107057+00:00] [debug] customer_id=5
[2026-11-13|09:55:00.107666+00:00] [debug] [Saturday.Sunday@example.com]
[2026-11-13|09:55:00.345903+00:00] [debug] [email|Saturday.Sunday@example.com]
[2026-11-13|10:00:30.022739+00:00] [debug] [GET]
[2026-11-13|10:00:30.024209+00:00] [debug] customer_id=5
[2026-11-13|10:00:30.026329+00:00] [debug] [5|Saturday Sunday]
[2026-11-13|10:00:50.913836+00:00] [debug] [GET]
[2026-11-13|10:00:50.915073+00:00] [debug] customer_id=5 | contact_type=email
[2026-11-13|10:00:50.919833+00:00] [debug] [Saturday.Sunday@example.com]
[2026-11-13|10:05:10.045338+00:00] [notice] SIGTERM received - shutting down
[2026-11-13|10:05:10.067015+00:00] [info] Server stopped
```

And of course, Docker itself gives the possibility to read log messages by using the corresponding command for that:

```
$ sudo docker logs -f api-lite-lfe
Exec: /var/tmp/api-lite/_build/default/rel/api-lited/erts-17.1.1/bin/erlexec -noinput +Bd -boot /var/tmp/api-lite/_build/default/rel/api-lited/releases/0.3.0/start -mode embedded -boot_var SYSTEM_LIB_DIR /var/tmp/api-lite/_build/default/rel/api-lited/lib -config /var/tmp/api-lite/_build/default/rel/api-lited/releases/0.3.0/sys.config -args_file /var/tmp/api-lite/_build/default/rel/api-lited/releases/0.3.0/vm.args -- foreground
Root: /var/tmp/api-lite/_build/default/rel/api-lited
/var/tmp/api-lite/_build/default/rel/api-lited
[2026-11-13|09:50:10.423118+00:00] [debug] [Customers API Lite]
[2026-11-13|09:50:10.667378+00:00] [debug] [<0.541.0>]
[2026-11-13|09:50:10.673285+00:00] [info] Server started on port 8765
[2026-11-13|09:50:40.095438+00:00] [debug] [PUT]
[2026-11-13|09:50:40.097485+00:00] [debug] [Saturday Sunday]
[2026-11-13|09:50:40.390855+00:00] [debug] [5|Saturday Sunday]
[2026-11-13|09:55:00.105809+00:00] [debug] [PUT]
[2026-11-13|09:55:00.107057+00:00] [debug] customer_id=5
[2026-11-13|09:55:00.107666+00:00] [debug] [Saturday.Sunday@example.com]
[2026-11-13|09:55:00.345903+00:00] [debug] [email|Saturday.Sunday@example.com]
[2026-11-13|10:00:30.022739+00:00] [debug] [GET]
[2026-11-13|10:00:30.024209+00:00] [debug] customer_id=5
[2026-11-13|10:00:30.026329+00:00] [debug] [5|Saturday Sunday]
[2026-11-13|10:00:50.913836+00:00] [debug] [GET]
[2026-11-13|10:00:50.915073+00:00] [debug] customer_id=5 | contact_type=email
[2026-11-13|10:00:50.919833+00:00] [debug] [Saturday.Sunday@example.com]
[2026-11-13|10:05:10.045338+00:00] [notice] SIGTERM received - shutting down
[2026-11-13|10:05:10.067015+00:00] [info] Server stopped
```

### Error handling

When the URI path or request body passed in an incoming request contains inappropriate input, the microservice will respond with the HTTP `400 Bad Request` status code, including a specific response body in JSON representation which may describe a possible cause of underlying client error, like the following:

```
$ curl http://localhost:8765/v1/customers/=qwerty4838=-i-.--089asdf..nj524987
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl http://localhost:8765/v1/customers/3..,,7/contacts
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl http://localhost:8765/v1/customers/--089asdf../contacts/email
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl -XPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"12197654320--089asdf../nj524987"}'
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
```
