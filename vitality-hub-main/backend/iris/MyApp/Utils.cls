Class MyApp.Utils
{

ClassMethod SavePatientData(pid As %String, ecgJson As %String = "", hrJson As %String = "", sleepJson As %String = "") As %Integer
{
    Set rec = ##class(MyApp.JSONStore).%New()
    Set rec.PatientID = pid
    
    // Parse strings into Objects only if they aren't empty
    If (ecgJson '= "") Set rec.ECGData = {}.%FromJSON(ecgJson)
    If (hrJson '= "")  Set rec.HRData = {}.%FromJSON(hrJson)
    If (sleepJson '= "") Set rec.SleepData = {}.%FromJSON(sleepJson)
    Do rec.%Save()
    Quit rec.%Id()
}

ClassMethod GetLatestJSONFile(pid As %String = "") As %String
{
    Set id = ""
    
    // Get latest globally or for a specific patient
    If (pid = "") {
        &sql(SELECT TOP 1 ID INTO :id FROM MyApp.JSONStore ORDER BY ID DESC)
    } Else {
        &sql(SELECT TOP 1 ID INTO :id FROM MyApp.JSONStore WHERE PatientID = :pid ORDER BY ID DESC)
    }
    
    If (SQLCODE '= 0) || (id = "") Quit "{}"

    Set rec = ##class(MyApp.JSONStore).%OpenId(id)
    
    // Build the combined response
    Set response = {}
    Set response.patientID = rec.PatientID
    Set response.ecg = rec.ECGData
    Set response.hr = rec.HRData
    Set response.sleep = rec.SleepData
    
    Quit response.%ToJSON()
}

}