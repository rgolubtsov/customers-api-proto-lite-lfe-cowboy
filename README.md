# Customers API Lite microservice prototype :small_blue_diamond: <img src="https://blog.lfe.io/assets/images/posts/LispFlavoredErlang-medium-square.png" style="border:0;width:32px" alt="LFE (Lisp Flavoured Erlang)" />

**A daemon written in LFE (Lisp Flavoured Erlang), designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[LFE](https://lfe.io "Lisp Flavoured Erlang")** port of the earlier developed **Customers API Lite microservice prototype**, written in Clojure using **[http-kit](https://http-kit.github.io "Simple, high-performance event-driven HTTP client+server for Clojure")** web client/server library, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-clojure-httpkit/blob/main/README.md)** almost as is, without any principal modifications or adjustment.

This repo is dedicated to develop a microservice that implements a prototype of REST API service for ordinary Customers operations like adding/retrieving a Customer to/from the database, also doing the same ops with Contacts (phone or email) which belong to a Customer account.

The data scheme chosen is very simplified and consisted of only three SQL database tables, but that's quite sufficient because the service operates on only two entities: a **Customer** and a **Contact** (phone or email). And a set of these operations is limited to the following ones:

* Create a new customer (put customer data to the database).
* Create a new contact for a given customer (put a contact regarding a given customer to the database).
* Retrieve from the database and list all customer profiles.
* Retrieve profile details for a given customer from the database.
* Retrieve from the database and list all contacts associated with a given customer.
* Retrieve from the database and list all contacts of a given type associated with a given customer.

As it is clearly seen, there are no *mutating*, usually expected operations like *update* or *delete* an entity and that's made intentionally.

The microservice incorporates the **[SQLite](https://sqlite.org "A small, fast, self-contained, high-reliability, full-featured, SQL database engine")** database as its persistent store. It is located in the `data/db/` directory as an XZ-compressed database file with minimal initial data &mdash; actually having two Customers and by six Contacts for each Customer. The database file is automatically decompressed during build process of the microservice and ready to use as is even when containerized with Docker.

Generally speaking, this project might be explored as a PoC (proof of concept) on how to amalgamate LFE/OTP REST API service backed by SQLite database, running standalone as a conventional daemon in host or VM environment, or in a containerized form as usually widely adopted nowadays.

Surely, one may consider this project to be suitable for a wide variety of applied areas and may use this prototype as: (1) a template for building similar microservices, (2) for evolving it to make something more universal, or (3) to simply explore it and take out some snippets and techniques from it for *educational purposes*, etc.

---

## Table of Contents

* **[Building](#building)**
* **[Running](#running)**
* **[Consuming](#consuming)**

## Building

The microservice might be built and run under **Arch Linux**. &mdash; First install the necessary dependencies (`rebar3`, `make`, `docker`):

```
$ sudo pacman -Syu rebar3 make docker
...
```

---

Then pull and install all the necessary plugins and third-party libraries:

```
$ rebar3 tree
===> Fetching rebar3_lfe v0.4.11
===> Fetching lfe v2.2.0
===> Analyzing applications...
===> Compiling lfe
===> Compiling rebar3_lfe
src/cl.lfe:472: Warning: redefining core function car/1
src/cl.lfe:479: Warning: redefining core function cdr/1
===> Verifying dependencies...
===> Fetching cowboy v2.14.2
===> Fetching cowlib v2.16.0
===> Fetching ranch v2.2.0
   └─ cowboy─2.14.2 (hex package)
      ├─ cowlib─2.16.0 (hex package)
      └─ ranch─2.2.0 (hex package)
```

**TBD** :cd:

## Running

**TBD** :cd:

## Consuming

**TBD** :cd:

---

**WIP** :dvd:
