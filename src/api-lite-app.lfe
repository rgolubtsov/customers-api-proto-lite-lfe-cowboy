;
; src/api-lite-app.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.7
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-app
    "The main module of the daemon. (The callback module in Erlang/OTP terms.)"
    (behavior application)
    (export
        (start     2)  ; (-start-type -start-args) -> {ok, pid(), State}
        (prep_stop 1)  ; (-state) -> ok
        (stop      1)) ; (-state) -> ok
    (import (from logger (error 1)
                         (info  1))
            (from syslog (open  3)
                         (log   3))
            (from sqlite3 (open 2))
            (from cowboy_router (compile     1))
            (from cowboy        (start_clear 3))
            (from api-lite-helper (-get-settings         0)
                                  (-is-debug-log-enabled 1)
                                  (-get-server-port      1)
                                  (-dbg                  3)
                                  (-cleanup              1))))

(include-file "api-lite-constants.lfe")

(defun start (-start-type -start-args)
    "The microservice entry point callback. Gets called when starting
    the daemon and is to create the supervision tree by starting
    the top level supervisor.

    Args:
        -start-type: The atom `normal` (usually).
        -start-args: A list of start arguments defined in the resource file
                     `api-lite.app.src` in the key `mod`.

    Returns:
        The `ok` tuple containing a Pid of the top level supervisor created
        and the `State` indicator (defaults to an empty list)."

    (let ((daemon-exec
          (++ (atom_to_list (element 2 (application:get_application))) "d")))

    ; Opening the system logger.
    ; Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
    (syslog:start) (let ((`#(ok ,s) (open daemon-exec `(cons pid) 'daemon)))

    ; Getting the daemon settings.
    (let ((settings (-get-settings)))

    ; Identifying whether debug logging is enabled.
    (let ((dbg (-is-debug-log-enabled settings)))

    (let ((daemon-name (element 2 (lists:keyfind 'daemon-name 1 settings))))
    (-dbg dbg s (++ (O-BRACKET) daemon-name (C-BRACKET))))

    ; Getting the SQLite database path.
    (let ((database-path
          (element 2 (lists:keyfind 'sqlite-database-path 1 settings))))

    ; Connecting to the database.
    (let ((cnx- (open 'anonymous (list `#(file ,database-path)))))
    (let ((cnx  (element 2 cnx-)))
    (-dbg dbg s (++ (O-BRACKET) (pid_to_list cnx) (C-BRACKET)))

    ; Getting the port number used to run the Cowboy web server.
    (let ((server-port (-get-server-port settings)))

    ; Starting up the Cowboy web server.
    (application:ensure_all_started 'cowboy)

    ; Compiling routes to allow Cowboy to dispatch them:
    ; /v1/customers
    ; /v1/customers/contacts
    ; /v1/customers/:customer_id
    ; /v1/customers/:customer_id/contacts
    ; /v1/customers/:customer_id/contacts/:contact_type
    (let ((dispatch (compile `(#(_ (
        #(    ,(REST-CONTEXT) api-lite-handler (,dbg ,s ,cnx))
        #(,(++ (REST-CONTEXT) (SLASH)          (REST-CONTACTS))
                              api-lite-handler (,dbg ,s ,cnx))
        #(,(++ (REST-CONTEXT) (SLASH)  (COLON) (REST-CUST-ID))
                              api-lite-handler (,dbg ,s ,cnx))
        #(,(++ (REST-CONTEXT) (SLASH)  (COLON) (REST-CUST-ID)
                              (SLASH)          (REST-CONTACTS))
                              api-lite-handler (,dbg ,s ,cnx))
        #(,(++ (REST-CONTEXT) (SLASH)  (COLON) (REST-CUST-ID)
                              (SLASH)          (REST-CONTACTS)
                              (SLASH)  (COLON) (REST-CONT-TYPE))
                              api-lite-handler (,dbg ,s ,cnx))
    ))))))
    (let ((status (start_clear 'api-lite-listener
        `(#(port ,server-port))
        `#M(env #M(dispatch ,dispatch))
    )))

    (cond
        ((== (element 1 status) 'error)
            (if (== (element 2 status) 'eaddrinuse)
                (error (++ (ERR-CANNOT-START-SERVER)(ERR-ADDR-ALREADY-IN-USE)))
                (error (++ (ERR-CANNOT-START-SERVER)(ERR-SERV-UNKNOWN-REASON)))
            ) (init:stop (EXIT-FAILURE)))
        ((== (element 1 status) 'ok)
            (let ((server-port- (integer_to_list  server-port)))
            (       info (++ (MSG-SERVER-STARTED) server-port-))
            (log s 'info (++ (MSG-SERVER-STARTED) server-port-))))
    ))))

    (let ((`#(ok ,pid) (api-lite-sup:start-link)))

    `#(ok ,pid (,cnx ,s)))))))))) ; <== SQLite DB "connection" + Syslog handle
                                  ;     will be returned as the `State` value.
)

(defun prep_stop (-state)
    "The microservice preparing-to-termination callback. Gets called just
    before the daemon is about to be stopped.

    Args:
        -state: A value of the `State` indicator as returned
                from the `start/2` callback.

    Returns:
        The `ok` atom."

    (let ((s (lists:last -state)))

    (       info (MSG-SERVER-STOPPED))
    (log s 'info (MSG-SERVER-STOPPED)))

    (-cleanup -state)

    'ok
)

(defun stop (-state)
    "The microservice termination callback. Gets called after the daemon
    has been stopped.

    Args:
        -state: A value of the `State` indicator as returned
                from the `prep_stop/1` callback.

    Returns:
        The `ok` atom."

    'ok
)

; vim:set nu et ts=4 sw=4:
