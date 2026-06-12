/// Rule: BestPractices_Interop_IRIS.md §6.1.1 "wsp:PolicyReference (#6447) compile failure"
/// Validity: Still valid in current IRIS; SOAP wizard still emits this XData block
///           from WSDLs that contain WS-Policy.
/// Severity: High.
///
/// Symptom: The generated *HTTPPortConfig class fails to compile with
///   ERROR #6447: Elemento inesperado, wsp:PolicyReference, de namespace WS-Policy
///                en el bloque XData de %SOAP.Configuration
///
/// Three equivalent fixes; pick (a) when you want to keep the WSDL-generated XData block
/// for reference, (b) when you control the WSDL source, (c) when you don't.
///
/// Fix (a) - Add REPORTANYERROR = 0 to the offending Config class:
Class Example.Vendor.WSC.SomeServiceHTTPPortConfig Extends %SOAP.Configuration
{

/// Suppresses the #6447 compile error from the WS-Policy XData block below.
/// The WS-Policy assertion is not used at runtime by the Ensemble client;
/// the actual policy (TLS, signing) is configured separately in the BO.
Parameter REPORTANYERROR = 0;

/// Fix (c) - alternative: rename or delete the XData OnConfigurationCompile block.
/// Keeping it here for reference; with REPORTANYERROR=0 it compiles without effect.
XData OnConfigurationCompile [ XMLNamespace = "http://www.w3.org/ns/wsdl/extensions" ]
{
<!-- wsp:PolicyReference URI="#somePolicy" - emitted by wizard from the source WSDL -->
}

}

/// Fix (b) - strip the <wsp:PolicyReference> block from the WSDL BEFORE re-running
/// the SOAP Wizard. Example sed pre-processing:
///
///   sed -i.bak '/<wsp:PolicyReference/d' vendor-service.wsdl
///
/// Then re-import the cleaned WSDL.
