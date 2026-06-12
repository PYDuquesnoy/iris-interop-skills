/// Rule: BestPractices_Ensemble_IRIS.md §13.7 "Credentials migration: walk Ens.Config.Credentials, export, re-import"
/// Validity: Still valid.
/// Severity: High.
///
/// Problem: Ensemble credentials store passwords in a Secondary database encrypted
/// with the instance key. Standard backup-restore preserves the credential RECORDS
/// but the passwords are unreadable on the new instance (different key).
///
/// Recipe: on the SOURCE instance, walk Ens.Config.Credentials, dump (name, username, password)
/// to a file (which lives encrypted-at-rest by your file system / OS). On the TARGET instance,
/// re-import.
///
/// Operational hygiene:
///   - Hold the dump file on encrypted disk; delete after re-import.
///   - Do NOT commit the dump file to git or to source control.
///   - The dump file is a credential vault for the migration window only.
Class Example.Migration.Credentials Extends %RegisteredObject
{

/// Walk Ens.Config.Credentials on the SOURCE namespace, dump each row to pFile.
/// Format: one row per line, fields TAB-separated:
///   <name> TAB <username> TAB <password>
ClassMethod Export(pFile As %String, pNamespace As %String = "") As %Status
{
    #DIM tSC as %Status = $$$OK
    #DIM tRS as %SQL.StatementResult
    #DIM tStmt as %SQL.Statement
    #DIM tLine as %String
    #DIM errObj as %Exception.AbstractException
    new $namespace
    if pNamespace '= "" set $namespace = pNamespace

    open pFile:("WNS"):2
    if '$test {
        quit $$$ERROR($$$GeneralError, "Cannot open "_pFile_" for write")
    }
    try {
        set tStmt = ##class(%SQL.Statement).%New()
        set tSC = tStmt.%Prepare("SELECT ID, Username, Password FROM Ens_Config.Credentials")
        $$$ThrowOnError(tSC)
        set tRS = tStmt.%Execute()
        while tRS.%Next() {
            set tLine = tRS.%Get("ID") _ $Char(9)
                      _ tRS.%Get("Username") _ $Char(9)
                      _ tRS.%Get("Password")
            use pFile  write tLine, !
        }
    } catch (errObj) {
        set tSC = errObj.AsStatus()
    }
    close pFile
    quit tSC
}

/// Read pFile (produced by Export) and re-create the credential rows on the TARGET.
/// If a row with the same name already exists, the password is updated in place.
ClassMethod Import(pFile As %String, pNamespace As %String = "") As %Status
{
    #DIM tSC as %Status = $$$OK
    #DIM tLine as %String
    #DIM tName, tUsername, tPassword as %String
    #DIM tCred as Ens.Config.Credentials
    #DIM errObj as %Exception.AbstractException
    new $namespace
    if pNamespace '= "" set $namespace = pNamespace

    open pFile:("R"):2
    if '$test {
        quit $$$ERROR($$$GeneralError, "Cannot open "_pFile_" for read")
    }
    try {
        for {
            use pFile  read tLine
            quit:tLine=""
            set tName = $Piece(tLine, $Char(9), 1)
            set tUsername = $Piece(tLine, $Char(9), 2)
            set tPassword = $Piece(tLine, $Char(9), 3)
            if ##class(Ens.Config.Credentials).%ExistsId(tName) {
                set tCred = ##class(Ens.Config.Credentials).%OpenId(tName)
            } else {
                set tCred = ##class(Ens.Config.Credentials).%New()
                set tCred.%Id() = tName
            }
            set tCred.Username = tUsername
            set tCred.Password = tPassword
            set tSC = tCred.%Save()
            $$$ThrowOnError(tSC)
        }
    } catch (errObj) {
        set tSC = errObj.AsStatus()
    }
    close pFile
    quit tSC
}

}
