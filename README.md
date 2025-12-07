# 🏥 ICU Survival Analysis Using MIMIC-III

**Survival Patterns | Mortality Drivers | Post-Discharge Outcomes**

This project analyzes ICU patient survival using the publicly available MIMIC-III Critical Care Dataset. The goal is to understand in-hospital vs post-discharge mortality, length of stay, and clinical & demographic factors influencing survival using classical survival analysis techniques.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Data Pipeline](#data-pipeline)
- [Survival Analysis Results](#survival-analysis-results)
- [Key Findings](#key-findings)
- [Usage](#usage)
- [Related Documentation](#related-documentation) 
- [Future Work](#future-work)
- [Acknowledgments](#acknowledgments)

---

## 🎯 Overview

**Research Questions:**
- What is the in-hospital mortality rate for ICU patients?
- How do age, diagnosis, and ICU unit type affect survival?
- Which factors are the strongest predictors of mortality?

**Methods:**
- Kaplan-Meier survival curves for non-parametric survival estimation
- Cox Proportional Hazards regression for multivariate risk modeling
- Stratified analysis by age, diagnosis, and ICU unit type

---

## 📊 Dataset

**MIMIC-III (Medical Information Mart for Intensive Care III)**
- De-identified health data from ICU patients at Beth Israel Deaconess Medical Center
- **Note:** Raw MIMIC-III files are NOT included in this repository due to data use agreements

**How to Access MIMIC-III:**
1. Complete CITI "Data or Specimens Only Research" course
2. Create PhysioNet account: https://physionet.org/register/
3. Request access: https://physionet.org/content/mimiciii/
4. Sign data use agreement (approval within 1-2 weeks)
5. Download the following files to your `data/raw/` folder:
   - `ADMISSIONS.csv` 
   - `ICUSTAYS.csv` 
   - `PATIENTS.csv`

**More Info:** See [MIMIC-III Documentation](https://mimic.mit.edu/docs/iii/)

---

## 📁 Project Structure

```
icu-survival-analysis/
├── notebooks/
│   ├── 1_clean_admissions.ipynb           # Ethnicity & marital status standardization
│   ├── 2_clean_icu_stays.ipynb            # Remove batch effects, ICU unit analysis
│   ├── 3_clean_patients.ipynb             # Date validation, mortality flags
│   ├── 4_mimic_id_consistency.ipynb       # Cross-dataset ID alignment
│   ├── 7_feature_engineering.ipynb        # Age calculation, diagnosis grouping
│   └── 8_survival_analysis.ipynb          # Kaplan-Meier & Cox PH modeling
├── data/
│   ├── raw/                               # Place your MIMIC-III CSVs here (not included)
│   ├── processed/                         # Cleaned individual tables
│   └── final/
│       └── SA_icu_final.csv               # Analysis-ready (53,122 adults)
├── sql/
│   ├── schema.sql                         # PostgreSQL schema with FKs
│   ├── merge_tables.sql                   # JOIN all three tables
│   └── post_merge_validation.sql          # Data quality checks
├── SA_plots/                              # Survival curve visualizations
│   ├── KMC_Overall_Survival.png
│   ├── KMC_InHospital_Survival.png
│   ├── KMC_Top6_DiagCat.png
│   └── KMC_Age_Bins.png
├── README.md
├── EDA_README.md                          # Exploratory Data Analysis (separate doc)
└── requirements.txt
```

---

## 🛠️ Installation

```bash
# Install required packages
pip install pandas numpy matplotlib seaborn scipy lifelines scikit-learn psycopg2-binary
```

---

## 🧹 Data Cleaning Pipeline

### 1. Admissions Data Cleaning (`clean_admissions.ipynb`)

**Dataset:** 58,976 hospital admissions

**Cleaning steps:**

#### Ethnicity Standardization
- Consolidated 41 ethnicity categories into 7 major groups:
  - `WHITE` (41,325 records)
  - `BLACK` (5,785 records)
  - `HISPANIC` (2,128 records)
  - `ASIAN` (2,007 records)
  - `OTHER` (1,763 records)
  - `UNKNOWN` (5,896 records)
  - `NATIVE/PACIFIC` (72 records)

#### Marital Status Grouping
- Simplified 8 categories into 5 meaningful groups:
  - `MARRIED` (24,239 records)
  - `SINGLE` (13,254 records)
  - `WIDOWED` (7,211 records)
  - `DIVORCED/SEPARATED` (3,784 records)
  - `UNKNOWN/OTHER` (10,488 records)

#### Time Spent Calculation
- Computed hospital length of stay: `DISCHTIME - ADMITTIME`
- Removed records with negative time differences (data entry errors)
- Validated all discharge times occur after admission times

#### Key Variables Retained
- `SUBJECT_ID` - Patient identifier
- `HADM_ID` - Hospital admission identifier
- `ADMITTIME` - Admission timestamp
- `DISCHTIME` - Discharge timestamp
- `DEATHTIME` - Death timestamp (if applicable)
- `ADMISSION_TYPE` - Emergency, Elective, Urgent, Newborn
- `INSURANCE` - Medicare, Private, Medicaid, Government, Self Pay
- `MARITAL_STATUS` - Standardized categories
- `DIAGNOSIS` - Primary diagnosis
- `HOSPITAL_EXPIRE_FLAG` - In-hospital mortality indicator (0/1)
- `ETHNIC_GROUP` - Standardized ethnicity

**Mortality by Admission Type:**
| Admission Type | % Survived | % Died |
|----------------|-----------|---------|
| Emergency | 87.08% | **12.92%** |
| Urgent | 87.95% | **12.05%** |
| Elective | 97.44% | 2.56% |
| Newborn | 99.21% | 0.79% |

---

### 2. ICU Stays Data Cleaning (`clean_icu_stays.ipynb`)

**Dataset:** 61,532 ICU stays → 61,396 after cleaning

**Cleaning steps:**

#### Database Source Filtering
- Identified three data sources: `carevue` (61.4%), `metavision` (38.4%), `both` (0.2%)
- Removed 136 records with `DBSOURCE = 'both'` due to potential batch effects
- Validated consistency in length of stay distributions across sources

#### ICU Unit Analysis
- **First Care Units:** MICU, CSRU, CCU, SICU, TSICU, NICU
- Analyzed patient transfer patterns between units
- Most patients remained in same care unit (diagonal dominance in crosstab)

#### Key Variables Retained
- `SUBJECT_ID` - Patient identifier (links to admissions)
- `HADM_ID` - Hospital admission identifier
- `ICUSTAY_ID` - Unique ICU stay identifier
- `INTIME` - ICU admission timestamp
- `OUTTIME` - ICU discharge timestamp
- `DBSOURCE` - Data collection system
- `LOS` - Length of stay in ICU (days)
- `FIRST_CAREUNIT` - Initial ICU unit type

**Data Quality Notes:**
- **No duplicate ICU stays:** All `ICUSTAY_ID` values are unique
- **Multiple ICU stays per patient:** 14,984 patients had multiple ICU admissions
- Most frequent patient: 41 ICU stays

---

### 3. Patients Data Cleaning (`clean_patients.ipynb`)

**Dataset:** 46,520 unique patients

**Cleaning steps:**

#### Date of Birth and Death Validation
- Converted `DOB` and `DOD` to datetime format
- Verified all expired patients (`EXPIRE_FLAG = 1`) have recorded death dates
- Validated that no death dates occur before birth dates
- **No data quality issues found** - all temporal relationships are logical

#### Mortality Statistics
- **Deceased patients:** 15,759 (33.9%)
- **Surviving patients:** 30,761 (66.1%)
- All deceased patients have complete death date information

#### Key Variables Retained
- `SUBJECT_ID` - Unique patient identifier
- `GENDER` - Patient gender (M/F)
- `DOB` - Date of birth
- `DOD` - Date of death (if applicable)
- `EXPIRE_FLAG` - Overall mortality indicator (0/1)

---

### 4. Cross-Dataset ID Consistency (`mimic_id_consistency_cleaning.ipynb`)

**Purpose:** Ensure referential integrity across all three datasets

**Initial State:**
- Admissions: 58,878 records
- ICU Stays: 61,396 records  
- Patients: 46,520 records

**Consistency Issues Identified:**

#### HADM_ID Alignment
- **84 HADM_IDs** in ICU stays missing from admissions (removed from ICU data)
- **1,284 HADM_IDs** in admissions missing from ICU stays (removed from admissions)
- These represent either data entry errors or incomplete linkages

#### SUBJECT_ID Alignment
- **182 SUBJECT_IDs** in patients table with no corresponding admissions or ICU stays
- Likely patients who visited the hospital but were not admitted or did not enter ICU
- Removed to maintain dataset consistency

**Final Cleaned Datasets:**
- **Admissions:** 57,594 records (↓ 1,284)
- **ICU Stays:** 61,312 records (↓ 84)
- **Patients:** 46,338 unique patients (↓ 182)

**Validation Results:**
```
✓ HADM_IDs present in ICU but missing in Admissions: 0
✓ HADM_IDs present in Admissions but missing in ICU: 0
✓ SUBJECT_IDs present in Admissions but missing in Patients: 0
✓ SUBJECT_IDs present in ICU but missing in Patients: 0
```

**Key Achievement:**
- **Perfect referential integrity** across all three datasets
- All 46,338 patients have complete admission and ICU stay records
- No orphaned records or broken foreign key relationships

---

### 5. Database Schema & Data Merging (SQL)

#### Schema Definition (`schema.sql`)

Created a normalized relational database with proper foreign key constraints linking patients, admissions, and ICU stays tables.

#### Table Merging (`merge_tables.sql`)

Combined all three tables into a comprehensive `icu_merged` table containing patient demographics, admission details, and ICU stay information. Result: 61,302 ICU stays with complete information.

#### Post-Merge Validation (`post_merge_validation.sql`)

Performed 7 comprehensive data quality checks:
1. Join integrity verification
2. Temporal consistency validation
3. ICU length of stay validation
4. Death flag consistency checks
5. Age sanity validation
6. Duplicate detection
7. Missing value analysis

All validation checks passed successfully.

---

### 6. Feature Engineering (`feature_engineering.ipynb`)

**Dataset:** 61,302 records → 61,290 after final cleaning

**Features Created:**

#### 1. Age at Admission
- Computed from date of birth and admission time
- **HIPAA Adjustment:** 2,713 patients aged >300 years recoded to 90 (actual age >89)
- Critical predictor for mortality risk

#### 2. Post-Discharge Survival Time
- Time from hospital discharge to death (`days_to_death`)
- Removed 12 records with negative values (data quality issues)
- NULL for patients who survived (censored observations)

#### 3. Event Flag for Survival Analysis
- Binary indicator: 1 = death occurred, 0 = censored (alive)
- Used for Kaplan-Meier and Cox regression models
- **Event rate:** 39.2% (24,034 deaths out of 61,290)

#### 4. Diagnosis Categorization

**Problem:** 14,622 unique diagnosis codes (too granular for modeling)

**Solution:** Created 12 major diagnostic categories using hierarchical regex pattern matching

| Category | Count | Examples |
|----------|-------|----------|
| CARDIAC / VASCULAR | 17,355 | Heart failure, MI, chest pain |
| NEWBORN / PEDIATRIC | 7,937 | Newborn, premature |
| GASTROINTESTINAL / HEPATIC | 6,659 | GI bleed, liver disease |
| NEUROLOGICAL | 6,593 | Stroke, seizure, altered mental status |
| RESPIRATORY / PULMONARY | 6,052 | Pneumonia, COPD, respiratory failure |
| OTHER | 5,850 | Unclassified diagnoses |
| SEPSIS / INFECTION | 4,271 | Sepsis, UTI, cellulitis |
| TRAUMA / SURGICAL | 2,420 | Falls, fractures, accidents |
| ONCOLOGY | 2,128 | Cancer, tumors |
| RENAL / METABOLIC | 1,382 | Kidney failure, DKA |
| TOXIC / SUBSTANCE RELATED | 558 | Overdose, withdrawal |
| FAILURE TO THRIVE / MISC | 85 | General debility |

**Output:** `icu_final_cleaned.csv` - Ready for survival analysis

---

## 📊 Survival Analysis (`survival_analysis.ipynb`)

### Study Population Selection

**Inclusion/Exclusion Criteria:**

Starting with 61,290 ICU stays, applied the following filters:

1. **Adults Only:** Excluded patients <18 years old (8,155 excluded)
2. **Organ Donors:** Removed 13 organ donor cases  
3. **Final Cohort:** 53,122 adult ICU stays from 38,388 unique patients

**Why keep all ICU stays?** Many patients have multiple ICU admissions, and each stay represents an independent survival trajectory. Analyzing all stays captures the full complexity of critical care outcomes.

### Event Definitions

Created two distinct survival endpoints:

#### 1. In-Hospital Mortality (`event_inhospital`)
Death occurring during hospitalization based on hospital records and death timing.

**Results:**
- Events: 6,513 in-hospital deaths (12.26%)
- Censored: 46,609 patients (87.74%)

#### 2. Post-Discharge Mortality (`event_postdischarge`)
Death occurring after hospital discharge for patients who survived hospitalization.

**Results:**
- Events: 17,443 post-discharge deaths (32.84%)
- Censored: 35,679 patients (67.16%)

### Time Variables

- **Overall survival:** Days from admission until death or last follow-up
- **Hospital survival:** Length of hospital stay
- **Post-discharge survival:** Days from discharge to death

---

### Kaplan-Meier Survival Curves

#### Overall Survival

<img width="2539" height="1407" alt="KMC_Overall_Survival" src="https://github.com/user-attachments/assets/2008d374-d206-4ad9-a5c3-ea5df565c95a" />


**Key Observations:**
- Steep initial decline: ~15% mortality within first 100 days
- Median survival: ~1,000 days (2.7 years)
- Long-term survival: ~5% at 4,000+ days
- Demonstrates high early mortality risk in ICU patients

---

#### In-Hospital Survival

<img width="2074" height="1407" alt="KMC_InHospital_Survival" src="https://github.com/user-attachments/assets/8a23e30e-58f0-4643-aae9-100bbdebba9d" />

**Key Observations:**
- Rapid initial mortality during acute phase
- Most deaths occur within first 50 days of hospitalization
- 87.74% censoring rate indicates most patients survive to discharge
- Confidence intervals widen over time as patient numbers decrease

---

#### Survival by Diagnosis Category (Top 6)

<img width="2670" height="1765" alt="KMC_Top6_DiagCat" src="https://github.com/user-attachments/assets/13da27ca-a17b-4343-ab2b-06fcc74c1f08" />

**Mortality Risk Ranking (In-Hospital):**
1. **Respiratory Failure/Pulmonary** - Steepest decline, worst prognosis
2. **Sepsis/Infection** - High early mortality
3. **Cardiac/Vascular** - Moderate mortality
4. **GI/Hepatic/Pancreatic** - Better intermediate survival
5. **Neurological** - Best long-term survival among top 6
6. **Other** - Variable outcomes

**Clinical Interpretation:**
- Respiratory and infectious conditions carry highest acute mortality risk
- Neurological conditions show better survival past acute phase
- Cardiac cases have steady mortality throughout hospital stay

---

#### Survival by Age Group

<img width="2370" height="1765" alt="KMC_Age_Bins" src="https://github.com/user-attachments/assets/c33b8722-81ad-47bc-85ed-275e4c527bfc" />

**Age-Stratified Mortality:**
- **<40 years:** Best survival (~65% at 300 days)
- **40-60 years:** Good survival (~37% at 150 days)
- **60-80 years:** Moderate survival (~15% long-term)
- **80+ years:** Worst survival (~18% at 200 days, then drops to 0%)

**Key Insight:** Age is a powerful predictor of ICU mortality. The 80+ group shows dramatically worse outcomes, with near-complete mortality by 200 days.

---

### Cox Proportional Hazards Model

**Model Performance:**
- Concordance Index: **0.70** (good discrimination)
- 53,122 observations, 23,956 events
- Cluster-robust SEs by patient ID

**Significant Risk Factors:**

| Variable | Hazard Ratio | 95% CI | Interpretation |
|----------|--------------|--------|----------------|
| **Age** (per year) | 1.03 | [1.03, 1.03] | +3% risk per year*** |
| **ICU LOS** (per day) | 0.95 | [0.95, 0.95] | -5% risk (stabilization effect)*** |
| **Emergency admission** | 1.17 | [1.10, 1.24] | +17% risk vs elective*** |
| **Urgent admission** | 1.17 | [1.05, 1.31] | +17% risk vs elective*** |
| **Respiratory diagnosis** | 1.25 | [1.18, 1.32] | +25% risk vs cardiac*** |
| **Neurological diagnosis** | 1.14 | [1.06, 1.21] | +14% risk vs cardiac*** |
| **Trauma/Surgical diagnosis** | 0.81 | [0.74, 0.90] | -19% risk (protective)*** |
| **CSRU unit** | 0.51 | [0.48, 0.54] | -49% risk vs CCU*** |
| **TSICU unit** | 0.67 | [0.63, 0.72] | -33% risk vs CCU*** |
| **SICU unit** | 0.71 | [0.67, 0.75] | -29% risk vs CCU*** |

***: p < 0.001

**Not Significant:**
- Gender (HR=1.01, p=0.52)
- GI/Hepatic, Oncology, Renal/Metabolic, Sepsis diagnoses

---

## 🔍 Key Findings

### 1. Age is the Strongest Predictor
- Linear 3% increase in mortality per year
- Patients >80 have dramatically worse outcomes
- Critical for care planning and resource allocation

### 2. Diagnosis-Driven Risk
- Respiratory failure: +25% mortality (highest risk)
- Neurological conditions: +14% mortality
- Trauma/surgical: -19% mortality (protective, likely younger patients)

### 3. ICU Specialization Matters
- Cardiac surgery ICU (CSRU): 49% lower risk (elective, optimized care)
- Medical ICU (MICU): Similar to coronary care unit
- Surgical ICUs show better outcomes than medical ICUs

### 4. Emergency Admissions Carry Excess Risk
- 17% higher mortality than elective admissions
- Reflects higher acuity and lack of optimization
- Highlights value of preventive care

### 5. Post-Discharge Mortality is Substantial
- 33% die after hospital discharge
- Median survival: 2.7 years
- Underscores need for transition care programs

---

## 🚀 Usage

### Complete Pipeline

```bash
# Step 1-4: Clean individual datasets
jupyter notebook notebooks/1_clean_admissions.ipynb
jupyter notebook notebooks/2_clean_icu_stays.ipynb
jupyter notebook notebooks/3_clean_patients.ipynb
jupyter notebook notebooks/4_mimic_id_consistency.ipynb

# Step 5: Merge in PostgreSQL
psql -d mimic3 -f sql/schema.sql
psql -d mimic3 -c "\COPY patients FROM 'cleaned_patients.csv' CSV HEADER"
psql -d mimic3 -c "\COPY admissions FROM 'cleaned_admissions.csv' CSV HEADER"
psql -d mimic3 -c "\COPY icustays FROM 'cleaned_icustays.csv' CSV HEADER"
psql -d mimic3 -f sql/merge_tables.sql
psql -d mimic3 -f sql/post_merge_validation.sql

# Step 6-7: Feature engineering and survival analysis
jupyter notebook notebooks/7_feature_engineering.ipynb
jupyter notebook notebooks/8_survival_analysis.ipynb
```

### Load Analysis-Ready Data

```python
import pandas as pd
from lifelines import KaplanMeierFitter, CoxPHFitter

# Load final dataset
df = pd.read_csv('data/final/SA_icu_final.csv')

# Quick summary
print(f"ICU stays: {len(df):,}")
print(f"Unique patients: {df['subject_id'].nunique():,}")
print(f"Deaths: {df['event'].sum():,} ({df['event'].mean()*100:.1f}%)")
print(f"Mean age: {df['age'].mean():.1f} years")

# Kaplan-Meier curve
km = KaplanMeierFitter()
km.fit(df['time_overall'], event_observed=df['event'])
km.plot_survival_function()
```

---

## 📊 Related Documentation

For detailed exploratory data analysis including:
- **Mortality patterns** by age, diagnosis, care unit, admission type, and demographics
- **Length of stay distributions** (ICU and hospital) with right-skewed patterns
- **Age vs diagnosis relationships** showing distinct age profiles across conditions
- **Care unit characteristics** and mortality rates by ICU type
- **Statistical comparisons** (t-tests for age differences between survivors/non-survivors)
- **Diagnosis category validation** via cross-tabulation with care unit assignments
- **10+ visualizations** with clinical interpretations

**See:** [EDA_README.md](./EDA_README.md)

---

## 📈 Future Work

- **Time-Varying Covariates:** Incorporate dynamic vital signs and lab values
- **Machine Learning:** Random survival forests, gradient boosted models
- **Competing Risks:** Model cause-specific mortality
- **External Validation:** Test on eICU or ANZICS databases
- **Readmission Modeling:** Predict and prevent ICU readmissions

---

## 🙏 Acknowledgments

- **MIMIC-III Database:** Johnson, A., Pollard, T., & Mark, R. (2016). MIMIC-III Clinical Database (version 1.4). PhysioNet.
- **MIT Laboratory for Computational Physiology**
- **PhysioNet** for providing open-access critical care data

---

## 📄 License

This project is for educational and research purposes. The MIMIC-III dataset requires credentialed access and has its own usage agreement.

---

## 📧 Contact

Questions or collaboration? Open an issue or contact [joellearns64@gmail.com].

---

**Note:** This project is for educational and research purposes. Findings should be validated in clinical settings before application.
