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
    "The main module of the daemon. (The callback module in Erlang/OTP terms.)"
    (behavior application)
    (export
        (start 2)   ; (-start-type -start-args) -> {ok, pid()}
        (stop  1))) ; (-state) -> ok

(defun start (-start-type -start-args)
    "The microservice entry point callback. Gets called when starting
    the daemon and is to create the supervision tree by starting
    the top level supervisor.

    Args:
        -start-type: The atom `normal` (usually).
        -start-args: A list of start arguments defined in the resource file
                     `api-lite.app.src` in the key `mod`.

    Returns:
        The `ok` tuple containing a Pid of the top level supervisor created
        and the `State` indicator (defaults to an empty list)."

    (api-lite-sup:start-link)
)

(defun stop (-state)
    "The microservice termination callback. Gets called after the daemon
    has been stopped.

    Args:
        -state: A value of the `State` indicator as returned
                from the `start/2` callback.

    Returns:
        The `ok` atom."

    'ok
)

; vim:set nu et ts=4 sw=4:
