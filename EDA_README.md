# 📊 Exploratory Data Analysis (EDA)

## ICU Survival Analysis - MIMIC-III Dataset

This document provides detailed exploratory data analysis of the ICU patient cohort, examining mortality patterns, length of stay distributions, and demographic relationships.

---

## 📋 Table of Contents

- [Dataset Overview](##dataset-overview)
- [Mortality Analysis](#mortality-analysis)
- [Length of Stay Analysis](#length-of-stay-analysis)
- [Demographic Patterns](#demographic-patterns)
- [Clinical Characteristics](#clinical-characteristics)
- [Key Findings](#key-findings)

---

## 📊 Dataset Overview

**Final Analysis Dataset:** 61,289 ICU stays

**Key Statistics:**
- **Overall Mortality Rate:** 39.2% (24,034 deaths)
- **Mean Age:** 55.6 years (SD = 26.9)
- **Median ICU LOS:** 2.09 days
- **Median Hospital LOS:** 6.9 days
- **Gender Distribution:** Relatively balanced (M/F)

**Data Sources:**
- CareVue: 61.5% of records
- MetaVision: 38.5% of records

**Missing Data:**
- Death-related fields: Expected (only present for deceased patients)
- Diagnosis: 4 records (<0.01%)
- No missing data in key demographic or clinical variables

---

##  Mortality Analysis

### Overall Mortality Patterns

<img width="1189" height="489" alt="download" src="https://github.com/user-attachments/assets/c26fafd6-24d8-49c2-88d4-6528c2038cda" />

**Two Types of Mortality Examined:**

1. **In-Hospital Mortality:** 10.6% (6,494 deaths during hospitalization)
2. **Overall Mortality:** 39.2% (includes both in-hospital and post-discharge deaths)

The substantial difference highlights the importance of post-discharge follow-up and long-term survival analysis.

---

### Mortality by Age

<img width="566" height="460" alt="download" src="https://github.com/user-attachments/assets/990d1911-d397-4524-8cd8-f5a8111010a9" />

**Statistical Test:** Independent samples t-test
- **t-statistic:** -131.163
- **p-value:** <0.001 (highly significant)

**Interpretation:**
- Deceased patients significantly older than survivors
- Mean age difference indicates age as a critical mortality predictor
- Clear separation between survival groups

---

### Mortality by Diagnosis Category

<img width="850" height="693" alt="download" src="https://github.com/user-attachments/assets/0a0cd308-7390-4675-87b7-176b8888cf1f" />

**Highest Risk Diagnoses:**

| Diagnosis Category | Mortality Rate |
|--------------------|----------------|
| **Failure to Thrive / Misc** | 76.5% |
| **Respiratory Failure / Pulmonary** | 60.5% |
| **Sepsis / Infection** | 57.9% |
| **Oncology** | 48.4% |
| **Neurological** | 47.2% |
| **GI / Hepatic / Pancreatic** | 47.4% |

**Lowest Risk Diagnoses:**

| Diagnosis Category | Mortality Rate |
|--------------------|----------------|
| **Newborn / Pediatric** | 0.8% |
| **Toxic / Substance Related** | 11.8% |
| **Trauma / Surgical** | 30.1% |
| **Other** | 37.6% |

**Key Insight:** Respiratory conditions and sepsis carry 6-7x higher mortality risk compared to pediatric or trauma cases.

---

### Mortality by Care Unit

<img width="850" height="426" alt="download" src="https://github.com/user-attachments/assets/1d58f0eb-c052-404b-bb97-e0aa1eb9d8a8" />

**Care Unit Risk Stratification:**

- **MICU (Medical ICU):** Highest mortality (~45%)
- **CCU (Coronary Care):** High mortality (~42%)
- **SICU (Surgical ICU):** Moderate mortality (~35%)
- **TSICU (Trauma/Surgical):** Moderate mortality (~32%)
- **CSRU (Cardiac Surgery Recovery):** Low mortality (~15%)
- **NICU (Neonatal ICU):** Lowest mortality (~1%)

**Interpretation:** Specialized surgical/recovery units show better outcomes than medical ICUs treating acute, unplanned conditions.

---

### Mortality by Admission Type

<img width="571" height="460" alt="download" src="https://github.com/user-attachments/assets/aac38b56-6a28-48ff-a300-7e59f5544194" />

**Risk by Admission Context:**
- **Emergency:** 40-45% mortality (highest)
- **Urgent:** 35-40% mortality
- **Elective:** 8-12% mortality (lowest)
- **Newborn:** <2% mortality

**Clinical Implication:** Planned, elective admissions allow for optimization and risk reduction.

---

### Mortality by Demographics

#### Ethnicity

<img width="578" height="531" alt="download" src="https://github.com/user-attachments/assets/29831693-68ba-4b3e-83da-948848d0a9f7" />

**Observations:**
- Relatively similar mortality rates across ethnic groups (35-43%)
- Unknown ethnicity group shows slightly higher mortality (~43%)
- No dramatic disparities, though small differences may warrant further investigation

---

#### Gender

<img width="580" height="460" alt="download" src="https://github.com/user-attachments/assets/723ef8a2-4aff-4796-93da-452ec7d03cb9" />

**Findings:**
- Minimal difference between male and female mortality
- Both groups approximately 38-40% mortality
- Gender not a strong independent predictor in this cohort

---

## 🏥 Length of Stay Analysis

### ICU Length of Stay Distribution

<img width="2146" height="1190" alt="hist_iculos_distribution" src="https://github.com/user-attachments/assets/7088db78-ead3-499a-aea4-b59b545104f8" />

**Distribution Characteristics:**
- **Highly right-skewed:** Most patients stay <5 days
- **Median:** 2.09 days
- **Mean:** 4.92 days (pulled up by outliers)
- **Range:** 0.0001 to 173 days
- **Outliers:** Small number of extended stays (>30 days)

**Interpretation:** Majority of ICU stays are brief, but complex cases can extend significantly.

---

### Hospital Length of Stay Distribution

<img width="2119" height="1190" alt="hist_hosplos_distribution" src="https://github.com/user-attachments/assets/bb5f3609-8a22-47a6-b0b6-a806c871d6cd" />

**Distribution Characteristics:**
- **Also right-skewed** but less extreme than ICU LOS
- **Median:** 6.9 days
- **Mean:** 11.3 days
- **Range:** 0.1 to 294 days
- **Pattern:** Sharp peak at 3-10 days, long tail

---

### LOS vs Mortality

#### Hospital LOS vs In-Hospital Mortality

<img width="622" height="398" alt="download" src="https://github.com/user-attachments/assets/05715b96-ad06-4ea3-9447-f277f0877286" />

**Findings:**
- Both survivors and non-survivors show similar median LOS
- Slight tendency for longer stays in survivors (stabilization before discharge)
- Wide variability in both groups
- Some very long stays (>100 days) in both outcomes

#### ICU LOS vs In-Hospital Mortality

<img width="622" height="398" alt="download" src="https://github.com/user-attachments/assets/ed4d6884-e2bd-4e48-9e7b-6d5880dc3187" />

**Findings:**
- Very similar ICU LOS distributions for survivors vs non-survivors
- Median ICU LOS slightly higher in survivors (~2-3 days vs 1-2 days)
- Early deaths don't accumulate long ICU stays
- Survivor bias: patients who live longer in ICU are stabilizing

---

## 👥 Demographic Patterns

### Age Distribution by Diagnosis

<img width="3461" height="2539" alt="box_diagVSage" src="https://github.com/user-attachments/assets/59818e71-5752-4a1f-9a36-578967db3c67" />

**Age Profiles by Diagnosis:**

**Oldest Patients:**
- **Failure to Thrive / Misc:** Median ~75 years
- **Cardiac / Vascular:** Median ~70 years
- **Neurological:** Median ~65-70 years

**Youngest Patients:**
- **Newborn / Pediatric:** Median ~0 years (by definition)
- **Toxic / Substance Related:** Median ~40 years
- **Trauma / Surgical:** Median ~55 years

**Clinical Insight:** Age patterns align with epidemiology - cardiac disease peaks in elderly, substance issues in younger adults, trauma spans all ages.

---

### Age vs ICU Length of Stay

<img width="622" height="475" alt="download" src="https://github.com/user-attachments/assets/b37c1768-6e40-46fd-a09b-4cbbfbda693b" />

**Correlation Analysis:**
- **No strong linear relationship** between age and ICU LOS
- Vertical clustering at age ~0 (neonates) with variable LOS
- Most adults (20-80 years) have ICU stays <25 days
- Extreme LOS outliers (>100 days) occur across age spectrum
- Newborns show longest stays due to prematurity/development needs

**Interpretation:** Disease severity and diagnosis drive LOS more than age alone.

---

### ICU LOS Distribution (Log-transformed)

<img width="571" height="460" alt="download" src="https://github.com/user-attachments/assets/14164d58-f524-4161-a99e-6d2acde60b65" />

**Purpose:** Log transformation reduces right-skew for clearer comparison

**Observations:**
- Deceased patients (expire_flag=1) show slightly lower log(LOS)
- Survivors have marginally longer ICU stays
- Reflects survivor bias: early deaths don't accumulate days
- Distributions largely overlapping

---

## 🏥 Clinical Characteristics

### Diagnosis Category Validation

**Cross-tabulation: Diagnosis Category vs First Care Unit**

<img width="837" height="439" alt="image" src="https://github.com/user-attachments/assets/526bb0d4-7247-4b80-9381-9f6c4c80822c" />

This validates our diagnosis categorization by comparing it to the patient's admitted care unit:

**Expected Alignments:**
- **Cardiac/Vascular → CCU/CSRU:** 70% correctly aligned
- **Newborn/Pediatric → NICU:** 100% correctly aligned
- **Respiratory → MICU:** 71% in medical ICU (expected)
- **Trauma/Surgical → TSICU/SICU:** 82% in surgical units
- **Neurological → SICU/MICU:** Distributed (brain injury/stroke treated in both)

**Conclusion:** Diagnosis categorization is clinically valid and aligns with care unit assignments.

---

## 🔍 Key Findings Summary

### 1. Age is a Major Mortality Driver
- Highly significant difference between survivors (younger) and non-survivors (older)
- Each additional year increases risk
- Age >80 shows dramatically worse outcomes

### 2. Diagnosis Category Strongly Predicts Outcome
- **Respiratory failure:** 60.5% mortality (highest among common diagnoses)
- **Sepsis/Infection:** 57.9% mortality
- **Newborn conditions:** <1% mortality (lowest)
- **Trauma/Surgical:** 30% mortality (better prognosis with intervention)

### 3. ICU Unit Type Matters
- Medical ICUs (MICU, CCU) have 2-3x higher mortality than surgical ICUs
- CSRU (cardiac surgery recovery) has excellent outcomes (15% mortality)
- Reflects patient selection: elective surgery vs acute medical crisis

### 4. Admission Context Impacts Risk
- Emergency admissions: 40-45% mortality
- Elective admissions: 8-12% mortality
- Urgent admissions: Intermediate risk
- Pre-optimization matters

### 5. Length of Stay is Right-Skewed
- Most patients: Short ICU/hospital stays (median 2-7 days)
- Small proportion: Extended stays (>30 days)
- LOS doesn't directly correlate with mortality in simple analysis

### 6. Demographics Show Minimal Disparities
- Gender: No significant difference
- Ethnicity: Relatively similar rates (35-43%)
- Age and diagnosis overwhelm demographic factors

### 7. ICU LOS Paradox
- Deceased patients have slightly shorter ICU stays
- Reflects survivor bias: early deaths don't accumulate days
- Not causal: long stays don't cause survival
- Patients who stabilize stay longer before discharge

---

## 📈 Implications for Survival Analysis

These EDA findings inform our survival modeling approach:

1. **Age must be included** as continuous predictor (strong linear effect)
2. **Diagnosis category is critical** - use as categorical predictor
3. **Admission type** should be included (emergency vs elective)
4. **Care unit** may add predictive value beyond diagnosis
5. **ICU LOS** should be interpreted carefully due to survivor bias
6. **Gender and ethnicity** can be controlled for but may not be strong predictors
7. **Time-varying effects** likely important (early vs late mortality)

---

## 🔗 Next Steps

After completing EDA, proceed to:
1. **Survival Analysis:** Kaplan-Meier curves and Cox PH modeling
2. **Risk Stratification:** Develop mortality prediction models
3. **Subgroup Analysis:** Focus on high-risk populations
4. **Feature Engineering:** Create interaction terms, severity scores

See main [README.md](README.md) for complete project documentation.

---

**Note:** This EDA provides descriptive statistics and visualizations. Formal hypothesis testing and predictive modeling are conducted in subsequent analyses.
