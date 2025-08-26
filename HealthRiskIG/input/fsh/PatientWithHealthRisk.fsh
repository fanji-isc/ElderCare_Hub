Instance: ExamplePatient1
InstanceOf: PatientWithHealthRisk
Title: "Synthetic Patient with Health Risk"
Description: "An example patient instance that includes a health risk extension"
Usage: #example

* name[0].family = "Doe"
* name[0].given[0] = "Jane"
* gender = #female
* birthDate = "1985-07-15"

// required extension to capture patient's health riskl
* extension[healthRiskExtension].url = "http://iscfhir.com/StructureDefinition/health-risk-extension"
* extension[healthRiskExtension].valueCodeableConcept = http://iscfhir.com/healthrisk#medium "Medium"

