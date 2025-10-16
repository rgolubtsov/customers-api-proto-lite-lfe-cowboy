;
; src/api-lite-sup.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.1
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-sup
    "The supervisor module of the daemon.
    (A top level supervisor in Erlang/OTP terms.)"
    (behavior supervisor)
    (export (start-link 0) (init 1)))

(defun start-link()
    "Creates a supervisor process as part of a supervision tree.

    Returns:
        The `ok` tuple containing a Pid of a supervisor created."

    (supervisor:start_link `#(local ,(MODULE)) (MODULE) ())
)

(defun init (_)
    "The callback function of a supervisor process.
    Gets called just after a supervisor is started.

    Returns:
        The `ok` tuple containing configuration for a supervisor
        and child processes specifications."

    (let ((sup-flags `#M(
        strategy  one_for_all
        intensity 0
        period    1
    )))

    (let ((child-specs ()))

    `#(ok #(
        ,sup-flags
        ,child-specs
    ))))
)

; vim:set nu et ts=4 sw=4:
