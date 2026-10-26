CLASS zcl_mdq_check_email definition
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zif_mdq_check.

ENDCLASS.


CLASS zcl_mdq_check_email
  IMPLEMENTATION.

  METHOD zif_mdq_check~check.

    DATA(lv_email_found) = abap_false.

    LOOP AT it_emails INTO DATA(ls_email)
      WHERE addrnumber = is_customer-adrnr.

      IF ls_email-smtp_addr IS NOT INITIAL.
        lv_email_found = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF lv_email_found = abap_false.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'MISSING_EMAIL'
        severity   = 'HIGH'
        deduction  = 20
        message    = 'Customer has no email address'
      ) TO ct_issues.

    ENDIF.

  ENDMETHOD.

ENDCLASS.