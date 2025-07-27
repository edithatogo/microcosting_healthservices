/*
		+---------------------------------------------------------------+
		| Name:			NWAU17_TEMPLATE_ED.sas							|
		| Description:	2017-18 Emergency Department Patients			|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU15 Calculator	|
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
%let INPUT =ED_INPUT;
 
/*Output dataset*/	
%let OUTPUT = ED_OUTPUT_17;

/*Root location of the NWAU calculator*/
%let LOCATION  = I:\Products\NWAUs Calculators\NEP17 SAS NWAU Calculator\01 Calculators;

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
%let episode_end_status = episode_end_status;			/*551305*/				/*Integer 1-9*/
%let type_of_visit = type_of_visit;						/*550725*/				/*Integer 1-9*/
%let triage_category = triage_category;					/*474185*/				/*Integer 1-9*/

/*
Option 2 (quicker)
Provide Mapped UDG 
*/
%let UDG = UDG;											/*Character - length 5: UDGNN*/


/*=====================================================================*/
/*Stage 3: Select required variables */
/*=====================================================================*/

/*Patient variables*/									/*METeOR ID*/			/*Required Format*/
%let INDSTAT = indigenous_status;									/*291036*/				/*Integer 1-4*/
%let COMPENSABLE_STATUS = compensable_status;					/*270100*/				/*Integer 1:Yes 2:No*/
%let DVA_STATUS = dva_status;								/*270092*/				/*Integer 1:Yes 2:No*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date*/
%let ADM_DATE = adm_date;								/*269967*/				/*Date*/

/*Classification variables*/
/*URG V1.4*/
%let URG = URG;											/*447800*/				/*Character - length 6: URGNNN*/

/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU17_CALCULATOR_ED.sas";