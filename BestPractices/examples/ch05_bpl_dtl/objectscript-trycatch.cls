/// Rule: BestPractices_Interop_IRIS.md §5.4 "ObjectScript error-handling idiom"
/// Validity: Still valid.
///
/// Why: Ensemble libraries and wizard-generated code don't use modern try/catch;
/// refactor opportunistically. Always return %Status.
Class Example.TryCatch.Idiom Extends %RegisteredObject
{

ClassMethod DoSomething(pInput As %String, Output pOutput As %String) As %Status
{
    #DIM tSC as %Status = $$$OK
    #DIM errObj as %Exception.AbstractException
    try {
        $$$THROWONERROR(tSC, ..InnerCall(pInput, .pOutput))
        // OR
        set tSC = ..InnerCall(pInput, .pOutput)
        $$$ThrowOnError(tSC)
    } catch (errObj) {
        set tSC = errObj.AsStatus()
    }
    quit tSC
}

ClassMethod InnerCall(pInput As %String, Output pOutput As %String) As %Status
{
    set pOutput = pInput
    quit $$$OK
}

}
