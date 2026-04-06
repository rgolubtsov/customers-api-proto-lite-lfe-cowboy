;
; src/api-lite-handler.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.7
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-handler "The request handler module of the daemon."
    (export (init                2)  ; (req state) -> {cowboy_rest, Req, State}
            (allowed_methods     2)  ; (req state) -> {[<methods>], Req, State}
         (content_types_accepted 2)  ; (req state) -> {[{{,,[]},}], Req, State}
         (content_types_provided 2)  ; (req state) -> {[{{,,[]},}], Req, State}
            (from-json           2)  ; (req state) -> {true,        Req, State}
            (to-json             2)) ; (req state) -> {<resp_body>, Req, State}
    (import (from logger (debug 1))
            (from api-lite-helper (-dbg 3))))

(include-file "api-lite-constants.lfe")

(defun init (req state)
    "The REST handler initialization callback.
    Gets called on each incoming HTTP request.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               with dispatch rules of the `cowboy_router` middleware).

    Returns:
        The `cowboy_rest` tuple containing the incoming request object
        and its initial state."

;   (debug req)

    (let (((cons dbg t) state))
    (let (((cons s cnx) t))

    (let ((method- (maps:get 'method req)))
    (let ((method  (binary:bin_to_list method-)))
    (-dbg dbg s (++ (O-BRACKET) method (C-BRACKET)))))))

;   (-dbg dbg s (++ (O-BRACKET) (pid_to_list (lists:last cnx)) (C-BRACKET)))

    `#(cowboy_rest ,req ,state)
)

(defun allowed_methods (req state)
    "The REST handler callback that returns a list of allowed methods.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               from the `init/2` callback).

    Returns:
        A tuple containing a list of allowed methods the daemon accepts
        along with the incoming request object and its initial state."

    `#((,(HTTP-PUT) ,(HTTP-GET) ,(HTTP-HEAD) ,(HTTP-OPTIONS)) ,req ,state)
)

(defun content_types_accepted (req state)
    "The REST handler callback that returns a list of media types
    the daemon accepts.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               from the `init/2` callback).

    Returns:
        A tuple containing a list of media types the daemon accepts
        along with the incoming request object and its initial state."

    `#((#(#(,(MIME-TYPE) ,(MIME-SUBTYPE) ()) from-json)) ,req ,state)
)

(defun from-json (req state)
    "The REST handler callback that expects to get and then processes
    the request  body in JSON representation. Finally, it sends
    the response body in JSON representation.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               from the `content_types_accepted/2` callback).

    Returns:
        The `true` tuple containing the incoming request object
        and its initial state."

    #|
     | NOTE: The `created` tuple is for `POST` requests only,
     |       but they are not allowed. :-) For `PUT` requests
     |       simply return `true`.
     | `#(#(created ,(characters_to_binary (REST-CONTEXT))) ,req ,state)
     |#
    `#(true ,req ,state)
)

(defun content_types_provided (req state)
    "The REST handler callback that returns a list of media types
    the daemon provides.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               from the `init/2` callback).

    Returns:
        A tuple containing a list of media types the daemon provides
        along with the incoming request object and its initial state."

    `#((#(#(,(MIME-TYPE) ,(MIME-SUBTYPE) ()) to-json)) ,req ,state)
)

(defun to-json (req state)
    "The REST handler callback that returns the response body
    in JSON representation.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               from the `content_types_provided/2` callback).

    Returns:
        A tuple containing the response body in JSON representation
        along with the incoming request object and its initial state."

    (-list-customers req state)

    `#(,(json:encode `()) ,req ,state)
)

(defun -list-customers (req state)
    "The `GET /v1/customers` endpoint.

    Retrieves from the database and lists all customer profiles.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the request (arbitrary data passed
               from the `to-json/2` callback).
    Returns:
        TODO: Describe the return value."

    (let (((cons dbg t) state))
    (let (((cons s cnx) t))

    (-dbg dbg s (++ (O-BRACKET) (pid_to_list (lists:last cnx)) (C-BRACKET)))))
)

; vim:set nu et ts=4 sw=4:
