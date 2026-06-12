/// Rule: BestPractices_Ensemble_IRIS.md §7.2 "Alert deduplication FunctionSet"
/// Validity: Still valid; portable function-set.
///
/// Usage as routing-rule guard inside Ens.Alert:
///   when AlreadyReportedErr(SourceConfigName, ErrorMessage, 60) -> skip
///
/// Protects against:
///   1. A BP and a BO in the same session both raise an alert -> duplicate email.
///   2. A failing BO retries every N seconds and emits an alert each retry -> mailbox flood.
Class PYD.FilterAlerts.FunctionSet Extends Ens.Rule.FunctionSet [ LegacyInstanceContext, Not ProcedureBlock ]
{

/// Returns true if (SourceConfigName, ErrorMessage) was already reported within Interval seconds today.
ClassMethod AlreadyReportedErr(SourceConfigName, ErrorMessage, Interval = 60) As %Boolean
{
    set datetime=$H, day=+datetime, seconds=$p(datetime,",",2)
    kill ^FilterAlerts("Err",day-1)  // Purge previous day
    if $data(^FilterAlerts("Err",day,seconds\Interval,$extract(ErrorMessage,1,200))) {
        quit 1
    } else {
        set ^FilterAlerts("Err",day,seconds\Interval,$extract(ErrorMessage,1,200))=""
    }
    quit 0
}

/// Returns true if any alert was already produced for this Ensemble session today.
ClassMethod AlreadyReportedPerSession() As %Boolean
{
    set SessionId=%Ensemble("SessionId"), day=+$H
    kill ^FilterAlerts("Session",day-1)
    if ($data(^FilterAlerts("Session",day,SessionId))) {
        quit 1
    } else {
        set ^FilterAlerts("Session",day,SessionId)=""
    }
    quit 0
}

}
