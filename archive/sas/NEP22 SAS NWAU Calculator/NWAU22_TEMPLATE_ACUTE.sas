/*
		+---------------------------------------------------------------------------+
		| Name:			Risk Ajusted NWAU22 Calculator TEMPLATE.sas					|
		| Description:	2022-23 Acute Admitted Patients								|
		|				Risk Adjusted National Weighted Activity Unit Template		|
		|				Set RHS of the statements to variable names in the input	|
		|				dataset.													|
		| Version:		1.0															|
		| Author:		Mireille Regan Gomm											|
		|				Pricing Section												|
		|				Independent Hospital Pricing Authority						|
		| Date:			November 2021												|
		+---------------------------------------------------------------------------+

*/

/* Provide the location of the parameters you would like to use for this run of the calculator. The call to the calculator itself is on the
	last line */

%let LOCATION = CALC_LOCATION ;

/*Input dataset*/

%let CALCULATOR_INPUT = SAMPLE_INPUT ;
 
/*Output dataset*/

%let CALCULATOR_OUTPUT = SAMPLE_OUTPUT ;

/*Set prefix for diagnosis codes, procedure codes and onset flags*/

%let PROC_PREFIX = x11srg ; /* ie. variables are x10srg01 to x10srg50 */

%let DIAG_PREFIX = x11ddx ; /* ie. variables are x10ddx01 to x10ddx100 */

%let ONSET_PREFIX = onset ; /* ie. variables are onset01 to onset100   */

/*Episode Characteristics*/

											/*METeOR ID*/			/*Required Format*/

/* Admission mode: Mechanism by which a person begins an episode of care. */

%let admmode = admm ;  						/* 269976 */			/* Integer Numeric 1, 2 or 3. */

/* Name of the variable containing each record's DRG. */

%let DRG = DRG10 ;

/* DRG version begin used */

%let DRG_VERSION = 10 ;

/* ICD version begin used */

%let ICD10AM_Edition = 11 ;					/*07, 08, 09, 10, 11 or 12*/

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all intermediate datasets from the working directory
(1 = Turn On; 0 = Turn Off)*/

%let CLEAR_DATA = 1 ; 

/*Choose option here (1 or 2)*/

%let ICU_PAED_OPTION = 1 ;

/*
Option 1 (slow)
Provide APC Identifier and year and the calculator will determine ICU and paediatric eligibility.
*/

%let APCID = estid; /*of form YYYYYYYY where YYYYYYYY is the APC Establishment ID*/

%let ID_YEAR = 1920 ;

/*
Option 2 (quicker)
Provide establishment eligible ICU and Paediatric flags (prepared earlier)
*/

%let EST_ELIGIBLE_ICU_FLAG = est_eligible_icu_flag ;

%let EST_ELIGIBLE_PAED_FLAG = est_eligible_paed_flag ;

/*=====================================================================*/
/*Stage 2: Choose COVID flag Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/

/* Option 1 requires the user to provide diagnosis codes with the prefix &DIAG_PREFIX. (defined above). The calculator will determine whether the patient
	was treated as a COVID patient on the basis of these codes. This is slower than option 2. */

%let COVID_OPTION = 1 ;

/*Option 2 requires the user to provide a variable,saved to the macro &PAT_COVID_FLAG. defined below, indicating whether the patient is treated for COVID-19
	( &PAT_COVID_FLAG. = 1) or not ( &PAT_COVID_FLAG. = 0). */

%let PAT_COVID_FLAG = covid_flag ;

/*=====================================================================*/
/*Stage 3: Choose Radiotherapy Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/

/* Option 1 requires the user to provide procedure codes with the prefix &PROC_PREFIX. (defined above). The calculator will determine whether the patient 
	underwent radiotherapy treatment on the basis of these codes. This is slower than option 2. */

%let RADIOTHERAPY_OPTION = 1 ;

/* Option 2 requires the user to provide a variable, with name saved to the macro &PAT_RADIOTHERAPY_FLAG. defined below, indicating whether the patient 
	underwent radiotherapy treatment ( &PAT_RADIOTHERAPY_FLAG. = 1 ) or not ( &PAT_RADIOTHERAPY_FLAG. = 0 ). */

%let PAT_RADIOTHERAPY_FLAG = PAT_RADIOTHERAPY_FLAG ;

/*=====================================================================*/
/*Stage 4: Choose Dialysis Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/

/* Option 1 requires the user to provide procedure codes with the prefix &PROC_PREFIX. (defined above). The calculator will determine whether the patient 
	underwent dialysis treatment on the basis of these codes. This is slower than option 2. */

%let DIALYSIS_OPTION = 1 ;

/* Option 2 requires the user to provide a variable, with name saved to the macro &PAT_DIALYSIS_FLAG. defined below, indicating whether the patient underwent
	dialysis treatment ( &PAT_DIALYSIS_FLAG. = 1 ) or not ( &PAT_DIALYSIS_FLAG. = 0 ). */

%let PAT_DIALYSIS_FLAG = pat_dialysis_flag ;

/*=====================================================================*/
/*Stage 5: Choose Codes for Public and Private Funding Sources*/
/*=====================================================================*/

/*MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE*/

/*IHPA DSS for 2011-12 and earlier (METeOR 339080)*/
/*%let PUBLICFS = (1, 10, 11);*/
/*%let PRIVATEFS = (2, 3);*/

/*IHPA DSS for 2012-13 and later (METeOR 472033)*/

/* Public funding sources: If the funding source variable (defined below) is equal to one of the values below then the patient may receive a nonzero NWAU
	and will receive no private patient deductions. */

%let PUBLICFS = (1, 2, 8) ;

/* Public funding sources: If the funding source variable (defined below) is equal to one of the values below then the patient may receive a nonzero NWAU
	and will incur a private patient deduction. */

%let PRIVATEFS = (9, 13) ;

/* Private Patient Service Adjustment Options. Choose 1 for 'nation-level' or 2 for 'juristiction-level'. Option 2 is that being used from NEP22. */

%let PPSERVADJ = 2 ;

/*=====================================================================*/
/*Stage 6: Choose Corresponding In-scope Caretype*/
/*=====================================================================*/

/*MODIFY ONLY IF USING DIFFERENT CODES FOR CARE TYPE*/

/*METeOR 270174: Required Format Integer 123456789 */

%let INSCOPE_CARE = (1, 7);

/*=====================================================================*/
/*Stage 7: Hospital Remoteness Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)

Option 1: Use APC Identifier to determine hospital remoteness.*/

%let EST_REMOTENESS_OPTION = 1 ;

/*Option 2*/

/*provide hospital remoteness*/							/*METeOR ID*/			/*Required Format*/

%let EST_REMOTENESS = hosp_RA16 ;						/* 539871 */			/*Integer 0-4*/

/*=====================================================================*/
/*Stage 8: Select other required variables */
/*=====================================================================*/

/* Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/

%let Pat_POSTCODE = Postcode;							/* 611398 */			/*Character PC1234	*/

%let Pat_SA2 = SA2;										/* 659825 */			/*Integer 0-4 */

/* Care classification variables */

%let CARE_TYPE = Caretype ;								/* 711010 */			/*Decimal e.g. 7.1*/
										
/* Establishment variables*/

%let STATE = STATE ; 									/* 720078 */			/*Integer 1-8 (1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT)*/

/*** Patient characteristic variables ***/

/* Patient birth date */

%let BIRTH_DATE = bir_date ;							/* 287007 */			/*Date*/

/* Admission date */

%let ADM_DATE = adm_date ;								/* 695137 */			/*Date*/

/* Separation date */

%let SEP_DATE = sep_date ;								/* 270025 */			/*Date*/

/* Leave days */

%let LEAVE = leave ;									/* 270251 */			/*Integer*/

/* Qualified leave days */

%let QLDAYS = qldays ;									/* 722649 */			/*Integer*/

/* psychiatric care days */

%let PSYCDAYS = psycdays ;								/* 722678 */			/*Integer*/

/* Length of stay in level 3 ICU facility */

%let ICU_HOURS = losiculvl3 ;							/* 731473 */			/*Integer*/

/* Length of stay in non-level 3 ICU facility. This is only relevant for patients with COVID 19. Otherwise this variable does not need to be defined in your
	data set in which case it will default to zero. */

%let ICU_OTHER = icuother ;								/* 731473 */			/*Integer*/

/* Patient Indigenous status */

%let INDSTAT = indstat ;								/* 602543 */			/*Integer 1-4*/

/* Funding source */

%let FUNDSC = fundingsource;							/* 679815 */			/*Integer 1-13*/				

