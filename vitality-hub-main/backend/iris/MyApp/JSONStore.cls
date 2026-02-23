Class MyApp.JSONStore Extends %Persistent
{
Property PatientID As %String;
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDT($H,3)} ];
Property ECGData As %Library.DynamicObject;
Property HRData As %Library.DynamicObject;
Property SleepData As %Library.DynamicObject;
Property DailySummaryData As %Library.DynamicObject;
Property ToiletData As %Library.DynamicObject;
Property GaitData As %Library.DynamicObject;
Index IDIndex On PatientID;
}