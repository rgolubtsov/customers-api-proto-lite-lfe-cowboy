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

(defmodule api-lite-helper "The helper module for the daemon.")

; Helper function. Makes final cleanups, closes streams, etc.
(defun -cleanup ()
    ; TODO: Make final cleanups...
    'ok
)

; vim:set nu et ts=4 sw=4:
