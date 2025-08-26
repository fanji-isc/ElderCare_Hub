Alias: $sct = http://snomed.info/sct

ValueSet: InterpretationConfidenceVS
Description: "Degree of confidence that a condition is present"
* $sct#415684004 "Suspected (qualifier value)"
* $sct#410592001 "Probably Present (qualifier value)"
* $sct#410605003 "Confirmed Present (qualifier value)"

Extension: InterpretationCertainty
Id: interpretation-certainty
Title: "Interpretation Certainty"
Description: "The certainty of the interpretation"
* value[x] only CodeableConcept
* value[x] from InterpretationConfidenceVS