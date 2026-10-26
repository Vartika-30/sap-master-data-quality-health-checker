INTERFACE zif_mdq_check
  PUBLIC.

  TYPES:
    BEGIN OF ty_customer,
      kunnr TYPE kunnr,
      name1 TYPE kna1-name1,
      adrnr TYPE kna1-adrnr,
      telf1 TYPE kna1-telf1,
    END OF ty_customer.

  TYPES:
    ty_customer_tab TYPE STANDARD TABLE OF ty_customer
      WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_email,
      addrnumber TYPE adr6-addrnumber,
      smtp_addr  TYPE adr6-smtp_addr,
    END OF ty_email.

  TYPES:
    ty_email_tab TYPE STANDARD TABLE OF ty_email
      WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_address,
      addrnumber TYPE adrc-addrnumber,
      street     TYPE adrc-street,
      city1      TYPE adrc-city1,
      post_code1 TYPE adrc-post_code1,
    END OF ty_address.

  TYPES:
    ty_address_tab TYPE STANDARD TABLE OF ty_address
      WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_issue,
      kunnr        TYPE kunnr,
      name1        TYPE kna1-name1,
      adrnr        TYPE kunnr,
      issue_type   TYPE char30,
      severity     TYPE char10,
      deduction    TYPE i,
      health_score TYPE i,
      message      TYPE char100,
    END OF ty_issue.

  TYPES:
    ty_issue_tab TYPE STANDARD TABLE OF ty_issue
      WITH EMPTY KEY.

  METHODS check
    IMPORTING
      is_customer TYPE ty_customer
      it_emails   TYPE ty_email_tab
      it_addresses TYPE ty_address_tab
    CHANGING
      ct_issues   TYPE ty_issue_tab.

ENDINTERFACE.