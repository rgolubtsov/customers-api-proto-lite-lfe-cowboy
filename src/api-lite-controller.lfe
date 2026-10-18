;
; src/api-lite-controller.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.15
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-controller "The controller module of the daemon."
    (export ( add-customer          4)  ; (req       dbg s cnx) -> ok
            ( add-contact           4)  ; (req       dbg s cnx) -> ok
            (list-customers         5)  ; (req state dbg s cnx) -> [#{=>,=>}, ...] | {stop, Req, State}
            ( get-customer          5)  ; (req state dbg s cnx) ->  #{=>,=>}       | {stop, Req, State}
            (list-contacts          5)  ; (req state dbg s cnx) -> [#{=>},    ...] | {stop, Req, State}
            (list-contacts-by-type  5)) ; (req state dbg s cnx) ->  #{}
    (import (from logger  (debug    1))
            (from string  (casefold 1))
            (from sqlite3 (sql_exec 2)
                          (sql_exec 3))
            (from cowboy_req (reply 2)
                     (set_resp_body 2)
                           (binding 3))
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

(defun list-customers (req state dbg s cnx)
    "The `GET /v1/customers` endpoint.

    Retrieves from the database and lists all customer profiles.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the handler (arbitrary data passed
               from the `to-json/2` callback).
        dbg:   The debug logging enabler.
        s:     The Unix system logger handle (a Port).
        cnx:   The database connection (a Pid).

    Returns:
        A list of all customer profiles as individual maps: `[#{=>,=>}, ...]`,
        or - if no customers exist yet - the `stop` tuple containing
        the modified incoming request object and an initial state
        of the handler."

    (try (progn
        ; Retrieving all customer profiles from the database.
        (let ((customers
            (-entity-prep (sql_exec cnx (m:SQL-GET-ALL-CUSTOMERS)) 'true)))

        (cond
            ((== (length customers) 0)
                (-http-404-resp (ERR-REQ-NOT-FOUND-2) req state))
            (else
                (let (((cons customer0 _) customers))
                (-dbg dbg s (++ (O-BRACKET)
                                (integer_to_list (mref customer0 'id  ))(V-BAR)
                                ( binary_to_list (mref customer0 'name))
                                (C-BRACKET))))

                customers)
        )))
    (catch (`#(error ,_ ,_) (-http-500-resp req state))))
)

(defun get-customer (req state dbg s cnx)
    "The `GET /v1/customers/{customer_id}` endpoint.

    Retrieves profile details for a given customer from the database.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the handler (arbitrary data passed
               from the `to-json/2` callback).
        dbg:   The debug logging enabler.
        s:     The Unix system logger handle (a Port).
        cnx:   The database connection (a Pid).

    Returns:
        A map containing profile details for a given customer,
        or - if no such customer exists - the `stop` tuple containing
        the modified incoming request object and an initial state
        of the handler."

    (let ((customer-id (binding 'customer_id req 1)))
    (-dbg dbg s (++ (REST-CUST-ID) (EQUALS) customer-id))

    (try (progn
        ; Retrieving profile details for a given customer from the database.
        (let ((customer-
            (sql_exec cnx (m:SQL-GET-CUSTOMER-BY-ID) `(,customer-id))))

        (cond
            ((== (length (proplists:get_value 'rows customer-)) 0)
                (-http-404-resp (ERR-REQ-NOT-FOUND-3) req state))
            (else
                (let (((cons customer _) (-entity-prep customer- 'true)))

                (-dbg dbg s (++ (O-BRACKET)
                                (integer_to_list (mref customer 'id  )) (V-BAR)
                                ( binary_to_list (mref customer 'name))
                                (C-BRACKET)))

                customer))
        )))
    (catch (`#(error ,_ ,_) (-http-500-resp req state)))))
)

(defun list-contacts (req state dbg s cnx)
    "The `GET /v1/customers/{customer_id}/contacts` endpoint.

    Retrieves from the database and lists all contacts
    associated with a given customer.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the handler (arbitrary data passed
               from the `to-json/2` callback).
        dbg:   The debug logging enabler.
        s:     The Unix system logger handle (a Port).
        cnx:   The database connection (a Pid).

    Returns:
        A list of all contacts associated with a given customer as individual
        maps: `[#{=>}, ...]`, or - if no contacts belonging to a given customer
        exist or no such customer exists - the `stop` tuple containing
        the modified incoming request object and an initial state
        of the handler."

    (let ((customer-id (binding 'customer_id req 1)))
    (-dbg dbg s (++ (REST-CUST-ID) (EQUALS) customer-id))

    (try (progn
        ; Retrieving all contacts associated with a given customer
        ; from the database.
        (let ((contacts (-entity-prep (sql_exec cnx (m:SQL-GET-ALL-CONTACTS) `(
            ,customer-id ; <== For retrieving phones.
            ,customer-id ; <== For retrieving emails.
        )) 'false)))

        (cond
            ((== (length contacts) 0)
                (-http-404-resp (ERR-REQ-NOT-FOUND-4) req state))
            (else
                (let (((cons contact0 _) contacts))
                (-dbg dbg s (++ (O-BRACKET)
                                (binary_to_list (mref contact0 'contact))
                                (C-BRACKET))))

                contacts)
        )))
    (catch (`#(error ,_ ,_) (-http-500-resp req state)))))
)

(defun list-contacts-by-type (req state dbg s cnx)
    "The `GET /v1/customers/{customer_id}/contacts/{contact_type}` endpoint.

    Retrieves from the database and lists all contacts of a given type
    associated with a given customer.

    Args:
        req:   A map representing the incoming HTTP request object.
        state: An initial state of the handler (arbitrary data passed
               from the `to-json/2` callback).
        dbg:   The debug logging enabler.
        s:     The Unix system logger handle (a Port).
        cnx:   The database connection (a Pid).

    Returns:
        A list of all contacts of a given type associated with a given customer
        as individual maps: `[#{=>}, ...]`, or - if no contacts of a given type
        belonging to a given customer exist or no such customer exists -
        the `stop` tuple containing the modified incoming request object
        and an initial state of the handler."

    (let ((customer-id  (binding 'customer_id  req 1)))
    (let ((contact-type (binding 'contact_type req (binary (PHONE)))))
    (-dbg dbg s (++      (REST-CUST-ID)  (EQUALS)(binary_to_list customer-id)
    (SPACE)(V-BAR)(SPACE)(REST-CONT-TYPE)(EQUALS)                contact-type))

    (let (((cons phones (cons emails _)) (m:SQL-GET-CONTACTS-BY-TYPE)))
    (let ((contact-type- (casefold contact-type)))
    (let ((sql-query (cond ((== contact-type- (binary (PHONE))) phones)
                           ((== contact-type- (binary (EMAIL))) emails)
    (else emails))))

    (try (progn
        ; Retrieving all contacts of a given type associated
        ; with a given customer from the database.
        (let ((contacts
            (-entity-prep (sql_exec cnx sql-query `(,customer-id)) 'false)))

        (cond
            ((== (length contacts) 0)
                (-http-404-resp (ERR-REQ-NOT-FOUND-4) req state))
            (else
                (let (((cons contact0 _) contacts))
                (-dbg dbg s (++ (O-BRACKET)
                                (binary_to_list (mref contact0 'contact))
                                (C-BRACKET))))

                contacts)
        )))
    (catch (`#(error ,_ ,_) (-http-500-resp req state)))))))))
)

; Helpers and others ----------------------------------------------------------

; Helper function. Used to preprocess a property list of entity structures
;                  that is taken from the database, to make it suitable
;                  for JSON marshalling.
;
;   `is-customer`: true  => `entity` is a property list of Customer entities,
;                : false => `entity` is a property list of Contact  entities.
;
(defun -entity-prep (entity is-customer)
    (let (((cons cols _) (proplists:get_all_values 'columns entity)))
    (let (((cons rows _) (proplists:get_all_values 'rows    entity)))

    (cond
        (is-customer
            (let (((cons id (cons name _)) cols))

            (lists:map (lambda (row) `#M(
                ,(list_to_atom id  ) ,(tref row 1)
                ,(list_to_atom name) ,(tref row 2)
            )) rows)))
        (else
            (let (((cons contact _) cols))

            (lists:map (lambda (row) `#M(
                ,(list_to_atom contact) ,(tref row 1)
            )) rows)))
    )))
)

; Helper function. Used to send the HTTP 404 Not Found response.
(defun -http-404-resp (msg req state)
    `#(stop ,(reply (HTTP-404) (set_resp_body (json:encode
        `#M(error ,msg)
    ) req)) ,state)
)

; Helper function. Used to send the HTTP 500 Internal Server Error response.
(defun -http-500-resp (req state)
    `#(stop ,(reply (HTTP-500) (set_resp_body (json:encode
        `#M(error ,(ERR-SRV-INTERNAL-ERROR))
    ) req)) ,state)
)

; vim:set nu et ts=4 sw=4:
