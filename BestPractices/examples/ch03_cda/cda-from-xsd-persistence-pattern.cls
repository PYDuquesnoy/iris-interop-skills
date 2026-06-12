/// Rule: BestPractices_Interop_IRIS.md §3.1 "CDA-from-XSD class generation:
///       Persistent + no Relationships + OnDelete Cascade"
/// Validity: Still valid.
/// Severity: High.
///
/// When importing CDA into ObjectScript classes from the XSD via the XML Schema Wizard,
/// the ONLY working combination is:
///   - Persistent (so messages persist with Ensemble messages)
///   - NO Relationships (Relationships=1 causes serialisation to XML to take ~60s per CDA)
///   - OnDelete = Cascade (so purging an Ensemble message also purges the CDA child rows)
///
/// Tested alternatives that FAIL:
///   - Serializable classes: cyclic-reference compile error (Component contains Component).
///   - Persistent with Relationships: slow XML serialisation as above.
///
/// This file is a TEMPLATE - replace the property layout with whatever the XML Schema
/// Wizard generated for your CDA template, then enforce the three settings below.
Class Example.CDA.ClinicalDocument Extends (%Persistent, %XML.Adaptor)
{

Parameter XMLNAME = "ClinicalDocument";

Parameter XMLNAMESPACE = "urn:hl7-org:v3";

/// CDA Component as a foreign-key reference. CRITICAL: NOT a Relationship.
/// On purge of the parent Ensemble message, OnDelete=Cascade propagates the delete here.
Property Component As Example.CDA.Component;

/// Repeated Component children: use array of references, NOT a Relationships block.
Property Components As array Of Example.CDA.Component;

/// Required so purging an Ensemble message also purges the CDA child rows
/// (avoids orphan accumulation).
Index ComponentIdx On Component [ OnDelete = cascade ];

Storage Default
{
<Data name="ClinicalDocumentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Component</Value>
</Value>
</Data>
<DataLocation>^Example.CDA.ClinicalDocumentD</DataLocation>
<DefaultData>ClinicalDocumentDefaultData</DefaultData>
<IdLocation>^Example.CDA.ClinicalDocumentD</IdLocation>
<IndexLocation>^Example.CDA.ClinicalDocumentI</IndexLocation>
<StreamLocation>^Example.CDA.ClinicalDocumentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