/* Admission urgency status. This is only used if the user is implementing one or both of the risk adjustment options. */

%let urgadm = urgadm ;									/* 686084 */		    /* Character 1, 2, 3 or 9 */

/* Sex. This is only used if the user is implementing one or both of the risk adjustment options */

%let sex = sex ;										/*635126*/				/* Character 1, 2, 3 or 9 */

/*Debug mode to display intermediate variables
(1 = Turn On; 0 = Turn Off)*/

%let DEBUG_MODE = 1 ;

/*=====================================================================*/
/*Stage 9: Choose risk adjustment option */
/*=====================================================================*/

/* Choose risk adjustment option here:
0, no risk adjustment is performed;
1, hospital acquired complications (HACs) are identified and then risk adjustment is performed;
2, the user provides the HAC flags by specifying HAC_PREFIX and risk adjusment is performed accordingly.*/

%let risk_adjustment = 1 ;

/*Option 2: risk_adjustment = 2 */

%let HAC_PREFIX = HACFLAG ; /* ie. variables are HACFLAG01 to HACFLAG16 & HACFLAG15P1P2*/

/* Include the HAC grouper outcome in the output dataset 
(1 = Include; 0 = Exclude)*/

%let keep_hacs = 1;

/* Include the comlexity scores in the output dataset 
(1 = Include; 0 = Exclude)*/

%let keep_points = 1;

/*=====================================================================*/
/*Stage 10: Choose Readmissions risk adjustment option */
/*=====================================================================*/

/* Choose risk adjustment option here:
0, no risk adjustment is performed;
1, Avoidable readmissions are identified and then risk adjustment is performed;
2, the user provides the readmissions flags by specifying ahr_prefix and risk adjusment is performed accordingly.*/

%let readmissions = 1;

%let ahr_prefix = ahr;

%let EP_ID = stateid;

%let EST_ID = estid;

%let HACFLAG = ; /* If the HAC risk_adjustment option above is 0, please specify a flag to determine if the episode has a HAC */

/* Option 1: readmissions 1 */

%let UNIQUE_ID = medicare_pin;

%let SEP_MODE = sep_mode;							/*722644*/				/* Character 10, 21, 22, 30, 40, 50, 60, 70, 80 or 90 */
													/*270094*/				/* Character 1, 2, 3, 4, 5, 6, 7, 8 or 9 */

/*Option 2: readmissions = 2 */

%let W01_READM = ; /* If the user provides the readmissions flags, they must also provide the w01 price of the associated readmission */

/* 	PAST_ADMISSIONS_OPTION: Choose option for the admissions in the previous year risk factor
	1: Calculate based on previous data (must have PREV_YEAR_ID_FILE and UNIQUE_ID fields populated),
	2: User provided (must populate ADM_PREV_YEAR_INPUT field below),
	3: Not given (assume 0 admissions in the previous year) */

%let PAST_ADMISSIONS_OPTION = 1;

%let PREV_YEAR_ACTIVITY_FILE = patient_prev; /* File with ADM_DATE and UNIQUE_ID for the year preceeding the input data year*/

%let ADM_PREV_YEAR_INPUT = var ; /* Requred for PAST_ADMISSIONS_OPTION = 2 */

/*	Whether or not to keep a list of trimmed episodes;*/

%let keep_trim = 0;

/*	Define trimmed episodes output*/

%let trimout = output.trimmed;

/* Readmissions scorer option: Choose whether to execute readmissions risk scorer as a python script or compiled executable (x86)
	1: Use compiled executable: compiled for x86, requires all executables and dll's in in &LOCATION.\Scorer_v3 to be whitelisted
	2: Call python script directly: Requires python 3, and modules 'pandas', 'numpy' and 'lightgbm'.  */

%let scorerOption = 2;

/*Scorer Option 1: use compiled executable*/

%let scorerPath = &LOCATION.\Scorer_v3;  /*Path to scorer program - defaults to scorer in calculator folder*/

/*Scorer option 2: run python 3 script directly*/

%let pythonExecutable = C:\ProgramData\Anaconda3\python.exe; /*path to python3 executable*/

/* Include the readmissions grouper outcome in the output dataset 
(1 = Include; 0 = Exclude)*/

%let keep_readms = 1;

/* Run Risk Adjusted NWAU Calculator */

%include "&location.\NWAU22_ADJUSTED_CALCULATOR_ACUTE.sas"; 