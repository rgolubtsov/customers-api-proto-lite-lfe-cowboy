;
; src/api-lite-handler.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.6
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-handler "The request handler module of the daemon."
    (export (init 2)) ; (req state) -> {ok, Req, State}
    (import (from logger (debug 1))
            (from api-lite-helper (-dbg 3))))

(include-file "api-lite-constants.lfe")

(defun init (req state)
    "The request handler callback. Gets called on each incoming HTTP request.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               with dispatch rules of the `cowboy_router` middleware).

    Returns:
        The `ok` tuple containing a new request object and its state."

    (debug req);

    (let (((cons dbg t) state))
    (let (((cons s cnx) t))

    (let ((method- (maps:get 'method req)))
    (let ((method  (binary:bin_to_list method-)))
    (-dbg dbg s (++ (O-BRACKET) method (C-BRACKET)))))

    (-dbg dbg s (++ (O-BRACKET) (pid_to_list (lists:last cnx)) (C-BRACKET)))));

    `#(ok ,req ,state)
)

; vim:set nu et ts=4 sw=4:
