/// Rule: BestPractices_Ensemble_IRIS.md §3.2 "Comanda/Resposta inheritance trick for one-of-N subtypes payloads"
/// Validity: Still valid.
/// Severity: Medium.
///
/// Problem: the schema defines ONE envelope type whose actual content is one of N subclasses.
/// In this case: a `Comanda` envelope with `SC1` or `SC2` content variants.
///
/// Pattern: make the generated wrapper class ABSTRACT and create concrete subclasses
/// (ComandaSC1, ComandaSC2) that the BS instantiates based on inspection of the inbound payload.
/// The DataTransform Wizard then sees concrete types and proposes correct mappings.

/// The wrapper envelope from the XSD - left ABSTRACT so DataTransforms target the subclasses.
Class Demo.MSG.Comanda Extends (%SerialObject, %XML.Adaptor) [ Abstract ]
{

Parameter XMLNAME = "Comanda";

Parameter XMLNAMESPACE = "urn:demo:envelope";

/// Concrete subclasses populate this with their typed payload.
Property Header As Demo.MSG.ComandaHeader;

}

/// Concrete subclass for the SC1 variant.
Class Demo.MSG.ComandaSC1 Extends Demo.MSG.Comanda
{

Property Content As Demo.MSG.SC1Content;

}

/// Concrete subclass for the SC2 variant.
Class Demo.MSG.ComandaSC2 Extends Demo.MSG.Comanda
{

Property Content As Demo.MSG.SC2Content;

}

/// Business Service entrypoint: peek at the inbound payload to pick the concrete class.
Class Demo.BS Extends Ens.BusinessService
{

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %String) As %Status
{
    #DIM tComanda as Demo.MSG.Comanda
    #DIM tDoc as %XML.Document
    #DIM tSC as %Status = $$$OK
    set tSC = ##class(%XML.Document).GetDocumentFromStream(pInput, .tDoc)
    quit:$$$ISERR(tSC) tSC

    // Inspect the inbound XML to decide which concrete subclass to materialise.
    // (Real impl: walk tDoc.GetDocumentElement() and look for the discriminator.)
    if ..LooksLikeSC1(tDoc) {
        set tComanda = ##class(Demo.MSG.ComandaSC1).%New()
    } else {
        set tComanda = ##class(Demo.MSG.ComandaSC2).%New()
    }
    // ... unmarshal pInput into tComanda, then SendRequestSync to BP ...
    quit tSC
}

ClassMethod LooksLikeSC1(pDoc As %XML.Document) As %Boolean [ CodeMode = expression ]
{
$$$YES
}

}
