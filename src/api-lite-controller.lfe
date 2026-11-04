;
; src/api-lite-controller.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.17
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-controller "The controller module of the daemon."
    (export ( add-customer          4)  ; (req dbg s cnx) -> Req             | {stop, Req, _}
            ( add-contact           4)  ; (req dbg s cnx) -> Req             | {stop, Req, _}
            (list-customers         4)  ; (req dbg s cnx) -> [#{=>,=>}, ...] | {stop, Req, _}
            ( get-customer          4)  ; (req dbg s cnx) ->  #{=>,=>}       | {stop, Req, _}
            (list-contacts          4)  ; (req dbg s cnx) -> [#{=>},    ...] | {stop, Req, _}
            (list-contacts-by-type  4)) ; (req dbg s cnx) -> [#{=>},    ...] | {stop, Req, _}
    (import (from logger  (debug    1))
            (from string  (casefold 1))
            (from sqlite3 (sql_exec 2)
                          (sql_exec 3))
            (from cowboy_req (reply 2)
                   (set_resp_header 3)
                   (set_resp_body   2)
                           (binding 3)
                         (read_body 1)
                       (body_length 1))
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
        The modified incoming request object, or - if the request
        is malformed - the `stop` tuple containing the modified incoming
        request object."

    (let ((payload- (read_body req)))
    (let ((req- (tref payload- 3)))

    (cond
        ((== (body_length req-) 0)
            (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED) req-))
        (else
            (let ((payload (tref payload- 2)))

            (try (progn
                (let ((customer (json:decode payload)))
                (let ((name (atom_to_binary 'name)))
                (let ((customer-name (case (maps:is_key name customer)
                    ('true  (mref customer name))
                    ('false #B())
                )))

                (cond
                    ((== (byte_size customer-name) 0)
                        (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED) req-))
                    (else
                        (-dbg dbg s (++ (O-BRACKET)
                                        (binary_to_list customer-name)
                                        (C-BRACKET)))

                        (try (progn
                            ; Creating a new customer
                            ; (putting customer data to the database).
                            (sql_exec cnx(m:SQL-PUT-CUSTOMER)`(,customer-name))

                            (let (((cons $customer _)
                                (-entity-prep (sql_exec cnx (++
                                    (m:SQL-GET-ALL-CUSTOMERS)
                                    (m:SQL-DESC-LIMIT-1)
                                )) 'true)))
                            (let (($id   (mref $customer 'id  )))
                            (let (($name (mref $customer 'name)))
                            (-dbg dbg s (++ (O-BRACKET) (integer_to_list $id  )
                                            (V-BAR)     ( binary_to_list $name)
                                            (C-BRACKET)))

                            (reply (HTTP-201) (set_resp_body (json:encode
                                `#M(id ,$id name ,$name)
                            ) (set_resp_header (HDR-LOCATION) (++
                                               (REST-CONTEXT) (SLASH)
                            (integer_to_list $id)) req-)))))))
                        (catch (`#(error ,_ ,_)
                            (-http-err-resp (HTTP-500) (ERR-SRV-INTERNAL-ERROR)
                                req-))
                        )))
                )))))
            (catch (`#(error ,_ ,_)
                (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED) req-))
            ))))
    )))
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
        The modified incoming request object, or - if the request
        is malformed - the `stop` tuple containing the modified incoming
        request object."

    (let ((payload- (read_body req)))
    (let ((req- (tref payload- 3)))

    (cond
        ((== (body_length req-) 0)
            (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED) req-))
        (else
            (let ((payload (tref payload- 2)))

            (try (progn
                (let ((contact (json:decode payload)))
                (let ((cust-id- (atom_to_binary 'customer_id)))
                (let ((contact- (atom_to_binary 'contact    )))
                (let ((contact-cust-id (case (maps:is_key cust-id- contact)
                    ('true  (mref contact cust-id-))
                    ('false #B())
                )))
                (let ((contact-contact (case (maps:is_key contact- contact)
                    ('true  (mref contact contact-))
                    ('false #B())
                )))

                (cond
                    ((or (== (byte_size contact-cust-id) 0)
                         (== (byte_size contact-contact) 0))

                        (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED) req-))
                    (else
                        (-dbg dbg s (++ (REST-CUST-ID)
                                        (EQUALS) contact-cust-id))
                        (-dbg dbg s (++ (O-BRACKET)
                                        (binary_to_list contact-contact)
                                        (C-BRACKET)))

                        ; Trying to parse and validate the request payload
                        ; {customer_id}.
                        (let ((contact-customer-id (try
                            (binary_to_integer contact-cust-id)
                        (catch (`#(error ,_ ,_) 0)))))

                        ; Parsing and validating a customer contact:
                        ; phone or email.
                        (let ((contact-type (-parse-contact contact-contact)))
                        (cond
                            ((or (=<  contact-customer-id  0)
                                 (== (length contact-type) 0))

                                (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED)
                                    req-))
                            (else
                                (let (((cons phone
                                       (cons email _)) (m:SQL-PUT-CONTACT)))
                                (let ((sql-query (cond
                                    ((== contact-type (PHONE)) phone)
                                    ((== contact-type (EMAIL)) email)
                                    (else email)
                                )))

                                (try (progn
                                    ; Creating a new contact (putting a contact
                                    ; regarding a given customer
                                    ; to the database).
                                    (sql_exec cnx sql-query `(
                                        ,contact-contact
                                        ,contact-customer-id
                                    ))

                                    (reply (HTTP-201)(set_resp_body(json:encode
                                        `#M(contact ,contact-contact)
                                    ) (set_resp_header (HDR-LOCATION) (++
                                        (REST-CONTEXT) (SLASH) (integer_to_list
                                        contact-customer-id) (SLASH)
                                        (REST-CONTACTS) (SLASH) contact-type
                                    ) req-))))
                                (catch (`#(error ,_ ,_) (-http-err-resp
                                    (HTTP-500) (ERR-SRV-INTERNAL-ERROR) req-))
                                )))))
                        ))))
                )))))))
            (catch (`#(error ,_ ,_)
                (-http-err-resp (HTTP-400) (ERR-REQ-MALFORMED) req-))
            ))))
    )))
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
        A list of all customer profiles as individual maps: `[#{=>,=>}, ...]`,
        or - if no customers exist yet - the `stop` tuple containing
        the modified incoming request object."

    (try (progn
        ; Retrieving all customer profiles from the database.
        (let ((customers
            (-entity-prep (sql_exec cnx (m:SQL-GET-ALL-CUSTOMERS)) 'true)))

        (cond
            ((== (length customers) 0)
                (-http-err-resp (HTTP-404) (ERR-REQ-NOT-FOUND-2) req))
            (else
                (let (((cons customer0 _) customers))
                (-dbg dbg s (++ (O-BRACKET)
                                (integer_to_list (mref customer0 'id  ))(V-BAR)
                                ( binary_to_list (mref customer0 'name))
                                (C-BRACKET))))

                customers)
        )))
    (catch (`#(error ,_ ,_)
        (-http-err-resp (HTTP-500) (ERR-SRV-INTERNAL-ERROR) req))
    ))
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
        or - if no such customer exists - the `stop` tuple containing
        the modified incoming request object."

    (let ((customer-id (binding 'customer_id req 1)))
    (-dbg dbg s (++ (REST-CUST-ID) (EQUALS) customer-id))

    (try (progn
        ; Retrieving profile details for a given customer from the database.
        (let ((customer-
            (sql_exec cnx (m:SQL-GET-CUSTOMER-BY-ID) `(,customer-id))))

        (cond
            ((== (length (proplists:get_value 'rows customer-)) 0)
                (-http-err-resp (HTTP-404) (ERR-REQ-NOT-FOUND-3) req))
            (else
                (let (((cons customer _) (-entity-prep customer- 'true)))
                (-dbg dbg s (++ (O-BRACKET)
                                (integer_to_list (mref customer 'id  )) (V-BAR)
                                ( binary_to_list (mref customer 'name))
                                (C-BRACKET)))

                customer))
        )))
    (catch (`#(error ,_ ,_)
        (-http-err-resp (HTTP-500) (ERR-SRV-INTERNAL-ERROR) req))
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
        A list of all contacts associated with a given customer as individual
        maps: `[#{=>}, ...]`, or - if no contacts belonging to a given customer
        exist or no such customer exists - the `stop` tuple containing
        the modified incoming request object."

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
                (-http-err-resp (HTTP-404) (ERR-REQ-NOT-FOUND-4) req))
            (else
                (let (((cons contact0 _) contacts))
                (-dbg dbg s (++ (O-BRACKET)
                                (binary_to_list (mref contact0 'contact))
                                (C-BRACKET))))

                contacts)
        )))
    (catch (`#(error ,_ ,_)
        (-http-err-resp (HTTP-500) (ERR-SRV-INTERNAL-ERROR) req))
    )))
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
        A list of all contacts of a given type associated with a given customer
        as individual maps: `[#{=>}, ...]`, or - if no contacts of a given type
        belonging to a given customer exist or no such customer exists -
        the `stop` tuple containing the modified incoming request object."

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
                (-http-err-resp (HTTP-404) (ERR-REQ-NOT-FOUND-4) req))
            (else
                (let (((cons contact0 _) contacts))
                (-dbg dbg s (++ (O-BRACKET)
                                (binary_to_list (mref contact0 'contact))
                                (C-BRACKET))))

                contacts)
        )))
    (catch (`#(error ,_ ,_)
        (-http-err-resp (HTTP-500) (ERR-SRV-INTERNAL-ERROR) req))
    )))))))
)

; Helpers and others ----------------------------------------------------------

; Helper function. Used to send HTTP 4xx/5xx responses.
(defun -http-err-resp (code msg req) ; -> {stop, Req, _}
    `#(stop ,(reply code (set_resp_body (json:encode
        `#M(error ,msg)
    ) req)) _)
)

; Helper function. Used to preprocess a property list of entity structures
;                  that is taken from the database, to make it suitable
;                  for JSON marshalling.
;
;   `is-customer`: true  => `entity` is a property list of Customer entities,
;                : false => `entity` is a property list of Contact  entities.
;
(defun -entity-prep (entity is-customer) ; -> [#{=>,=>}, ...] | [#{=>}, ...]
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

; Helper function. Used to parse and validate a customer contact.
;                  Returns the type of contact: phone or email.
(defun -parse-contact (contact) ; -> "phone" | "email" | []
    (cond
        ((/= (re:run contact (PHONE-REGEX)) 'nomatch) (PHONE))
        ((/= (re:run contact (EMAIL-REGEX)) 'nomatch) (EMAIL))
        (else `())
    )
)

; vim:set nu et ts=4 sw=4:
