REPORT zmdq_health_check.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*

DATA:
  gv_kunnr TYPE kunnr.
  DATA:
  gv_run_id TYPE char14.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

SELECT-OPTIONS:
  s_kunnr FOR gv_kunnr.

PARAMETERS:
  p_email AS CHECKBOX DEFAULT 'X',
  p_phone AS CHECKBOX DEFAULT 'X',
  p_addr  AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b1.


*---------------------------------------------------------------------*
* Local Types
*---------------------------------------------------------------------*

TYPES:
  ty_customer_tab TYPE STANDARD TABLE OF
    zif_mdq_check=>ty_customer
    WITH EMPTY KEY.

TYPES:
  ty_issue_tab TYPE STANDARD TABLE OF
    zif_mdq_check=>ty_issue
    WITH EMPTY KEY.

TYPES:
  BEGIN OF ty_summary,
    kunnr           TYPE kunnr,
    name1           TYPE kna1-name1,
    issue_count     TYPE i,
    total_deduction TYPE i,
    health_score    TYPE i,
    status          TYPE char20,
  END OF ty_summary.

TYPES:
  ty_summary_tab TYPE STANDARD TABLE OF ty_summary
    WITH EMPTY KEY.

*------------*
TYPES:
  BEGIN OF ty_rule_cfg,
    rule_id     TYPE zmdq_rule_cfg-rule_id,
    rule_name   TYPE zmdq_rule_cfg-rule_name,
    active      TYPE zmdq_rule_cfg-active,
    severity    TYPE zmdq_rule_cfg-severity,
    deduction   TYPE zmdq_rule_cfg-deduction,
    description TYPE zmdq_rule_cfg-description,
  END OF ty_rule_cfg.

TYPES:
  ty_rule_cfg_tab TYPE STANDARD TABLE OF ty_rule_cfg
    WITH EMPTY KEY.

DATA:
  gt_rule_cfg TYPE ty_rule_cfg_tab.

*---------------------------------------------------------------------*
* Internal Tables
*---------------------------------------------------------------------*

DATA:
  gt_customers TYPE ty_customer_tab,
  gt_emails    TYPE zif_mdq_check=>ty_email_tab,
  gt_addresses TYPE zif_mdq_check=>ty_address_tab,
  gt_issues    TYPE ty_issue_tab,
  gt_summary   TYPE ty_summary_tab.


*---------------------------------------------------------------------*
* Main Processing
*---------------------------------------------------------------------*

START-OF-SELECTION.



SELECT
  rule_id,
  rule_name,
  active,
  severity,
  deduction,
  description
  FROM zmdq_rule_cfg
  WHERE active = 'X'
  INTO TABLE @gt_rule_cfg.

IF gt_rule_cfg IS INITIAL.
  MESSAGE 'No active MDQ rules configured' TYPE 'E'.
ENDIF.

  CONCATENATE sy-datum sy-uzeit INTO gv_run_id.
  WRITE: / 'Run ID:', gv_run_id.
*---------------------------------------------------------------------*
* 1. Read Customer Master Data - KNA1
*---------------------------------------------------------------------*

  IF s_kunnr IS INITIAL.

    SELECT
      kunnr,
      name1,
      adrnr,
      telf1
      FROM kna1
      INTO TABLE @gt_customers.

  ELSE.

    SELECT
      kunnr,
      name1,
      adrnr,
      telf1
      FROM kna1
      WHERE kunnr IN @s_kunnr
      INTO TABLE @gt_customers.

  ENDIF.


*---------------------------------------------------------------------*
* 2. Read Email Data - ADR6
*---------------------------------------------------------------------*

  IF gt_customers IS NOT INITIAL
     AND p_email = abap_true.

    SELECT
      addrnumber,
      smtp_addr
      FROM adr6
      FOR ALL ENTRIES IN @gt_customers
      WHERE addrnumber = @gt_customers-adrnr
      INTO TABLE @gt_emails.

  ENDIF.


*---------------------------------------------------------------------*
* 3. Read Address Data - ADRC
*---------------------------------------------------------------------*

  IF gt_customers IS NOT INITIAL
     AND p_addr = abap_true.

    SELECT
      addrnumber,
      street,
      city1,
      post_code1
      FROM adrc
      FOR ALL ENTRIES IN @gt_customers
      WHERE addrnumber = @gt_customers-adrnr
      INTO TABLE @gt_addresses.

  ENDIF.


*---------------------------------------------------------------------*
* 4. Create Rule Objects
*---------------------------------------------------------------------*

  DATA:
    lo_email_rule        TYPE REF TO zcl_mdq_check_email,
    lo_email_format_rule TYPE REF TO zcl_mdq_check_email_format,
    lo_phone_rule        TYPE REF TO zcl_mdq_check_phone,
    lo_address_rule     TYPE REF TO zcl_mdq_check_address.

  IF p_email = abap_true.

    lo_email_rule = NEW zcl_mdq_check_email( ).

    lo_email_format_rule =
      NEW zcl_mdq_check_email_format( ).

  ENDIF.

  IF p_phone = abap_true.

    lo_phone_rule = NEW zcl_mdq_check_phone( ).

  ENDIF.

  IF p_addr = abap_true.

    lo_address_rule =
      NEW zcl_mdq_check_address( ).

  ENDIF.


*---------------------------------------------------------------------*
* 5. Execute Quality Rules
*---------------------------------------------------------------------*

  LOOP AT gt_customers INTO DATA(ls_customer).


*-------------------------------------------------------------------*
* Missing Email Rule
*-------------------------------------------------------------------*

    IF lo_email_rule IS BOUND.

      lo_email_rule->zif_mdq_check~check(
        EXPORTING
          is_customer  = ls_customer
          it_emails    = gt_emails
          it_addresses = gt_addresses
        CHANGING
          ct_issues    = gt_issues ).

    ENDIF.


*-------------------------------------------------------------------*
* Email Format Rule
*-------------------------------------------------------------------*

    IF lo_email_format_rule IS BOUND.

      lo_email_format_rule->zif_mdq_check~check(
        EXPORTING
          is_customer  = ls_customer
          it_emails    = gt_emails
          it_addresses = gt_addresses
        CHANGING
          ct_issues    = gt_issues ).

    ENDIF.


*-------------------------------------------------------------------*
* Missing Phone Rule
*-------------------------------------------------------------------*

    IF lo_phone_rule IS BOUND.

      lo_phone_rule->zif_mdq_check~check(
        EXPORTING
          is_customer  = ls_customer
          it_emails    = gt_emails
          it_addresses = gt_addresses
        CHANGING
          ct_issues    = gt_issues ).

    ENDIF.


*-------------------------------------------------------------------*
* Address Rule
*-------------------------------------------------------------------*

    IF lo_address_rule IS BOUND.

      lo_address_rule->zif_mdq_check~check(
        EXPORTING
          is_customer  = ls_customer
          it_emails    = gt_emails
          it_addresses = gt_addresses
        CHANGING
          ct_issues    = gt_issues ).

    ENDIF.

  ENDLOOP.


*---------------------------------------------------------------------*
* 6. Calculate Customer Scores + Summary
*---------------------------------------------------------------------*

  LOOP AT gt_customers INTO ls_customer.

    DATA:
      lv_total_deduction TYPE i VALUE 0,
      lv_issue_count     TYPE i VALUE 0,
      lv_health_score    TYPE i.

*-------------------------------------------------------------------*
* Calculate issue count and deductions
*-------------------------------------------------------------------*

    LOOP AT gt_issues INTO DATA(ls_issue)
      WHERE kunnr = ls_customer-kunnr.

      lv_issue_count = lv_issue_count + 1.

      lv_total_deduction =
        lv_total_deduction + ls_issue-deduction.

    ENDLOOP.



**********************************************************************
*issue*

*-------------------------------------------------------------------*
* Calculate score
*-------------------------------------------------------------------*

    lv_health_score = 100 - lv_total_deduction.

    IF lv_health_score < 0.
      lv_health_score = 0.
    ENDIF.


*-------------------------------------------------------------------*
* Determine status
*-------------------------------------------------------------------*

    DATA(lv_status) = VALUE char20( ).

    IF lv_health_score >= 90.

      lv_status = 'HEALTHY'.

    ELSEIF lv_health_score >= 70.

      lv_status = 'GOOD'.

    ELSEIF lv_health_score >= 40.

      lv_status = 'NEEDS_REVIEW'.

    ELSE.

      lv_status = 'CRITICAL'.

    ENDIF.


