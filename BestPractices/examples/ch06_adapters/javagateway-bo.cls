/// Rule: BestPractices_Interop_IRIS.md §6.6 "Java integration via JavaGateway"
/// Validity: Still valid; flag as "Use sparingly in 2025+".
/// Severity: Medium.
///
/// Pattern: when a third-party library is only available as Java (e.g. a legacy
/// vendor SAML module or other vendor JAR) call it from Ensemble via the JavaGateway.
///
/// Steps:
///   1. Deploy the JAR to a fixed directory (e.g. D:\ClassesJavaEnsemble\).
///   2. Use Studio -> Tools -> Java Gateway Wizard to generate ObjectScript proxy classes.
///   3. Write a BO that extends EnsLib.JavaGateway.AbstractOperation (this class).
///   4. Add the JAR to the JavaGateway classpath via the production component's
///      "Parametros adicionales" setting.
///
/// In 2025+, prefer external services or ObjectScript reimplementation.
/// (The 2017+ SAML JavaGateway pattern was superseded by the public
/// intersystems-ib/SAML-COS ObjectScript implementation - see external-repos.md.)
Class Example.Adapters.JavaGateway.BO Extends EnsLib.JavaGateway.AbstractOperation
{

/// Setting: classpath addition for the JAR. Configure in production XML or Portal.
Parameter SETTINGS = "JavaClassPath";

Property JavaClassPath As %String(MAXLEN = 1024) [ InitialExpression = "D:\ClassesJavaEnsemble\vendor.jar" ];

Method CallVendorMethod(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    #DIM tSC as %Status = $$$OK
    #DIM tProxy as %ObjectHandle
    #DIM errObj as %Exception.AbstractException
    try {
        // Wizard-generated proxy class, here named "com.vendor.MyService".
        set tProxy = ##class(com.vendor.MyService).%New(..%GatewayConnection)

        // The Java method to invoke (signature matches the generated proxy).
        set pResponse = ##class(Ens.Response).%New()
        set pResponse.SomeField = tProxy.someJavaMethod(pRequest.SomeArg)
    } catch (errObj) {
        set tSC = errObj.AsStatus()
    }
    quit tSC
}

}
