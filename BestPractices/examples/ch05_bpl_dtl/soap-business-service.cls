/// Rule: BestPractices_Interop_IRIS.md §5.1 "BS that exposes a SOAP service: how to wire it"
/// Validity: Still valid.
/// Severity: Medium.
///
/// Steps codified by this template:
///   1. New -> General -> Web Service in Studio; define the WS.
///   2. Change parent class from %SOAP.WebService to EnsLib.SOAP.Service.   <-- key change
///   3. Override Adapter parameter to BLANK (default EnsLib.SOAP.InboundAdapter
///      prevents direct inbound on a BS that is itself the SOAP service).
///   4. Implement web methods with [WebMethod] and parameters typed to
///      MSG.<Name>{Req|Rsp} classes (per §1.1 naming convention).
///   5. Override OnProcessInput and call the BP sync or async as needed.
Class Example.MyService.BS Extends EnsLib.SOAP.Service
{

/// CRITICAL: must be BLANK. Default EnsLib.SOAP.InboundAdapter blocks direct inbound.
Parameter ADAPTER;

Parameter NAMESPACE = "http://example.org/myservice";

Parameter SERVICENAME = "MyService";

/// Web method implementing the inbound contract.
Method AcceptOrder(pRequest As Example.MSG.AcceptOrderReq) As Example.MSG.AcceptOrderRsp [ WebMethod ]
{
    #DIM tSC as %Status = $$$OK
    #DIM pResponse as Example.MSG.AcceptOrderRsp
    set tSC = ..OnProcessInput(pRequest, .pResponse)
    if $$$ISERR(tSC) {
        // Map %Status to a SOAP fault appropriate for your contract.
        $$$ThrowOnError(tSC)
    }
    quit pResponse
}

/// Called per inbound message. Dispatch to the BP synchronously or via SendRequestAsync.
Method OnProcessInput(pInput As Example.MSG.AcceptOrderReq, Output pOutput As Example.MSG.AcceptOrderRsp) As %Status
{
    set pOutput = ##class(Example.MSG.AcceptOrderRsp).%New()
    // Synchronous dispatch to the BP:
    quit ..SendRequestSync("Example.MyService.BP", pInput, .pOutput)
}

}
