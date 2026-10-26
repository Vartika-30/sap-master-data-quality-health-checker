*&---------------------------------------------------------------------*
*& Report zmdq_history_viewer
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmdq_history_viewer.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*

PARAMETERS:
  p_runid TYPE char14.

*---------------------------------------------------------------------*
* Data
*---------------------------------------------------------------------*

DATA:
  gt_runs   TYPE STANDARD TABLE OF zmdq_run,
  gt_issues TYPE STANDARD TABLE OF zmdq_issue.

DATA:
  go_alv_runs   TYPE REF TO cl_salv_table,
  go_alv_issues TYPE REF TO cl_salv_table.

*---------------------------------------------------------------------*
* Main Processing
*---------------------------------------------------------------------*

DATA:
  gs_latest_run TYPE zmdq_run.

START-OF-SELECTION.

  "---------------------------------------------------------------*
  " 1. Read Run History
  "---------------------------------------------------------------*

  IF p_runid IS INITIAL.

    SELECT *
      FROM zmdq_run
      INTO TABLE @gt_runs
      ORDER BY run_id DESCENDING.

  ELSE.

    SELECT *
      FROM zmdq_run
      INTO TABLE @gt_runs
      WHERE run_id = @p_runid.

  ENDIF.

  IF gt_runs IS INITIAL.
    MESSAGE 'No run history found.' TYPE 'I'.
    RETURN.
  ENDIF.

  "---------------------------------------------------------------*
  " 2. Display Run History
  "---------------------------------------------------------------*

  TRY.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv_runs
        CHANGING
          t_table      = gt_runs ).

      go_alv_runs->get_functions( )->set_all( abap_true ).

      go_alv_runs->get_columns( )->set_optimize( abap_true ).

      go_alv_runs->display( ).

    CATCH cx_salv_msg.

      MESSAGE 'Error displaying run history.' TYPE 'E'.

  ENDTRY.

  "---------------------------------------------------------------*
  " 3. Read Issues
  "---------------------------------------------------------------*

  IF p_runid IS NOT INITIAL.

    SELECT *
      FROM zmdq_issue
      INTO TABLE @gt_issues
      WHERE run_id = @p_runid.

  ELSE.

    READ TABLE gt_runs INTO gs_latest_run INDEX 1.
    IF sy-subrc = 0.

      SELECT *
        FROM zmdq_issue
        INTO TABLE @gt_issues
        WHERE run_id = @gs_latest_run-run_id.

    ENDIF.

  ENDIF.

  "---------------------------------------------------------------*
  " 4. Display Issues
  "---------------------------------------------------------------*

  IF gt_issues IS INITIAL.
    MESSAGE 'No issues found for the selected run.' TYPE 'I'.
    RETURN.
  ENDIF.

  TRY.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv_issues
        CHANGING
          t_table      = gt_issues ).

      go_alv_issues->get_functions( )->set_all( abap_true ).

      go_alv_issues->get_columns( )->set_optimize( abap_true ).

      go_alv_issues->display( ).

    CATCH cx_salv_msg.

      MESSAGE 'Error displaying issue history.' TYPE 'E'.

  ENDTRY.
