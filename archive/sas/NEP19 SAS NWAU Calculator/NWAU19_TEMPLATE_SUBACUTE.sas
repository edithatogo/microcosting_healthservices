/*
		+---------------------------------------------------------------+
		| Name:			NWAU19_TEMPLATE_SUBACUTE.sas					|
		| Description:	2019-20 Subacute Admitted Patients				|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU19 Calculator	|
		|				Set RHS of the statements to variable names in 	|
		|				the input dataset								|
		| Version:		1.0												|
		| Author:														|
		|				Pricing Section									|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/

/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/*Input dataset*/
%let INPUT =SA_INPUT;
 
/*Output dataset*/	
%let OUTPUT = SA_OUTPUT;

/*Root location of the NWAU calculator*/
%let LOCATION  = I:\004 NEP19\01 Calculators;

/*Turn on debug mode to display intermediate variables (0 or 1)*/
%let DEBUG_MODE = 1;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA=1; 

/*=====================================================================*/
/*Stage 3: Choose Radiotherapy Option*/
/*=====================================================================*/

/*Choose option here (1 or 2)*/
%let RADIOTHERAPY_OPTION = 2;

/*Option 1 (slow)*/
/*Provide prefix of columns containing procedure codes*/
%let PROC_PREFIX = x09srg;

/*Option 2 (quicker)*/
/*provide name of column containing radiotherapy flag (or set to 0/1)*/
%let PAT_RADIOTHERAPY_FLAG =PAT_RADIOTHERAPY_FLAG;

/*=====================================================================*/
/*Stage 4: Choose Dialysis Option*/
/*=====================================================================*/
/*Choose option here (1 or 2)*/
%let DIALYSIS_OPTION = 2;

/*Option 1 (slow)*/
/*Provide prefix of columns containing procedure codes*/
%let PROC_PREFIX = x09srg;

/*Option 2 (quicker)*/
/*provide name of column containing dialysis flag (or set to 0/1)*/
%let PAT_DIALYSIS_FLAG = pat_dialysis_flag;

/*=====================================================================*/
/*Stage 2: Choose Codes for Public and Private Funding Sources*/
/*=====================================================================*/
/*MODIFY ONLY IF USING DIFFERENT CODES FOR PUBLIC AND PRIVATE FUNDING SOURCE*/

/*IHPA DSS for 2011-12 and earlier (METeOR 339080)*/
/*%let PUBLICFS = (1,10,11);*/
/*%let PRIVATEFS = (2,3);*/

/*IHPA DSS for 2012-13 and later (METeOR 472033)*/
%let PUBLICFS = (1,2,8);
%let PRIVATEFS = (9,13);


/*=====================================================================*/
/*Stage 3: Select other required variables */
/*=====================================================================*/

/*Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/
%let Pat_POSTCODE = Postcode;							/*429894*/				/*Character PC1234	*/
%let Pat_SA2=SA2;										/*469909*/				/*Integer 123456789*/
%let Pat_SLA = SLA;										/*455542*/				/*Integer 12345*/

/*Classification variables*/
%let CARE_TYPE = Caretype;								/*270174*/				/*Decimal e.g. 7.1*/
%let ANSNAP_V4 = SNAPV4;															/*Character - length 4 e.g. 4AZ1*/

/*Establishment variables*/
%let STATE = STATE; 									/*286919*/				/*Integer 1-8 (1->NSW,2->Vic,3->Qld,4->SA,5->WA,6->Tas,7->NT,8->ACT)*/
%let EST_REMOTENESS = hosp_RA11;												/*Integer 0-4*/

/*Patient variables*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date*/
%let ADM_DATE = adm_date;								/*269967, 445848*/				/*Date*/ 
%let SEP_DATE = sep_date;								/*270025, 445598*/				/*Date*/
%let LEAVE = leave;										/*270251*/				/*Integer*/
%let INDSTAT = indstat;									/*291036*/				/*Integer 1-4*/
%let FUNDSC = fundingsource;							/*553314*/				/*Integer 1-13,99*/

/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU19_CALCULATOR_SUBACUTE.sas";