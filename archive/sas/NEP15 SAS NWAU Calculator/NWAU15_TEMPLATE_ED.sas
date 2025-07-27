/*
		+---------------------------------------------------------------+
		| Name:			NWAU15_TEMPLATE_ED.sas							|
		| Description:	2015-16 Emergency Department Patients			|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU15 Calculator	|
		|				Set RHS of the statements to variable names in 	|
		|				the input dataset								|
		| Version:		1.0												|
		| Author:		Sean Heng										|
		|				Pricing and Efficiency Analyst					|
		|				Technical Pricing and Funding Models Section	|
		|				Independent Hospital Pricing Authority			|
		+---------------------------------------------------------------+
*/

/*=====================================================================*/
/*Stage 1: Set out relevant datasets*/
/*=====================================================================*/

/*Input dataset*/
%let INPUT =INPUT_DATA;
 
/*Output dataset*/	
%let OUTPUT = OUTPUT_DATA;

/*Root location of the NWAU calculator*/
%let LOCATION  =  C:\SAS Calculators;

/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off*/
%let DEBUG_MODE = 1;

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
%let INDSTAT = indstat;									/*291036*/				/*Integer 1-4*/
%let COMPENSABLE_STATUS = compstatus;					/*270100*/				/*Integer 1:Yes 2:No*/
%let DVA_STATUS = dvapat;								/*270092*/				/*Integer 1:Yes 2:No*/

/*Classification variables*/
/*URG V1.4*/
%let URG = URG;											/*447800*/				/*Character - length 6: URGNNN*/

/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU15_CALCULATOR_ED.sas";