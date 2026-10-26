CLASS zcl_mdq_check_phone definition
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zif_mdq_check.

ENDCLASS.


CLASS zcl_mdq_check_phone
  IMPLEMENTATION.

  METHOD zif_mdq_check~check.

    IF is_customer-telf1 IS INITIAL.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'MISSING_PHONE'
        severity   = 'MEDIUM'
        deduction  = 15
        message    = 'Customer has no telephone number'
      ) TO ct_issues.

    ENDIF.

  ENDMETHOD.

ENDCLASS.