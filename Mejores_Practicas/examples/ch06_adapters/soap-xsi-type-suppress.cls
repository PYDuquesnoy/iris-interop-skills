/// Rule: BestPractices_Ensemble_IRIS.md §6.1.2 "Vendor WS rejects xsi:type"
///        + §5.3 "XML projection — OUTPUTTYPEATTRIBUTE = 0"
/// Validity: Still valid.
/// Severity: Medium.
///
/// Symptom: even with type info matching the schema, vendor SOAP server returns
/// errors when xsi:type attributes appear in the request.
///
/// Fix: set Parameter OUTPUTTYPEATTRIBUTE = 0 on the generated SOAP client class
/// (or on the SOAP proxy message types). Suppresses xsi:type on every element.
Class Example.Vendor.WSC.SAPClient Extends %SOAP.WebClient
{

/// Suppress xsi:type attributes on the wire. Multiple vendor
/// servers choke on the unexpected attribute even when the type matches.
Parameter OUTPUTTYPEATTRIBUTE = 0;

}
