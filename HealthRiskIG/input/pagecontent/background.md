# Background and Strategic Vision

## Background

Rochester Health has recently hired a new Chief Medical Officer (CMO) who has prioritized **preventive care** and **early intervention** as core strategies to both reduce long-term healthcare costs and improve patient outcomes.

This renewed focus on proactive care is a response to increasing national trends in chronic disease, rising emergency care utilization, and the recognized value of data-driven population health management.

## Strategic Decision

To operationalize this vision, Rochester Health is launching a system-wide initiative to:

- **Risk-rate every patient** based on their likelihood of experiencing a serious health event (e.g., hospitalization, cardiovascular incident, or unmanaged chronic condition) in the next five years.
- **Leverage this rating** to tailor patient management strategies, including personalized visit frequency with medical providers, care coordination intensity, and preventative service offerings.

## FHIR Implementation Guide Purpose

This Implementation Guide defines the standardized representation of a patient's health risk level using FHIR. It introduces:

- A new `CodeSystem` and `ValueSet` defining risk levels (`Low`, `Medium`, `High`)
- A reusable `Extension` to capture the risk rating on the `Patient` resource
- A profile on the `Patient` resource that mandates inclusion of the risk rating

This IG enables interoperability across care teams, analytics platforms, and clinical systems — ensuring that patient risk stratification is both portable and actionable.

