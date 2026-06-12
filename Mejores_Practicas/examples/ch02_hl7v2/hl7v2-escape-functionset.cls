/// Rule: BestPractices_Ensemble_IRIS.md §2.3 "Escape special characters when constructing HL7 v2 strings"
/// Validity: Still valid.
/// Severity: Medium.
///
/// Verbatim trace from the source doc:
///   INTEGRACIONS>w ##class(Demo.UTL.FunctionSet).FormataTextPerHL7v2("hola | ^ ~ \ & que tal"_$C(13,10))
///   hola \F\ \S\ \R\ \E\ \T\ que tal\X0D\\X0A\
///
///   INTEGRACIONS>w ##class(Demo.UTL.FunctionSet).DesformataTextDesdeHL7v2("hola \F\ \S\ \R\ \E\ \T\ que tal\X0D\\X0A\")
///   hola | ^ ~ \ & que tal
///
/// Ensemble auto-escapes HL7 v2 special chars when it generates the message itself
/// (e.g. a system-generated NACK). When you build an HL7 message manually
/// (e.g. a custom NACK in a BP catch), you MUST escape these chars via a helper like this.
/// Without escaping, a `|` inside a free-text field collapses the segment structure
/// and the receiver gets a malformed message.
Class Demo.UTL.FunctionSet Extends Ens.Rule.FunctionSet
{

/// Escape the HL7v2 special characters in `pText` so it is safe to drop into a field.
/// Order matters: `\` must be escaped FIRST, otherwise we'd re-escape the `\` characters
/// introduced by the other rules.
ClassMethod FormataTextPerHL7v2(pText As %String) As %String
{
    set pText = $Replace(pText, "\", "\E\")    // backslash FIRST
    set pText = $Replace(pText, "|", "\F\")    // field separator
    set pText = $Replace(pText, "^", "\S\")    // component separator
    set pText = $Replace(pText, "~", "\R\")    // repetition separator
    set pText = $Replace(pText, "&", "\T\")    // sub-component separator
    set pText = $Replace(pText, $Char(13), "\X0D\")
    set pText = $Replace(pText, $Char(10), "\X0A\")
    quit pText
}

/// Inverse of FormataTextPerHL7v2. Order matters: `\E\` LAST.
ClassMethod DesformataTextDesdeHL7v2(pText As %String) As %String
{
    set pText = $Replace(pText, "\X0A\", $Char(10))
    set pText = $Replace(pText, "\X0D\", $Char(13))
    set pText = $Replace(pText, "\T\", "&")
    set pText = $Replace(pText, "\R\", "~")
    set pText = $Replace(pText, "\S\", "^")
    set pText = $Replace(pText, "\F\", "|")
    set pText = $Replace(pText, "\E\", "\")    // backslash LAST
    quit pText
}

}
