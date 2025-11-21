;
; src/api-lite-helper.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.5
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
            (-dbg                  3)  ; (dbg s message) -> ok
            (-cleanup              1)) ; (s) -> ok
    (import (from logger (debug 1))
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

; Helper function. Used to log messages for debugging aims in a free form.
(defun -dbg (dbg s message)
    (cond (dbg
        (       debug message)
        (log s 'debug message)
    ))

    'ok
)

; Helper function. Makes final cleanups, closes streams, etc.
(defun -cleanup (s)
    ; Closing the system logger.
    ; Calling <syslog.h> closelog();
    (close s)

    'ok
)

; vim:set nu et ts=4 sw=4:
