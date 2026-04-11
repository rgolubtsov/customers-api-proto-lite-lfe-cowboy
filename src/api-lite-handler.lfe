;
; src/api-lite-handler.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.8
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
            (from sqlite3 (sql_exec 2)
                          (sql_exec 3))
            (from api-lite-helper (-dbg 3)))
    (module-alias (api-lite-model model)))

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
        and its new (or modified) state."

    (let (((cons dbg (cons s _)) state))

    (let ((method- (maps:get 'method req)))
    (let ((method  (binary:bin_to_list method-)))
    (-dbg dbg s (++ (O-BRACKET) method (C-BRACKET)))

    (let ((state- (++ state method)))

    `#(cowboy_rest ,req ,state-)))))
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

    (let (((cons dbg (cons s (cons cnx (cons route method)))) state))

    (-dbg dbg s (++ (O-BRACKET) (atom_to_list route) (C-BRACKET)))
    (-dbg dbg s (++ (O-BRACKET) method (C-BRACKET)))

    (case route
        ('r-put-get-cust (add-customer req dbg s cnx))
        ('r-put-cont     (add-contact  req dbg s cnx))
    ))

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

    (let (((cons dbg (cons s (cons cnx (cons route method)))) state))

    (-dbg dbg s (++ (O-BRACKET) (atom_to_list route) (C-BRACKET)))
    (-dbg dbg s (++ (O-BRACKET) method (C-BRACKET)))

    (case route
        ('r-put-get-cust  (list-customers        req dbg s cnx))
        ('r-get-cust      (get-customer          req dbg s cnx))
        ('r-get-cont      (list-contacts         req dbg s cnx))
        ('r-get-cont-type (list-contacts-by-type req dbg s cnx))
    ))

    `#(,(json:encode `()) ,req ,state)
)

; REST API endpoints ----------------------------------------------------------

(defun add-customer (req dbg s cnx)
    "The `PUT /v1/customers` endpoint.

    Creates a new customer (puts customer data to the database).

    The request body is defined exactly in the form
    as `{\"name\":\"{customer_name}\"}`. It should be passed
    with the accompanied request header `content-type` just like the following:

    ```
    -H 'content-type: application/json' -d '{\"name\":\"{customer_name}\"}'
    ```

    `{customer_name}` is a name assigned to a newly created customer.

    Args:
        req: A map representing the incoming HTTP request object.
        dbg: The debug logging enabler.
        s:   The Unix system logger handle (a Port).
        cnx: The database connection (a Pid).

    Returns:
        The `ok` atom."

    (-dbg dbg s (++ (O-BRACKET) (pid_to_list cnx) (C-BRACKET))) (debug req)

    'ok
)

(defun add-contact (req dbg s cnx)
    "The `PUT /v1/customers/contacts` endpoint.

    Creates a new contact for a given customer (puts a contact
    regarding a given customer to the database).

    The request body is defined exactly in the form
    as `{\"customer_id\":\"{customer_id}\",\"contact\":\"{customer_contact}\"}`
    It should be passed with the accompanied request header `content-type`
    just like the following:

    ```
    -H 'content-type: application/json' -d '{\"customer_id\":\"{customer_id}\",\"contact\":\"{customer_contact}\"}'
    ```

    `{customer_id}` is the customer ID used to associate a newly created
    contact with this customer.

    Args:
        req: A map representing the incoming HTTP request object.
        dbg: The debug logging enabler.
        s:   The Unix system logger handle (a Port).
        cnx: The database connection (a Pid).

    Returns:
        The `ok` atom."

    (-dbg dbg s (++ (O-BRACKET) (pid_to_list cnx) (C-BRACKET))) (debug req)

    'ok
)

(defun list-customers (req dbg s cnx)
    "The `GET /v1/customers` endpoint.

    Retrieves from the database and lists all customer profiles.

    Args:
        req: A map representing the incoming HTTP request object.
        dbg: The debug logging enabler.
        s:   The Unix system logger handle (a Port).
        cnx: The database connection (a Pid).

    Returns:
        The `ok` atom."

    (debug req)

    ; Retrieving all customer profiles from the database.
    (let ((customers (sql_exec cnx (model:SQL-GET-ALL-CUSTOMERS))))

    (debug customers))

    'ok
)

(defun get-customer (req dbg s cnx)
    "The `GET /v1/customers/{customer_id}` endpoint.

    Retrieves profile details for a given customer from the database.

    Args:
        req: A map representing the incoming HTTP request object.
        dbg: The debug logging enabler.
        s:   The Unix system logger handle (a Port).
        cnx: The database connection (a Pid).

    Returns:
        The `ok` atom."

    (debug req)

    (let ((cust-id 2)) ; <== TODO: Replace with the actual one.

    ; Retrieving profile details for a given customer from the database.
    (let ((customer (sql_exec cnx (model:SQL-GET-CUSTOMER-BY-ID) `(,cust-id))))

    (debug customer)))

    'ok
)

(defun list-contacts (req dbg s cnx)
    "The `GET /v1/customers/{customer_id}/contacts` endpoint.

    Retrieves from the database and lists all contacts
    associated with a given customer.

    Args:
        req: A map representing the incoming HTTP request object.
        dbg: The debug logging enabler.
        s:   The Unix system logger handle (a Port).
        cnx: The database connection (a Pid).

    Returns:
        The `ok` atom."

    (debug req)

    (let ((cust-id 2)) ; <== TODO: Replace with the actual one.

    ; Retrieving all contacts associated with a given customer
    ; from the database.
    (let ((contacts (sql_exec cnx (model:SQL-GET-ALL-CONTACTS) `(
        ,cust-id ; <== For retrieving phones.
        ,cust-id ; <== For retrieving emails.
    ))))

    (debug contacts)))

    'ok
)

(defun list-contacts-by-type (req dbg s cnx)
    "The `GET /v1/customers/{customer_id}/contacts/{contact_type}` endpoint.

    Retrieves from the database and lists all contacts of a given type
    associated with a given customer.

    Args:
        req: A map representing the incoming HTTP request object.
        dbg: The debug logging enabler.
        s:   The Unix system logger handle (a Port).
        cnx: The database connection (a Pid).

    Returns:
        The `ok` atom."

    (debug req)

    (let ((cust-id 2)) ; <== TODO: Replace with the actual one.

    (let (((cons sql-query _) (model:SQL-GET-CONTACTS-BY-TYPE))) ; <== TODO:...

    ; Retrieving all contacts of a given type associated with a given customer
    ; from the database.
    (let ((contacts (sql_exec cnx sql-query `(,cust-id))))

    (debug contacts))))

    'ok
)

; vim:set nu et ts=4 sw=4:
