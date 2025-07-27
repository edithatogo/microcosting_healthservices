/*
Configuration file for the Acute Admitted NEP14 NWAU Calculator
Set RHS of the statements below to variable names in your dataset
*/

/*Input dataset*/
%let INPUT = DATA.ACUTE_EXAMPLE;
 
/*Output dataset*/	
%let OUTPUT = DATA.ACUTE_EXAMPLE_NWAU14;

/*Root location of the NWAU calculator*/
%let LOCATION  = C:\NEP14 SAS NWAU Calculators\calculator;

/*Turn on debug mode to display intermediate variables*/
%let DEBUG_MODE = 0;

/*=====================================================================*/
/*Choose option here (1 or 2)*/
%let ICU_PAED_OPTION = 1;

/*
Option 1 (slow)
Provide APC Identifier and year and the calculator will determine ICU and paediatric eligibility.
This only works for APC identifiers in years 2009-10, 2010-11 and 2011-12
You can still use data from earlier/later years but make sure the identifiers are from one of the three above
*/
%let APCID = APCID; /*of form APCIDXXXX_YYYYYYYY where XXXX is the year (below) and YYYYYYYY is the APC Establishment ID*/
%let ID_YEAR=1112; /*the only acceptable years are 0910, 1011 and 1112*/

/*
Option 2 (quicker)
Provide establishment eligible ICU and Paediatric flags (prepared earlier)
*/
%let EST_ELIGIBLE_ICU_FLAG = est_eligible_icu_flag;
%let EST_ELIGIBLE_PAED_FLAG = est_eligible_paed_flag;
/*=====================================================================*/

/*Patient Geographical variables*/
%let POSTCODE = pat_postcode;								/*Character PC1234*/
%let SLA = pat_sla;											/*Integer 12345*/

/*Classification variables*/
%let CARE_TYPE = care_type;									/*Decimal e.g. 7.1*/
%let DRG = DRG7;											/*Character - length 4*/

/*Establishment variables*/
%let STATE = est_state; 									/*Integer 1-8 (1->NSW,2->Vic,3->Qld,4->SA,5->WA,6->Tas,7->NT,8->ACT)*/
%let EST_REMOTENESS = est_remoteness;						/*Integer 0-4*/

/*Patient variables*/
%let BIRTH_DATE = birth_date;								/*Date*/
%let ADM_DATE = admission_date;								/*Date*/
%let SEP_DATE = separation_date;							/*Date*/
%let LEAVE = leave_days;									/*Integer*/
%let QLDAYS = newborn_qualified_days;						/*Integer*/
%let PSYCDAYS = psychiatric_care_days;						/*Integer*/
%let ICU_HOURS = icu_hours;									/*Integer*/

%let INDSTAT = indigenous_status;							/*Integer 1-4*/
%let FUNDSC = funding_source;								/*Integer 1-13,99*/

/*=====================================================================*/

/*Choose option here*/
%let RADIOTHERAPY_OPTION = 2;

/*Option 1 (slow)*/
/*Provide prefix of columns containing procedure codes*/
%let PROC_PREFIX = x07srg;

/*Option 2 (quicker)*/
/*provide name of column containing radiotherapy flag (or set to 0/1)*/
%let PAT_RADIOTHERAPY_FLAG = pat_radiotherapy_flag;

/*=====================================================================*/

/*Set codes for public and private funding sources */
/*MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE*/

/*IHPA DSS for 2011-12 and earlier (METeOR 339080)*/
%let PUBLICFS = (1,10,11);
%let PRIVATEFS = (2,3);

/*IHPA DSS for 2012-13 and later (METeOR 472033)*/
/*%let PUBLICFS = (1,2,3,8);*/
/*%let PRIVATEFS = (9,13);*/

/*=====================================================================*/

/*include SAS code that runs the calculator - DO NOT MODIFY*/
%inc "&LOCATION.\NWAU14_CALCULATOR_ACUTE.sas";