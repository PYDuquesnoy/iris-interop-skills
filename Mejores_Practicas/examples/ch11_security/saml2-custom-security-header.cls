/// Rule: BestPractices_Ensemble_IRIS.md §11.3 "SAML 2.0 — attaching a custom security header to a generated SOAP BO"
/// Validity: Still valid.
/// Severity: High.
///
/// Pattern: The wizard-generated SOAP BO doesn't expose hooks for a wsse:Security header.
/// Override OnMessage (or OnRequest) to:
///   1. Instantiate the Web Service Client manually so we can set SecurityOut BEFORE InvokeMethod.
///   2. Build the SAML assertion (see SAML-COS / SAML11-COS in examples/external-repos.md).
///   3. Wrap it in a <wsse:Security> header (passed via SecurityOut).
///   4. Call InvokeMethod with the method name and arguments.
///
/// The BO exposes a SAMLCredentials setting (alias of an X509 credentials configuration in IRIS)
/// so the cert used to sign the SAML can be changed per-environment without code change.
///
/// CRITICAL CONSTRAINT (§11.2): the SAML assertion must declare ALL its own XML namespaces.
/// Once the receiver extracts it from the SOAP envelope, it is processed by a separate
/// module that does not see the parent envelope's xmlns: declarations.
Class Demo.Vendor.WS016V3.BO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property SAMLCredentials As %String(MAXLEN = 128);

Parameter SETTINGS = "SAMLCredentials";

Method InvokeWithSAML(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    #DIM tSC as %Status = $$$OK
    #DIM tHeader as %SOAP.Security
    #DIM errObj as %Exception.AbstractException
    try {
        Set ..Adapter.WebServiceClientClass = "Demo.Vendor.WS016V3.WSC"

        ///PYD+: Instantiate the Web Service Client to attach a SAML Header
        set ..Adapter.%Client = $classmethod(..Adapter.WebServiceClientClass, "%New")
        set tSC = ..GenSecurityHeader(pRequest.atributosSAML, .tHeader)
        Quit:$$$ISERR(tSC) tSC
        set ..Adapter.%Client.SecurityOut = tHeader
        ///PYD-

        Set tSC = ..Adapter.InvokeMethod("methodName", .pResponse, pRequest.arg1, pRequest.arg2)
    } catch (errObj) {
        set tSC = errObj.AsStatus()
    }
    quit tSC
}

/// Build a wsse:Security header containing a SAML 2.0 assertion.
/// Implementation: see intersystems-ib/SAML-COS (covers the Latin-1 charset bug, §11.1).
Method GenSecurityHeader(pAtributosSAML, Output pHeader As %SOAP.Security) As %Status [ Abstract ]
{
}

}
