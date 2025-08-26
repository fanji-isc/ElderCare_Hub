Instance: HeartRateRecoveryExample
InstanceOf: HRRProfile
* subject = Reference(ThomasHeart)
* code = $hrr#001
* status = #final
* valueQuantity.value = 45
* valueQuantity.unit = "beats/min"
* interpretation = #abnormal
* extension[InterpretationCertainty].valueCodeableConcept = $sct#410592001

Instance: ThomasHeart
InstanceOf: Patient
Title: "Synthetic Patient with Health Risk"
Description: "Example synthetic patient who had a heart rate recovery observation"
Usage: #example

* id = "heart-thomas"
* name[0].family = "Heart"
* name[0].given[0] = "Thomas"
* gender = #male
* birthDate = "1955-07-15"