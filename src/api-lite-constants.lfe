;
; src/api-lite-constants.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.7
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

; (defmodule api-lite-constants "The pseudo-module containing only constants.")

; Helper constants.
(defmacro EXIT-FAILURE _   1) ;    Failing exit status.
(defmacro EXIT-SUCCESS _   0) ; Successful exit status.
(defmacro SLASH        _ "/")
(defmacro COLON        _ ":")
(defmacro O-BRACKET    _ "[")
(defmacro C-BRACKET    _ "]")

; Common notification messages.
(defmacro MSG-SERVER-STARTED _ "Server started on port ")
(defmacro MSG-SERVER-STOPPED _ "Server stopped")

; Common error messages.
(defmacro ERR-PORT-VALID-MUST-BE-POSITIVE-INT _ (++
    "Valid server port must be a positive integer value, in the range "
    "1024 .. 49151. The default value of 8080 will be used instead."))
(defmacro ERR-CANNOT-START-SERVER _
    "FATAL: Cannot start server ")
(defmacro ERR-ADDR-ALREADY-IN-USE _
    "due to address requested already in use. Quitting...")
(defmacro ERR-SERV-UNKNOWN-REASON _
    "for an unknown reason. Quitting...")

; The filename of the daemon settings (as a series of Erlang terms).
(defmacro SETTINGS _ "../../../../etc/settings.conf")

(defmacro MIN-PORT _ 1024 ) ; The minimum port number allowed.
(defmacro MAX-PORT _ 49151) ; The maximum port number allowed.
(defmacro DEF-PORT _ 8080 ) ; The default server port number.

; REST URI path-related constants.
(defmacro REST-VERSION   _ "v1"          )
(defmacro REST-PREFIX    _ "customers"   )
(defmacro REST-CUST-ID   _ "customer_id" )
(defmacro REST-CONTACTS  _ "contacts"    )
(defmacro REST-CONT-TYPE _ "contact_type")
(defmacro REST-CONTEXT   _ (++
    (SLASH) (REST-VERSION) (SLASH) (REST-PREFIX)))

; HTTP response-related constants.
(defmacro MIME-TYPE    [] #"application")
(defmacro MIME-SUBTYPE [] #"json"       )

; vim:set nu et ts=4 sw=4:
