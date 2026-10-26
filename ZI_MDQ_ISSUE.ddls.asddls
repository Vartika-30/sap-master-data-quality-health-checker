@AbapCatalog.sqlViewName: 'ZIMDQISS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MDQ Issue History'

define view ZI_MDQ_ISSUE
  as select from zmdq_issue
{
  key run_id,
  key kunnr,
  key issue_type,

      name1,
      adrnr,
      severity,
      deduction,
      health_score,
      message
}