*-------------------------------------------------------------------*
* Add summary row
*-------------------------------------------------------------------*

    APPEND VALUE #(
      kunnr           = ls_customer-kunnr
      name1           = ls_customer-name1
      issue_count     = lv_issue_count
      total_deduction = lv_total_deduction
      health_score    = lv_health_score
      status          = lv_status
    ) TO gt_summary.


*-------------------------------------------------------------------*
* Put score into issue rows
*-------------------------------------------------------------------*

*-------*
*new section*

LOOP AT gt_issues INTO ls_issue.

  READ TABLE gt_rule_cfg INTO DATA(ls_cfg)
    WITH KEY rule_id = ls_issue-issue_type.

  IF sy-subrc = 0.

    ls_issue-severity  = ls_cfg-severity.
    ls_issue-deduction = ls_cfg-deduction.

    MODIFY gt_issues FROM ls_issue.

  ENDIF.

ENDLOOP.







    LOOP AT gt_issues ASSIGNING FIELD-SYMBOL(<ls_issue>)
      WHERE kunnr = ls_customer-kunnr.

      <ls_issue>-health_score = lv_health_score.

    ENDLOOP.

  ENDLOOP.


*---------------------------------------------------------------------*
* 7. Display Issue Detail ALV
*---------------------------------------------------------------------*

  IF gt_issues IS NOT INITIAL.

    DATA:
      lo_alv    TYPE REF TO cl_salv_table,
      lo_column TYPE REF TO cl_salv_column_table.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = gt_issues ).

    lo_alv->get_functions( )->set_all( abap_true ).

    lo_alv->get_columns( )->set_optimize( abap_true ).


    TRY.

        lo_column ?=
          lo_alv->get_columns( )->get_column( 'KUNNR' ).

        lo_column->set_short_text( 'Customer' ).
        lo_column->set_medium_text( 'Customer No.' ).
        lo_column->set_long_text( 'Customer Number' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'NAME1' ).

        lo_column->set_short_text( 'Name' ).
        lo_column->set_medium_text( 'Customer Name' ).
        lo_column->set_long_text( 'Customer Name' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'ADRNR' ).

        lo_column->set_short_text( 'Address' ).
        lo_column->set_medium_text( 'Address No.' ).
        lo_column->set_long_text( 'Address Number' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'ISSUE_TYPE' ).

        lo_column->set_short_text( 'Issue' ).
        lo_column->set_medium_text( 'Issue Type' ).
        lo_column->set_long_text( 'Data Quality Issue' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'SEVERITY' ).

        lo_column->set_short_text( 'Severity' ).
        lo_column->set_medium_text( 'Severity' ).
        lo_column->set_long_text( 'Issue Severity' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'DEDUCTION' ).

        lo_column->set_short_text( 'Deduct.' ).
        lo_column->set_medium_text( 'Deduction' ).
        lo_column->set_long_text( 'Health Score Deduction' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'HEALTH_SCORE' ).

        lo_column->set_short_text( 'Score' ).
        lo_column->set_medium_text( 'Health Score' ).
        lo_column->set_long_text( 'Customer Health Score' ).


        lo_column ?=
          lo_alv->get_columns( )->get_column( 'MESSAGE' ).

        lo_column->set_short_text( 'Message' ).
        lo_column->set_medium_text( 'Issue Message' ).
        lo_column->set_long_text(
          'Data Quality Issue Message' ).

      CATCH cx_salv_not_found.

    ENDTRY.


    lo_alv->display( ).

  ENDIF.



*-------*
*CHECK*
DATA ls_run TYPE zmdq_run.

ls_run-mandt          = sy-mandt.
ls_run-run_id         = gv_run_id.
ls_run-run_date       = sy-datum.
ls_run-run_time       = sy-uzeit.
ls_run-run_user       = sy-uname.
ls_run-customer_count = lines( gt_customers ).
ls_run-issue_count    = lines( gt_issues ).


INSERT zmdq_run FROM @ls_run.

