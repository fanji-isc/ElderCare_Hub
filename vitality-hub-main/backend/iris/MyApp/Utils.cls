Class MyApp.Utils
{

ClassMethod SavePatientData(pid As %String, ecgJson As %String = "", hrJson As %String = "", sleepJson As %String = "", dailySummaryJson As %String = "", toiletJson As %String = "", gaitJson As %String = "", fridgeJson As %String = "", neighborhoodJson As %String = "", phoneCallJson As %String = "") As %Integer
{
    // Upsert: reuse existing record for this patient if one exists
    Set id = ""
    &sql(SELECT TOP 1 ID INTO :id FROM MyApp.JSONStore WHERE PatientID = :pid ORDER BY ID ASC)

    If (SQLCODE = 0) && (id '= "") {
        Set rec = ##class(MyApp.JSONStore).%OpenId(id)
    } Else {
        Set rec = ##class(MyApp.JSONStore).%New()
        Set rec.PatientID = pid
    }

    // Overwrite only fields that were provided
    If (ecgJson '= "") Set rec.ECGData = {}.%FromJSON(ecgJson)
    If (hrJson '= "")  Set rec.HRData = {}.%FromJSON(hrJson)
    If (sleepJson '= "") Set rec.SleepData = {}.%FromJSON(sleepJson)
    If (dailySummaryJson '= "") Set rec.DailySummaryData = {}.%FromJSON(dailySummaryJson)
    If (toiletJson '= "") Set rec.ToiletData = {}.%FromJSON(toiletJson)
    If (gaitJson '= "") Set rec.GaitData = {}.%FromJSON(gaitJson)
    If (fridgeJson '= "") Set rec.FridgeData = {}.%FromJSON(fridgeJson)
    If (neighborhoodJson '= "") Set rec.NeighborhoodData = {}.%FromJSON(neighborhoodJson)
    If (phoneCallJson '= "") Set rec.PhoneCallData = {}.%FromJSON(phoneCallJson)

    Do rec.%Save()
    Quit rec.%Id()
}

ClassMethod DeleteDuplicates(pid As %String) As %Integer
{
    // Keep only the lowest-ID record for this patient; delete the rest
    Set id = ""
    &sql(SELECT TOP 1 ID INTO :id FROM MyApp.JSONStore WHERE PatientID = :pid ORDER BY ID ASC)
    If (SQLCODE '= 0) || (id = "") Quit 0

    Set deleted = 0
    Set rs = ##class(%ResultSet).%New("MyApp.JSONStore:Extent")
    Do rs.Execute()
    While rs.Next() {
        Set rowId = rs.GetData(1)
        If (rowId '= id) {
            Set rec = ##class(MyApp.JSONStore).%OpenId(rowId)
            If rec.PatientID = pid {
                Do rec.%DeleteId(rowId)
                Set deleted = deleted + 1
            }
        }
    }
    Quit deleted
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
    Set response.dailySummary = rec.DailySummaryData
    Set response.toilet = rec.ToiletData
    Set response.gait = rec.GaitData
    Set response.fridge = rec.FridgeData
    Set response.neighborhood = rec.NeighborhoodData
    Set response.phoneCalls = rec.PhoneCallData

    Quit response.%ToJSON()
}

}