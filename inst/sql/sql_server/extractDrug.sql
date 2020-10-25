IF OBJECT_ID('@target_database_schema.@drug_exposure_table', 'U') IS NOT NULL
DROP TABLE @target_database_schema.@drug_exposure_table;

CREATE TABLE @target_database_schema.@drug_exposure_table(
    subject_id VARCHAR(255),
    cohort_start_date DATE,
    drug_exposure_start_date DATE,
    drug_concept_id VARCHAR(255),
    ancestor_concept_id VARCHAR(255),
    concept_name VARCHAR(255)
);

INSERT INTO @target_database_schema.@drug_exposure_table(subject_id, cohort_start_date, drug_exposure_start_date, drug_concept_id, ancestor_concept_id, concept_name)

SELECT DISTINCT SUBJECT_ID, cohort_start_date, drug_exposure_start_date, drug_concept_id, ancestor_concept_id, concept_name FROM @target_database_schema.@target_cohort_table
JOIN @cdm_database_schema.drug_exposure ON @target_cohort_table.SUBJECT_ID=@cdm_database_schema.drug_exposure.person_id
JOIN @cdm_database_schema.concept_ancestor ON drug_exposure.drug_concept_id = @cdm_database_schema.concept_ancestor.descendant_concept_id
JOIN @cdm_database_schema.concept ON @cdm_database_schema.concept_ancestor.ancestor_concept_id=@cdm_database_schema.concept.concept_id
WHERE COHORT_DEFINITION_ID = @target_cohort_id
and @cdm_database_schema.drug_exposure.drug_exposure_start_date <= DATEADD(day, 7, CAST(@target_database_schema.@target_cohort_table.cohort_start_date AS DATE))
and @cdm_database_schema.drug_exposure.drug_exposure_start_date >= @target_database_schema.@target_cohort_table.cohort_start_date
and drug_concept_id != 0
and concept_class_id = 'Ingredient';
