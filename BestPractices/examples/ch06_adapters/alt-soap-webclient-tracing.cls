/// Rule: BestPractices_Interop_IRIS.md §6.2 "Per-BO Alt.SOAP.WebClient for SOAP tracing"
/// Validity: Still valid.
/// Severity: High (debuggability).
///
/// Why: the global ^ISCSOAP("Log") toggle forces all components in a namespace
/// to share one log file. By changing every generated SOAP proxy's superclass
/// from %SOAP.WebClient to a customer-internal copy (Alt.SOAP.WebClient) and
/// adding a SoapLogFile setting per BO, you get one log file per BO, settable
/// from the Portal at runtime.
///
/// Caveat: ^ISCSOAP is process-scoped; this still has races in heavy multi-process
/// scenarios. Treat as a debug aid, not always-on tracing.
///
/// Also referenced from §12.4 (Monitoring chapter — SOAP-trace files).
Class Example.Adapters.SOAPClient.BO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property SoapLogFile As %String(MAXLEN = 512) [ InitialExpression = "" ];

Parameter SETTINGS = "SoapLogFile";

Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    If (..SoapLogFile '= "") {
        set ^ISCSOAP("Log") = "ios"
        set ^ISCSOAP("LogFile") = ..SoapLogFile
    }

    // ... invoke the SOAP proxy here ...
    // Set tSC = ..Adapter.InvokeMethod("methodName", .pResponse, pRequest.arg1)

    If (..SoapLogFile '= "") {
        set ^ISCSOAP("Log") = ""
    }
    quit $$$OK
}

}
