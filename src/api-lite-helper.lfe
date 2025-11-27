;
; src/api-lite-helper.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.5
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-helper "The helper module for the daemon."
    (export (-get-settings         0)  ; ( ) -> [{...}, ...]
            (-is-debug-log-enabled 1)  ; (settings) -> true | false
            (-get-server-port      1)  ; (settings) -> pos_integer()
            (-dbg                  3)  ; (dbg s message) -> ok
            (-cleanup              1)) ; (state) -> ok
    (import (from logger (debug 1)
                         (error 1))
            (from syslog (log   3)
                         (close 1))))

(include-file "api-lite-constants.lfe")

; Helper function. Used to get the daemon settings.
(defun -get-settings ()
    (let ((`#(ok ,settings) (file:consult (SETTINGS)))) settings)
)

; Helper function. Identifies whether debug logging is enabled
; by retrieving the corresponding setting from daemon settings.
(defun -is-debug-log-enabled (settings)
    (let ((dbg (lists:keyfind 'logger-debug-enabled 1 settings)))

    (if (is_boolean dbg) dbg (element 2 dbg)))
)

; Helper function. Retrieves the port number used to run the Cowboy web server,
; from daemon settings.
(defun -get-server-port (settings)
    (let ((server-port- (lists:keyfind 'server-port 1 settings)))
    (let ((server-port
        (if (not (is_boolean server-port-)) (element 2 server-port-) 0)))

    (cond
        ((/= server-port 0)
            (cond
                ((and (>= server-port (MIN-PORT)) (=< server-port (MAX-PORT)))
                    server-port)
                (else
                    (error (ERR-PORT-VALID-MUST-BE-POSITIVE-INT)) (DEF-PORT))
            ))
        (else
            (error (ERR-PORT-VALID-MUST-BE-POSITIVE-INT)) (DEF-PORT))
    )))
)

; Helper function. Used to log messages for debugging aims in a free form.
(defun -dbg (dbg s message)
    (cond (dbg
        (       debug message)
        (log s 'debug message)
    ))

    'ok
)

; Helper function. Makes final cleanups, closes streams, etc.
(defun -cleanup (state)
    (let (((cons cnx s) state))

    (sqlite3:close cnx)

    ; Closing the system logger.
    ; Calling <syslog.h> closelog();
    (close (lists:last s)))

    'ok
)

; vim:set nu et ts=4 sw=4:
