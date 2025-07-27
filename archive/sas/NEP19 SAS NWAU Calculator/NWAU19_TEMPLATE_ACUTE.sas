
/*
		+---------------------------------------------------------------------------+
		| Name:			Risk Adjusted NWAU19 Calculator TEMPLATE.sas					|
		| Description:	2019-20 Acute Admitted Patients								|
		|				Risk Adjusted National Weighted Activity Unit Template		|
		|				Set RHS of the statements to variable names in the input	|
		|				dataset.													|
		| Version:		1.2													     	|
		| Author:		Pricing Section												|
		|				Independent Hospital Pricing Authority						|
		| Date:			July 2020												    |
		+---------------------------------------------------------------------------+
*/

%let LOCATION = C:\Calculators;

/*Input dataset*/
%let CALCULATOR_INPUT = DATA.SAMPLE_INPUT;
 
/*Output dataset*/	
%let CALCULATOR_OUTPUT = DATA.SAMPLE_OUTPUT;

/*Set prefix for diagnosis codes, procedure codes and onset flags*/

%let PROC_PREFIX = x09srg; /* ie. variables are x09srg01 to x09srg50 */
%let DIAG_PREFIX = x09ddx; /* ie. variables are x09ddx01 to x09ddx100 */
%let ONSET_PREFIX = onset; /* ie. variables are onset01 to onset100   */

/*Episode Characteristics*/
											/*METeOR ID*/			/*Required Format*/
%let admmode = admm;  						/*269976x */			/*Interger Numeric*/

%let DRG=DRG9;
%let ICD10AM_Edition=10;						/*7,8,9,10 or 11*/

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA=1; 

/*Choose option here (1 or 2)*/
%let ICU_PAED_OPTION = 1;

/*
Option 1 (slow)
Provide APC Identifier and year and the calculator will determine ICU and paediatric eligibility.
*/
%let APCID = estid; /*of form YYYYYYYY where YYYYYYYY is the APC Establishment ID*/
%let ID_YEAR=1516; 

/*
Option 2 (quicker)
Provide establishment eligible ICU and Paediatric flags (prepared earlier)
*/
%let EST_ELIGIBLE_ICU_FLAG = est_eligible_icu_flag;
%let EST_ELIGIBLE_PAED_FLAG = est_eligible_paed_flag;

/*=====================================================================*/
/*Stage 2: Choose Covid flag Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/
%let COVID_OPTION = 1;

/*Option 2 (quicker)*/
%let PAT_COVID_FLAG = covid_flag;

/*=====================================================================*/
/*Stage 3: Choose Radiotherapy Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/
%let RADIOTHERAPY_OPTION = 1;

/*Option 2 (quicker)*/
/*provide name of column containing radiotherapy flag (or set to 0/1)*/
%let PAT_RADIOTHERAPY_FLAG =PAT_RADIOTHERAPY_FLAG;

/*=====================================================================*/
/*Stage 4: Choose Dialysis Option*/
/*=====================================================================*/
/*Choose option her (1 or 2)*/
%let DIALYSIS_OPTION = 1;

/*Option 2 (quicker)*/
/*provide name of column containing dialysis flag (or set to 0/1)*/
%let PAT_DIALYSIS_FLAG = pat_dialysis_flag;

/*=====================================================================*/
/*Stage 5: Choose Codes for Public and Private Funding Sources*/
/*=====================================================================*/
/*MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE*/

/*IHPA DSS for 2011-12 and earlier (METeOR 339080)*/
/*%let PUBLICFS = (1,10,11);*/
/*%let PRIVATEFS = (2,3);*/

/*IHPA DSS for 2012-13 and later (METeOR 472033)*/
%let PUBLICFS = (1,2,8);
%let PRIVATEFS = (9,13);

/*=====================================================================*/
/*Stage 6: Choose Corresponding Inscope Caretype*/
/*=====================================================================*/
/*MODIFY ONLY IF USING DIFFERENT CODES FOR CARETYPE*/

/*METeOR 270174: Required Format Integer 123456789 */
%let INSCOPE_CARE = (1,7,11);

/*=====================================================================*/
/*Stage 7: Define Hospital Remoteness*/
/*=====================================================================*/

/*provide hospital remoteness*/
%let EST_REMOTENESS = hosp_RA;												/*Integer 0-4*/

/*=====================================================================*/
/*Stage 7: Select other required variables */
/*=====================================================================*/

/*Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/
%let Pat_POSTCODE = Postcode;							/*429894*/				/*Character PC1234	*/
%let Pat_SA2 = SA2;										/*469909*/				/*Integer 123456789*/
%let Pat_SLA = SLA;										/*455542*/				/*Integer 12345*/

/*Classification variables*/
%let CARE_TYPE = Care;								/*270174*/				/*Decimal e.g. 7.1*/
										
/*Establishment variables*/
%let STATE = STATE; 									/*286919*/				/*Integer 1-8 (1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT)*/

/*Patient variables*/
%let BIRTH_DATE = birthdate;								/*287007*/				/*Date*/
%let ADM_DATE = admdate;								/*269967*/				/*Date*/
%let SEP_DATE = sepdate;								/*270025*/				/*Date*/
%let LEAVE = leave;										/*270251*/				/*Integer*/
%let QLDAYS = qldays;									/*270033*/				/*Integer*/
%let PSYCDAYS = psycdays;								/*552375*/				/*Integer*/
%let ICU_HOURS = icuhours;								/*471553*/				/*Integer*/
%let ICU_OTHER = icuother;								/*471553*/				/*Integer*/

%let INDSTAT = indstat;								/*291036*/				/*Integer 1-4*/
%let FUNDSC = fundsc;							/*649391*/				/*Integer 1-13*/				
%let urgadm = urgadm;									/*269986*/			    /*Character 1239*/

%let sex=sex;											/*635126*/				/*Character 1239*/

/*Debug mode to display intermediate variables
(1 = Turn On; 0 = Turn Off)*/
%let DEBUG_MODE = 0;

/*=====================================================================*/
/*Stage 8: Choose risk adjustment option */
/*=====================================================================*/

/* Choose risk adjustment option here:
0, no risk adjustment is performed;
1, hospital acquired complications (HACs) are identified and then risk adjustment is performed;
2, the user provides the HAC flags by specifying HAC_PREFIX and risk adjustment is performed accordingly.*/
%let risk_adjustment = 1;

/*Option 2: risk_adjustment = 2 */
%let HAC_PREFIX = HACFLAG; /* ie. variables are HACFLAG01 to HACFLAG16 */

/* Include the HAC grouper outcome in the output dataset 
(1 = Include; 0 = Exclude)*/
%let keep_hacs = 1;

/* Include the complexity scores in the output dataset 
(1 = Include; 0 = Exclude)*/
%let keep_points = 1;

/* Run Risk Adjusted NWAU Calculator */
%include "&location.\NWAU19_ADJUSTED_CALCULATOR_ACUTE.sas"; 
