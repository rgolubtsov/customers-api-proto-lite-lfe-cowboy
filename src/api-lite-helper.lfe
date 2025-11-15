;
; src/api-lite-helper.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.4
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-helper "The helper module for the daemon."
    (export (-cleanup 1)) ; (s) -> ok
    (import (from logger (debug 1))
            (from syslog (close 1))))

; Helper function. Makes final cleanups, closes streams, etc.
(defun -cleanup (s)
    (debug (port_to_list s))

    ; Closing the system logger.
    ; Calling <syslog.h> closelog();
    (close s)

    'ok
)

; vim:set nu et ts=4 sw=4:
