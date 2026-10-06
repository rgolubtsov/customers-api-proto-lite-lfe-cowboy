;
; src/api-lite-controller.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.10
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-controller "The controller module of the daemon."
    (export ( add-customer          4)  ; (req dbg s cnx) -> ok
            ( add-contact           4)  ; (req dbg s cnx) -> ok
            (list-customers         4)  ; (req dbg s cnx) -> [#{=>,=>}, ...]
            ( get-customer          4)  ; (req dbg s cnx) ->  #{=>,=>}
            (list-contacts          4)  ; (req dbg s cnx) ->  #{}
            (list-contacts-by-type  4)) ; (req dbg s cnx) ->  #{}
    (import (from logger  (debug    1))
            (from sqlite3 (sql_exec 2)
                          (sql_exec 3))
            (from api-lite-helper (-dbg 3)))
    (module-alias (api-lite-model m)))

(include-file "api-lite-constants.lfe")

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
        A list of all customer profiles as individual maps: `[#{=>,=>}, ...]`."

    ; Retrieving all customer profiles from the database.
    (let ((customers (-entity-prep (sql_exec cnx (m:SQL-GET-ALL-CUSTOMERS)))))

    (let (((cons customer0 _) customers))
    (-dbg dbg s (++ (O-BRACKET) (integer_to_list (mref customer0 'id  ))
                    (V-BAR)     ( binary_to_list (mref customer0 'name))
                    (C-BRACKET))))

    customers)
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
        A map containing profile details for a given customer,
        or an empty map if no such customer exists."

    (let ((customer-id (mref (maps:get 'bindings req) 'customer_id)))
    (-dbg dbg s (++ (REST-CUST-ID) (EQUALS) customer-id))

    ; Retrieving profile details for a given customer from the database.
    (let ((customer- (sql_exec cnx (m:SQL-GET-CUSTOMER-BY-ID)`(,customer-id))))

    (cond
        ((== (length (proplists:get_value 'rows customer-)) 0)
            `#M())
        (else
            (let (((cons customer _) (-entity-prep customer-)))

            (-dbg dbg s (++ (O-BRACKET) (integer_to_list (mref customer 'id  ))
                            (V-BAR)     ( binary_to_list (mref customer 'name))
                            (C-BRACKET)))

            customer))
    )))
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
        An empty map."

    (let ((customer-id 2)) ; <== TODO: Replace with the actual one.

    ; Retrieving all contacts associated with a given customer
    ; from the database.
    (let ((contacts (sql_exec cnx (m:SQL-GET-ALL-CONTACTS) `(
        ,customer-id ; <== For retrieving phones.
        ,customer-id ; <== For retrieving emails.
    ))))
    (debug contacts)))

    `#M()
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
        An empty map."

    (let ((customer-id 2)) ; <== TODO: Replace with the actual one.

    (let (((cons sql-query _) (m:SQL-GET-CONTACTS-BY-TYPE))) ; <== TODO: -"- .

    ; Retrieving all contacts of a given type associated with a given customer
    ; from the database.
    (let ((contacts (sql_exec cnx sql-query `(,customer-id))))
    (debug contacts))))

    `#M()
)

; -----------------------------------------------------------------------------

; Helper function. Used to preprocess an entity structure that is taken
;                  from the database, to make it suitable for JSON marshalling.
(defun -entity-prep (entity)
    (let (((cons cols _) (proplists:get_all_values 'columns entity)))
    (let (((cons rows _) (proplists:get_all_values 'rows    entity)))

    (let (((cons id (cons name _)) cols))

    (lists:map (lambda (row) `#M(
        ,(list_to_atom id  ) ,(tref row 1)
        ,(list_to_atom name) ,(tref row 2)
    )) rows))))
)

; vim:set nu et ts=4 sw=4:
