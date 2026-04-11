;
; src/api-lite-model.lfe
; =============================================================================
; Customers API Lite microservice prototype (LFE/OTP port). Version 0.1.8
; =============================================================================
; A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
; to be run as a microservice, implementing a special Customers API prototype
; with a smart yet simplified data scheme.
; =============================================================================
; (See the LICENSE file at the top of the source tree.)
;

(defmodule api-lite-model "The model module of the daemon."
    (export all))

(defun SQL-GET-ALL-CUSTOMERS ()
    "Returns an SQL query for retrieving all customer profiles.

    Used by the `GET /v1/customers` REST endpoint."

    (++ "select id ," ; as 'Customer ID'
        "       name" ; as 'Customer Name'
        " from"
        "       customers"
        " order by"
        "       id")
)

(defun SQL-GET-CUSTOMER-BY-ID ()
    "Returns an SQL query for retrieving profile details for a given customer.

    Used by the `GET /v1/customers/{customer_id}` REST endpoint."

    (++ "select id ," ; as 'Customer ID'
        "       name" ; as 'Customer Name'
        " from"
        "       customers"
        " where"
        "      (id = ?)")
)

(defun SQL-GET-ALL-CONTACTS ()
    "Returns an SQL query for retrieving all contacts for a given customer.

    Used by the `GET /v1/customers/{customer_id}/contacts` REST endpoint."

    (++ "select phones.contact" ; as 'Phone(s)'
        " from"
        "       contact_phones phones,"
        "       customers      cust"
        " where"
        "      (cust.id = phones.customer_id) and"
        "      (cust.id =                  ?)"
        " union "
        "select emails.contact" ; as 'Email(s)'
        " from"
        "       contact_emails emails,"
        "       customers      cust"
        " where"
        "      (cust.id = emails.customer_id) and"
        "      (cust.id =                  ?)")
)

(defun SQL-GET-CONTACTS-BY-TYPE ()
    "Returns a list of SQL queries for retrieving all contacts of a given type
    for a given customer.

    Used by the `GET /v1/customers/{customer_id}/contacts/{contact_type}`
    REST endpoint."

 `(,(++ "select phones.contact" ; as 'Phone(s)'
        " from"
        "       contact_phones phones,"
        "       customers      cust"
        " where"
        "      (cust.id = phones.customer_id) and"
        "      (cust.id =                  ?)")
   ,(++ "select emails.contact" ; as 'Email(s)'
        " from"
        "       contact_emails emails,"
        "       customers      cust"
        " where"
        "      (cust.id = emails.customer_id) and"
        "      (cust.id =                  ?)"))
)

(defun SQL-ORDER-CONTACTS-BY-ID ()
    "Returns a list of intermediate parts of SQL queries,
    used to order contact records by ID."

 `(," order by phones.id"
   ," order by emails.id")
)

(defun SQL-DESC-LIMIT-1 ()
    "Returns a terminating part of an SQL query,
    used to retrieve the last record created."

    " desc limit 1"
)

; vim:set nu et ts=4 sw=4:
