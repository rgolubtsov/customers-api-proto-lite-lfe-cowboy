;
; src/api-lite-constants.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.6
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

; Common error messages.
(defmacro ERR-PORT-VALID-MUST-BE-POSITIVE-INT _ (++
    "Valid server port must be a positive integer value, in the range "
    "1024 .. 49151. The default value of 8080 will be used instead."))

; The filename of the daemon settings (as a series of Erlang terms).
(defmacro SETTINGS _ "../../../../etc/settings.conf")

(defmacro MIN-PORT _ 1024 ) ; The minimum port number allowed.
(defmacro MAX-PORT _ 49151) ; The maximum port number allowed.
(defmacro DEF-PORT _ 8080 ) ; The default server port number.

; vim:set nu et ts=4 sw=4:
