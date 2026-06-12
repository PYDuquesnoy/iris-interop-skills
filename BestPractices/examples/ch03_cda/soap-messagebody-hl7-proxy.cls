/// Rule: BestPractices_Interop_IRIS.md §3.4 "SOAP carrying CDA / HL7 as MessageBody — the canonical pattern"
/// Validity: Still valid.
/// Severity: High.
///
/// When a third-party WSDL specifies a custom `acceptMessage(message)` with the HL7 ER7
/// text in a string field (NOT the standard Ensemble EnsLib.HL7.Util.SOAPClient shape):
///
///   - Change the parameter type from %String -> %Stream.GlobalCharacter
///     (HL7 messages can exceed string limits)
///   - Copy EnsLib.HL7.Operation.SOAPOperation as the BO base
///   - Override Adapter.WebServiceClientClass to point to the custom proxy
///   - Adapt Adapter.InvokeMethod("acceptMessage", ...) (default would call Send)
///
/// The same pattern applies for SOAP-carrying-CDA to a regional document repository
/// (e.g. <publicarDocument> with a CCD <ClinicalDocument xmlns="urn:hl7-org:v3">
/// directly in the SOAP Body parameter).

/// Wizard-generated SOAP proxy, patched to accept HL7 as a Stream.
Class Demo.Vendor.WSC.AcceptMessageProxy Extends %SOAP.WebClient
{

Parameter NAMESPACE = "http://vendor.example/ws";

Parameter SERVICENAME = "AcceptMessageWS";

/// PATCHED: was Parameter message As %String; HL7 messages can exceed string limits.
Method acceptMessage(message As %Stream.GlobalCharacter) As %String [ WebMethod ]
{
    quit ..WebMethod("acceptMessage").Invoke($this, "acceptMessage", .message)
}

}

/// BO that pushes an HL7 message into the vendor SOAP service.
/// Subclasses EnsLib.HL7.Operation.SOAPOperation (copy as needed if you need to patch it).
Class Demo.Vendor.BO Extends EnsLib.HL7.Operation.SOAPOperation
{

/// Point the adapter at the patched proxy.
Method OnInit() As %Status
{
    set ..Adapter.WebServiceClientClass = "Demo.Vendor.WSC.AcceptMessageProxy"
    quit $$$OK
}

/// Override the operation method - default would call Send().
Method OnMessage(pRequest As EnsLib.HL7.Message, Output pResponse As Ens.Response) As %Status
{
    #DIM tSC as %Status = $$$OK
    #DIM tStream as %Stream.GlobalCharacter
    #DIM tResponseString as %String
    set tStream = ##class(%Stream.GlobalCharacter).%New()
    set tSC = pRequest.OutputToLibraryStream(tStream)
    quit:$$$ISERR(tSC) tSC

    set tSC = ..Adapter.InvokeMethod("acceptMessage", .tResponseString, tStream)
    set pResponse = ##class(Ens.Response).%New()
    quit tSC
}

}
