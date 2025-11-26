;
; src/api-lite-handler.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.0
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-handler "The request handler module of the daemon."
    (export (init 2)) ; (req state) -> {ok, Req, State}
    (import (from logger (debug 1))))

(defun init (req state)
    "The request handler callback. Gets called on each incoming HTTP request.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request.

    Returns:
        The `ok` tuple containing a new request object and its state."

    (debug req)

    `#(ok ,req ,state)
)

; vim:set nu et ts=4 sw=4:
