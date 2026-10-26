*&---------------------------------------------------------------------*
*& Report zmdq_init_rules
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmdq_init_rules.
DATA:
  lt_rules TYPE STANDARD TABLE OF zmdq_rule_cfg,
  ls_rule  TYPE zmdq_rule_cfg.

ls_rule-CLIENt = sy-mandt.
ls_rule-rule_id = 'MISSING_EMAIL'.
ls_rule-rule_name = 'Missing Email'.
ls_rule-active = 'X'.
ls_rule-severity = 'HIGH'.
ls_rule-deduction = 20.
ls_rule-description = 'Customer has no email address'.
APPEND ls_rule TO lt_rules.

CLEAR ls_rule.
ls_rule-client = sy-mandt.
ls_rule-rule_id = 'MISSING_PHONE'.
ls_rule-rule_name = 'Missing Phone'.
ls_rule-active = 'X'.
ls_rule-severity = 'MEDIUM'.
ls_rule-deduction = 15.
ls_rule-description = 'Customer has no phone number'.
APPEND ls_rule TO lt_rules.

CLEAR ls_rule.
ls_rule-client = sy-mandt.
ls_rule-rule_id = 'MISSING_ADDRESS'.
ls_rule-rule_name = 'Missing Address'.
ls_rule-active = 'X'.
ls_rule-severity = 'HIGH'.
ls_rule-deduction = 20.
ls_rule-description = 'Customer has no address assignment'.
APPEND ls_rule TO lt_rules.

CLEAR ls_rule.
ls_rule-client = sy-mandt.
ls_rule-rule_id = 'MISSING_STREET'.
ls_rule-rule_name = 'Missing Street'.
ls_rule-active = 'X'.
ls_rule-severity = 'MEDIUM'.
ls_rule-deduction = 10.
ls_rule-description = 'Customer address has no street'.
APPEND ls_rule TO lt_rules.

CLEAR ls_rule.
ls_rule-client = sy-mandt.
ls_rule-rule_id = 'MISSING_CITY'.
ls_rule-rule_name = 'Missing City'.
ls_rule-active = 'X'.
ls_rule-severity = 'MEDIUM'.
ls_rule-deduction = 10.
ls_rule-description = 'Customer address has no city'.
APPEND ls_rule TO lt_rules.

CLEAR ls_rule.
ls_rule-client = sy-mandt.
ls_rule-rule_id = 'MISSING_POSTAL_CODE'.
ls_rule-rule_name = 'Missing Postal Code'.
ls_rule-active = 'X'.
ls_rule-severity = 'MEDIUM'.
ls_rule-deduction = 10.
ls_rule-description = 'Customer address has no postal code'.
APPEND ls_rule TO lt_rules.

CLEAR ls_rule.
ls_rule-client = sy-mandt.
ls_rule-rule_id = 'INVALID_EMAIL'.
ls_rule-rule_name = 'Invalid Email'.
ls_rule-active = 'X'.
ls_rule-severity = 'MEDIUM'.
ls_rule-deduction = 10.
ls_rule-description = 'Customer email has invalid format'.
APPEND ls_rule TO lt_rules.

INSERT zmdq_rule_cfg FROM TABLE @lt_rules.

IF sy-subrc = 0.
  COMMIT WORK.
  MESSAGE '7 MDQ rules initialized successfully.' TYPE 'S'.
ELSE.
  ROLLBACK WORK.
  MESSAGE 'Error while initializing MDQ rules.' TYPE 'E'.
ENDIF.
