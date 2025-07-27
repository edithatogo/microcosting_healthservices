/*
		+---------------------------------------------------------------+
		| Name:			NWAU18_TEMPLATE_ED.sas							|
		| Description:	2018-19 Emergency Department Patients			|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU15 Calculator	|
		|				Set RHS of the statements to variable names in 	|
		|				the input dataset								|
		| Version:		1.0												|
		| Author:		Thomas Connor									|
		|				Technical Manager								|
		|				Pricing Section									|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
/*


/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/*Input dataset*/
%let INPUT =ED;
 
/*Output dataset*/	
%let OUTPUT = ED_NWAU;

/*Root location of the NWAU calculator*/
%let LOCATION  =  I:\Working\003 NEP18\09 NWAU Calculators\01 SAS Calculators\02 FINAL NEP18\01 Calculators;

/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off*/
%let DEBUG_MODE = 0;

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
%let episode_end_status = episode_end_status;			/*551305*/				/*Integer 1-9*/
%let type_of_visit = type_of_visit;						/*550725*/				/*Integer 1-9*/
%let triage_category = triage_category;					/*474185*/				/*Integer 1-9*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date*/
%let ADM_DATE = adm_date;								/*269967*/				/*Date*/

/*
Option 2 (quicker)
Provide Mapped UDG 
*/
%let UDG = UDG;											/*Character - length 5: UDGNN*/


/*=====================================================================*/
/*Stage 3: Select required variables */
/*=====================================================================*/

/*Patient variables*/									/*METeOR ID*/			/*Required Format*/
%let INDSTAT = indstatnum;									/*291036*/				/*Integer 1-4*/
%let COMPENSABLE_STATUS = compstatusnum;					/*270100*/				/*Integer 1:Yes 2:No*/
%let DVA_STATUS = dvapatnum;								/*270092*/				/*Integer 1:Yes 2:No*/

/*Classification variables*/
/*URG V1.4*/
%let URG = URG;											/*447800*/				/*Character - length 6: URGNNN*/

/*Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/
%let Pat_POSTCODE = Postcode;							/*429894*/				/*Character PC1234	*/
%let Pat_SA2=ASGS_num;										/*469909*/				/*Integer 123456789*/
%let Pat_SLA = SLA;										/*455542*/				/*Integer 12345*/

														/*Character - length 4*/
/*Establishment variables*/
%let EST_REMOTENESS = hosp_RA11;												/*Integer 0-4*/


/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU18_CALCULATOR_ED.sas";