/*
		+---------------------------------------------------------------+
		| Name:			NWAU19_TEMPLATE_ED.sas							|
		| Description:	2019-20 Emergency Department Patients			|
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
%let INPUT = CHECKING.ED_CHECK;
 
/*Output dataset*/	
%let OUTPUT = ED_OUPUT;

/*Root location of the NWAU calculator*/
%let LOCATION  =  I:\004 NEP19\01 Calculators;


/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off*/
%let DEBUG_MODE = 1;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA=1; 

/*=====================================================================*/
/*Stage 2: Choose UDG Option*/
/*=====================================================================*/
/*Choose option here (1 or 2)*/
%let UDG_OPTION = 1;

/*
Option 1 (slow)
Provide Episode End Status, Type of Visit and Triage Category 
*/

														/*METeOR ID*/			/*Required Format*/
%let episode_end_status = eddepst;			/*551305*/				/*Integer 1-9*/
%let type_of_visit = edvisit;						/*550725*/				/*Integer 1-9*/
%let triage_category = edtriag;					/*474185*/				/*Integer 1-9*/

/*
Option 2 (quicker)
Provide Mapped UDG 
*/
%let UDG = UDGv1p3;											/*Character - length 5: UDGNN*/


/*=====================================================================*/
/*Stage 3: Select required variables */
/*=====================================================================*/

/*Patient variables*/									/*METeOR ID*/			/*Required Format*/
%let INDSTAT = indstat;									/*291036*/				/*Integer 1-4*/
%let COMPENSABLE_STATUS = compstatus;					/*270100*/				/*Integer 1:Yes 2:No*/
%let DVA_STATUS = dvapat;								/*270092*/				/*Integer 1:Yes 2:No*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date*/
%let ADM_DATE = adm_date;								/*269967*/				/*Date*/

/*Classification variables*/
/*URG V1.4*/
%let URG = URGv1p3;											/*447800*/				/*Character - length 6: URGNNN*/

/*=====================================================================*/
/*Stage 4: Select other required variables */
/*=====================================================================*/

/*Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/
%let Pat_POSTCODE = pcode;							/*429894*/				/*Character PC1234	*/
%let Pat_SA2=ASGS;										/*469909*/				/*Integer 123456789*/
%let Pat_SLA = SLA;										/*455542*/				/*Integer 12345*/

														/*Character - length 4*/

/*Establishment variables*/
%let EST_REMOTENESS = RA2011;												/*Integer 0-4*/


/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU19_CALCULATOR_ED.sas";
