/*
		+---------------------------------------------------------------+
		| Name:			NWAU16_TEMPLATE_ACUTE.sas						|
		| Description:	2016-17 Acute Admitted Patients					|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU16 Calculator	|
		|				Set RHS of the statements to variable names in 	|
		|				the input dataset								|
		| Version:		1.0												|
		| Author:		Sean Heng										|
		|				Mathematical Statistical Analyst				|
		|				Pricing Section									|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/


/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/*Input dataset*/
%let INPUT =ACUTE_INPUT;
 
/*Output dataset*/	
%let OUTPUT = ACUTE_OUTPUT;

/*Root location of the NWAU calculator*/
%let LOCATION  = C:\SAS Calculators;

/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off)*/
%let DEBUG_MODE = 1;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA=1; 


/*=====================================================================*/
/*Stage 2: Choose ICU and Paediatric Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/
%let ICU_PAED_OPTION = 2;

/*
Option 1 (slow)
Provide APC Identifier and year and the calculator will determine ICU and paediatric eligibility.
This only works for APC identifiers in years 2009-10, 2010-11, 2011-12, 2012-13 and 2013-14
You can still use data from earlier/later years but make sure the identifiers are from one of the four above
*/
%let APCID = estid; /*of form YYYYYYYY where YYYYYYYY is the APC Establishment ID*/
%let ID_YEAR=1314; /*the only acceptable years are 0910, 1011, 1112, 1213 and 1314*/

/*
Option 2 (quicker)
Provide establishment eligible ICU and Paediatric flags (prepared earlier)
*/
%let EST_ELIGIBLE_ICU_FLAG = est_eligible_icu_flag;
%let EST_ELIGIBLE_PAED_FLAG = est_eligible_paed_flag;

/*=====================================================================*/
/*Stage 3: Choose Radiotherapy Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/
%let RADIOTHERAPY_OPTION = 2;

/*Option 1 (slow)*/
/*Provide prefix of columns containing procedure codes*/
%let PROC_PREFIX = x08srg;

/*Option 2 (quicker)*/
/*provide name of column containing radiotherapy flag (or set to 0/1)*/
%let PAT_RADIOTHERAPY_FLAG =PAT_RADIOTHERAPY_FLAG;

/*=====================================================================*/
/*Stage 4: Choose Dialysis Option*/
/*=====================================================================*/
/*Choose option her (1 or 2)*/
%let DIALYSIS_OPTION = 2;

/*Option 1 (slow)*/
/*Provide prefix of columns containing procedure codes*/
%let PROC_PREFIX = x08srg;

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
%let INSCOPE_CARE = (1,7);


/*=====================================================================*/
/*Stage 7: Select other required variables */
/*=====================================================================*/

/*Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/
%let Pat_POSTCODE = Postcode;							/*429894*/				/*Character PC1234	*/
%let Pat_SA2=SA2;										/*469909*/				/*Integer 123456789*/
%let Pat_SLA = SLA;										/*455542*/				/*Integer 12345*/

/*Classification variables*/
%let CARE_TYPE = Caretype;								/*270174*/				/*Decimal e.g. 7.1*/
%let DRG = AN80DRG;																/*Character - length 4*/

/*Establishment variables*/
%let STATE = STATE; 									/*286919*/				/*Integer 1-8 (1->NSW, 2->Vic, 3->Qld, 4->SA, 5->WA, 6->Tas, 7->NT, 8->ACT)*/
%let EST_REMOTENESS = hosp_RA11;												/*Integer 0-4*/

/*Patient variables*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date*/
%let ADM_DATE = adm_date;								/*269967*/				/*Date*/
%let SEP_DATE = sep_date;								/*270025*/				/*Date*/
%let LEAVE = leave;										/*270251*/				/*Integer*/
%let QLDAYS = qldays;									/*270033*/				/*Integer*/
%let PSYCDAYS = psycdays;								/*552375*/				/*Integer*/
%let ICU_HOURS = losinicu;								/*471553*/				/*Integer*/

%let INDSTAT = indstat;									/*291036*/				/*Integer 1-4*/
%let FUNDSC = fundingsource;							/*553314*/				/*Integer 1-13,99*/

/*=====================================================================*/
/*Stage 8: include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU16_CALCULATOR_ACUTE.sas";
