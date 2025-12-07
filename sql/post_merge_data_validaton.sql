
/* 1.VERIFY JOIN INTEGRITY
   Ensure merging did not duplicate or lose rows*/

-- Count total ICU stays before merge
SELECT COUNT(*) AS total_icustays_premerge
FROM icustays;

-- Count unique ICU stays after merge
SELECT COUNT(DISTINCT icustay_id) AS unique_icustays_postmerge
FROM icu_merged;

-- Check for any duplicated ICU stay IDs after merge
SELECT COUNT(DISTINCT icustay_id) AS distinct_icustay_ids,
       COUNT(*) AS total_rows
FROM icu_merged;

-- Check for missing key IDs (should be zero)
SELECT COUNT(*) AS null_key_rows
FROM icu_merged
WHERE icustay_id IS NULL OR hadm_id IS NULL;


/* 2.TIME CONSISTENCY CHECKS
   Validate chronological order of admissions and ICU stays*/

-- Find rows where times are out of logical order
SELECT COUNT(*) AS invalid_timestamps
FROM icu_merged
WHERE intime > outtime
   OR admittime > dischtime;


/* 3.ICU LOS VALIDATION
   Identify and remove invalid length-of-stay records */

-- Find entries where ICU LOS and OUTTIME are both missing
SELECT COUNT(*) AS null_los_outtime_count
FROM icu_merged
WHERE icu_los IS NULL
  AND outtime IS NULL;

-- Delete invalid entries (if you’re sure)
DELETE FROM icu_merged
WHERE icu_los IS NULL
  AND outtime IS NULL;


/* 4.DEATH FLAG CONSISTENCY
   Examine mismatch between hospital_expire_flag and patient expire_flag*/

SELECT hospital_expire_flag,
       expire_flag,
       COUNT(*) AS record_count
FROM icu_merged
GROUP BY hospital_expire_flag, expire_flag
ORDER BY hospital_expire_flag, expire_flag;


/* 5. AGE SANITY CHECK
   Identify unrealistic or negative ages (due to shifted DOB) */

SELECT COUNT(*) AS invalid_age_count
FROM icu_merged
WHERE EXTRACT(YEAR FROM admittime) - EXTRACT(YEAR FROM dob) < 0;


/* 6.DUPLICATE RECORD CHECK
   Detect duplicate (subject_id, hadm_id) combinations */

SELECT subject_id,
       hadm_id,
       COUNT(*) AS duplicate_count
FROM icu_merged
GROUP BY subject_id, hadm_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


/* 7. MISSING VALUE CHECK
   Examine missing values in key demographic fields */

SELECT
  SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
  SUM(CASE WHEN ethnic_group IS NULL THEN 1 ELSE 0 END) AS ethnicity_nulls
FROM icu_merged;



select count(distinct diagnosis) from icu_merged


