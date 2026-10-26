CLASS zcl_mdq_check_address DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zif_mdq_check.

ENDCLASS.


CLASS zcl_mdq_check_address IMPLEMENTATION.

  METHOD zif_mdq_check~check.

    DATA:
      ls_address TYPE zif_mdq_check=>ty_address.


*------------------------------------------------------------------*
* Check 1: Is an address assigned to the customer?
*------------------------------------------------------------------*

    IF is_customer-adrnr IS INITIAL.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'MISSING_ADDRESS'
        severity   = 'HIGH'
        deduction  = 20
        message    = 'Customer has no address assigned'
      ) TO ct_issues.

      RETURN.

    ENDIF.


*------------------------------------------------------------------*
* Check 2: Find the address in ADRC internal table
*------------------------------------------------------------------*

    READ TABLE it_addresses
      INTO ls_address
      WITH KEY addrnumber = is_customer-adrnr.


*------------------------------------------------------------------*
* Address number exists in KNA1 but not in ADRC
*------------------------------------------------------------------*

    IF sy-subrc <> 0.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'ADDRESS_NOT_FOUND'
        severity   = 'HIGH'
        deduction  = 20
        message    = 'Address number has no ADRC record'
      ) TO ct_issues.

      RETURN.

    ENDIF.


*------------------------------------------------------------------*
* Check 3: Street
*------------------------------------------------------------------*

    IF ls_address-street IS INITIAL.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'MISSING_STREET'
        severity   = 'MEDIUM'
        deduction  = 10
        message    = 'Customer address has no street'
      ) TO ct_issues.

    ENDIF.


*------------------------------------------------------------------*
* Check 4: City
*------------------------------------------------------------------*

    IF ls_address-city1 IS INITIAL.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'MISSING_CITY'
        severity   = 'MEDIUM'
        deduction  = 10
        message    = 'Customer address has no city'
      ) TO ct_issues.

    ENDIF.


*------------------------------------------------------------------*
* Check 5: Postal Code
*------------------------------------------------------------------*

    IF ls_address-post_code1 IS INITIAL.

      APPEND VALUE #(
        kunnr      = is_customer-kunnr
        name1      = is_customer-name1
        adrnr      = is_customer-adrnr
        issue_type = 'MISSING_POSTAL_CODE'
        severity   = 'MEDIUM'
        deduction  = 10
        message    = 'Customer address has no postal code'
      ) TO ct_issues.

    ENDIF.

  ENDMETHOD.

ENDCLASS.