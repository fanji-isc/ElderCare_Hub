Extension: HealthRiskExtension
Id: health-risk-Extension
Title: "Health Risk Extension"
Description: "A mandatory extension to capture patient's health risk"
* ^url = "http://iscfhir.com/StructureDefinition/health-risk-extension"
* ^status = #active
* ^version = "1.0.0"

* value[x] only CodeableConcept
* valueCodeableConcept from HealthRiskCodes (required)