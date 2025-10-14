;
; src/api-lite-app.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.1
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-app
    (behavior application)
    (export (start 2) (stop 1)))

(defun start (-start-type, -start-args)
    (api-lite-sup:start-link)
)

(defun stop (-state)
    'ok
)

; vim:set nu et ts=4 sw=4:
