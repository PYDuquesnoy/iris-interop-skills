/// Rule: BestPractices_Ensemble_IRIS.md §5.5 "Async logging: prefer ^IRISTemp.* + System.Semaphores over IPQ"
/// Validity: Still valid.
/// Severity: Medium.
///
/// Why temp globals over IPQ:
///   - IPQ is one-writer-one-reader per queue; many-writers needs the undocumented %SYSTEM.IPQSet.
///   - IPQ has bounded size: a full queue blocks writers, cascading pause across the app.
///   - IPQ is memory-only (lost on crash).
///   - Temp globals (^IRISTemp.*) are not journalled, never part of the writer's transaction
///     (no rollback risk), and spill to disk on memory overflow - graceful degradation.
///   - IPQ's pass-by-reference benefit only matters for very-large objects; for typical log
///     records (<1 MB) it's dwarfed by the blocking risk.
///
/// Pattern:
///   - Writers push records into ^IRISTemp.AppLog with $Increment for the slot key, then signal a semaphore.
///   - Reader sleeps on the semaphore; when woken, drains ^IRISTemp.AppLog (oldest first) and re-sleeps.
///   - Multiple readers possible; they share the same semaphore.
Class Example.AsyncLog.Logger Extends %RegisteredObject
{

/// Process-shared semaphore name.
Parameter SEMNAME = "AppLogSemaphore";

/// Writer entrypoint - call from any process to enqueue a log record.
ClassMethod Write(pRecord As %String) As %Status
{
    #DIM tSlot as %Integer
    set tSlot = $Increment(^IRISTemp.AppLog)
    set ^IRISTemp.AppLog(tSlot) = $ZDateTime($Horolog, 3, 1) _ "|" _ pRecord
    // Wake the reader (non-blocking signal).
    do $SYSTEM.Semaphore.Signal(..#SEMNAME, 1, 0)
    quit $$$OK
}

/// Reader loop entrypoint - run as a long-lived job (one-shot job; or a scheduled BS).
/// Process records oldest-first; sleep until a writer signals.
ClassMethod ReaderLoop() As %Status
{
    #DIM tKey as %Integer
    #DIM tRec as %String
    #DIM tTimeout as %Integer = 60   // 60-second drain interval as fallback
    for {
        // Drain everything currently queued.
        set tKey = $Order(^IRISTemp.AppLog(""))
        while tKey '= "" {
            set tRec = $Get(^IRISTemp.AppLog(tKey))
            kill ^IRISTemp.AppLog(tKey)
            do ..PersistRecord(tRec)
            set tKey = $Order(^IRISTemp.AppLog(tKey))
        }
        // Sleep until signalled or timeout (fallback drain).
        do $SYSTEM.Semaphore.Wait(..#SEMNAME, 1, tTimeout)
    }
    quit $$$OK
}

/// Replace with your persistence target (file, persistent class, OS syslog, etc.).
ClassMethod PersistRecord(pRecord As %String)
{
    // Example: append to a file
    open "/var/log/iris/applog.log":("WAS"):2
    use "/var/log/iris/applog.log"  write pRecord, !
    close "/var/log/iris/applog.log"
}

}
