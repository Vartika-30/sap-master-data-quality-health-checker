CLASS zcl_mdq_check_email_format DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zif_mdq_check.

ENDCLASS.


CLASS zcl_mdq_check_email_format IMPLEMENTATION.

  METHOD zif_mdq_check~check.

    DATA:
      lv_at_count    TYPE i,
      lv_dot_count   TYPE i,
      lv_at_position TYPE i,
      lv_email       TYPE string,
      lv_local       TYPE string,
      lv_domain      TYPE string.

    LOOP AT it_emails INTO DATA(ls_email)
      WHERE addrnumber = is_customer-adrnr.

      IF ls_email-smtp_addr IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_email = ls_email-smtp_addr.

      CLEAR:
        lv_at_count,
        lv_dot_count,
        lv_at_position,
        lv_local,
        lv_domain.

*------------------------------------------------------------------*
* Count @ symbols
*------------------------------------------------------------------*

      FIND ALL OCCURRENCES OF '@'
        IN lv_email
        MATCH COUNT lv_at_count.

*------------------------------------------------------------------*
* Basic structure: exactly one @
*------------------------------------------------------------------*

      IF lv_at_count <> 1.

        APPEND VALUE #(
          kunnr      = is_customer-kunnr
          name1      = is_customer-name1
          adrnr      = is_customer-adrnr
          issue_type = 'INVALID_EMAIL'
          severity   = 'MEDIUM'
          deduction  = 10
          message    = 'Email contains an invalid @ structure'
        ) TO ct_issues.

        CONTINUE.

      ENDIF.

*------------------------------------------------------------------*
* Split local part and domain
*------------------------------------------------------------------*

      SPLIT lv_email AT '@'
        INTO lv_local lv_domain.

*------------------------------------------------------------------*
* Domain must contain a dot
*------------------------------------------------------------------*

      FIND ALL OCCURRENCES OF '.'
        IN lv_domain
        MATCH COUNT lv_dot_count.

      IF lv_local IS INITIAL
         OR lv_domain IS INITIAL
         OR lv_dot_count = 0.

        APPEND VALUE #(
          kunnr      = is_customer-kunnr
          name1      = is_customer-name1
          adrnr      = is_customer-adrnr
          issue_type = 'INVALID_EMAIL'
          severity   = 'MEDIUM'
          deduction  = 10
          message    = 'Email format appears invalid'
        ) TO ct_issues.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.