#
# Dockerfile
# =============================================================================
# Customers API Lite microservice prototype (LFE/OTP port). Version 0.3.0
# =============================================================================
# A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
# to be run as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# === Stage 1: Install dependencies ===========================================
FROM       erlang:alpine
RUN        ["apk", "add", "make"      ]
RUN        ["apk", "add", "gcc"       ]
RUN        ["apk", "add", "musl-dev"  ]
RUN        ["apk", "add", "sqlite-dev"]

# === Stage 2: Build the microservice =========================================
USER       daemon
WORKDIR    var/tmp
COPY       src          api-lite/src/
COPY       etc          api-lite/etc/
COPY       config       api-lite/config/
COPY       data/db      api-lite/data/db/
COPY       Makefile     api-lite/
COPY       rebar.config api-lite/
WORKDIR    api-lite
USER       root
RUN        ["chown", "-R", "daemon:daemon", "."]
USER       daemon
           # Forcing Rebar3 to create its ".cache/rebar3/hex/" in the CWD
           # and not in "/sbin/" as by default.
ENV        HOME=.
RUN        ["rebar3", "tree"]
RUN        ["make",   "all" ]

# === Stage 3: Run the microservice ===========================================
ENTRYPOINT ["_build/default/rel/api-lited/bin/api-lited", "foreground"]

# vim:set nu ts=4 sw=4:
