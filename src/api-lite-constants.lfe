;
; src/api-lite-constants.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.5
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

; (defmodule api-lite-constants "The pseudo-module containing only constants.")

; Helper constants.
(defmacro B-O-O-O-M _ 000)
(defmacro O-BRACKET _ "[")
(defmacro C-BRACKET _ "]")

; The filename of the daemon settings (as a series of Erlang terms).
(defmacro SETTINGS _ "../../../../etc/settings.conf")

; vim:set nu et ts=4 sw=4:
