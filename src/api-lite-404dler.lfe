;
; src/api-lite-404dler.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.17
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-404dler
    "The request handler module of the daemon that is dedicated
    to handle solely requests against undefined routes."
    (export (init 2)) ; (req state) -> {ok, Req, State}
    (import (from cowboy_req (method 1)
                             (reply  3)
                      (set_resp_body 2))
            (from logger     (debug  1))
            (from api-lite-helper (-dbg 3))))

(include-file "api-lite-constants.lfe")

(defun init (req state)
    "The handler initialization callback. Gets called on each incoming
    HTTP request that does not match any of predefined routes.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the handler (arbitrary data passed
               with dispatch rules of the `cowboy_router` middleware).

    Returns:
        The `ok` tuple containing the modified incoming request object
        and an initial state of the handler."

    (let (((cons dbg (cons s _)) state))
    (-dbg dbg s (++ (O-BRACKET) (binary:bin_to_list(method req)) (C-BRACKET))))
    (debug req)

    `#(ok ,(reply (HTTP-404)
        `#M(,(CONTENT-TYPE) ,(++ (MIME-TYPE-S) (SLASH) (MIME-STYPE-S)))
    (set_resp_body (json:encode
        `#M(error ,(ERR-REQ-NOT-FOUND-1))
    ) req)) ,state)
)

; vim:set nu et ts=4 sw=4:
