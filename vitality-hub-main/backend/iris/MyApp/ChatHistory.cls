Class MyApp.ChatHistory Extends %Persistent
{
Property PatientID As %String;
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDT($H,3)} ];
Property UserMessage As %Library.DynamicObject;
Index IDIndex On PatientID;
}