IF sy-subrc <> 0.
  MESSAGE 'Error while saving run history' TYPE 'E'.
ENDIF.


DATA:
  lt_db_issues TYPE STANDARD TABLE OF zmdq_issue,
  ls_db_issue  TYPE zmdq_issue.



LOOP AT gt_issues INTO ls_issue.

  CLEAR ls_db_issue.

  ls_db_issue-mandt        = sy-mandt.
  ls_db_issue-run_id       = gv_run_id.
  ls_db_issue-kunnr        = ls_issue-kunnr.
  ls_db_issue-issue_type   = ls_issue-issue_type.
  ls_db_issue-name1        = ls_issue-name1.
  ls_db_issue-adrnr        = ls_issue-adrnr.
  ls_db_issue-severity     = ls_issue-severity.
  ls_db_issue-deduction    = ls_issue-deduction.
  ls_db_issue-health_score = ls_issue-health_score.
  ls_db_issue-message      = ls_issue-message.

  APPEND ls_db_issue TO lt_db_issues.

ENDLOOP.

IF lt_db_issues IS NOT INITIAL.

  MESSAGE |Prepared issue records: { lines( lt_db_issues ) }| TYPE 'I'.

  INSERT zmdq_issue FROM TABLE @lt_db_issues.

  DATA(lv_insert_subrc) = sy-subrc.

  MESSAGE |Issue insert SY-SUBRC: { lv_insert_subrc }| TYPE 'I'.

  IF lv_insert_subrc <> 0.
    MESSAGE 'Error while saving issue history' TYPE 'E'.
  ENDIF.

ENDIF.



*------------------*
*INSERT*









*---------------------------------------------------------------------*
* 8. Display Customer Summary ALV
*---------------------------------------------------------------------*

  IF gt_summary IS NOT INITIAL.

    DATA:
      lo_summary_alv    TYPE REF TO cl_salv_table,
      lo_summary_column TYPE REF TO cl_salv_column_table.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lo_summary_alv
      CHANGING
        t_table      = gt_summary ).

    lo_summary_alv->get_functions( )->set_all( abap_true ).

    lo_summary_alv->get_columns( )->set_optimize( abap_true ).


    TRY.

        lo_summary_column ?=
          lo_summary_alv->get_columns( )->get_column(
            'KUNNR' ).

        lo_summary_column->set_short_text( 'Customer' ).
        lo_summary_column->set_medium_text( 'Customer No.' ).
        lo_summary_column->set_long_text(
          'Customer Number' ).


        lo_summary_column ?=
          lo_summary_alv->get_columns( )->get_column(
            'NAME1' ).

        lo_summary_column->set_short_text( 'Name' ).
        lo_summary_column->set_medium_text(
          'Customer Name' ).
        lo_summary_column->set_long_text(
          'Customer Name' ).


        lo_summary_column ?=
          lo_summary_alv->get_columns( )->get_column(
            'ISSUE_COUNT' ).

        lo_summary_column->set_short_text( 'Issues' ).
        lo_summary_column->set_medium_text(
          'Issue Count' ).
        lo_summary_column->set_long_text(
          'Number of Quality Issues' ).


        lo_summary_column ?=
          lo_summary_alv->get_columns( )->get_column(
            'TOTAL_DEDUCTION' ).

        lo_summary_column->set_short_text( 'Deduct.' ).
        lo_summary_column->set_medium_text(
          'Total Deduction' ).
        lo_summary_column->set_long_text(
          'Total Health Score Deduction' ).


        lo_summary_column ?=
          lo_summary_alv->get_columns( )->get_column(
            'HEALTH_SCORE' ).

        lo_summary_column->set_short_text( 'Score' ).
        lo_summary_column->set_medium_text(
          'Health Score' ).
        lo_summary_column->set_long_text(
          'Customer Health Score' ).


        lo_summary_column ?=
          lo_summary_alv->get_columns( )->get_column(
            'STATUS' ).

        lo_summary_column->set_short_text( 'Status' ).
        lo_summary_column->set_medium_text(
          'Health Status' ).
        lo_summary_column->set_long_text(
          'Customer Health Status' ).

      CATCH cx_salv_not_found.

    ENDTRY.


    lo_summary_alv->display( ).

  ENDIF.
