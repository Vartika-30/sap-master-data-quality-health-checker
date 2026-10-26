@AbapCatalog.sqlViewName: 'ZIMDQRUN'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MDQ Run History'

define view ZI_MDQ_RUN
  as select from zmdq_run
{
  key run_id,
      run_date,
      run_time,
      run_user,
      customer_count,
      issue_count
}
