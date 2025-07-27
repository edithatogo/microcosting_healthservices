/*
		+---------------------------------------------------------------+
		| Name:			NWAU20_TEMPLATE_ED.sas							|
		| Description:	2020-21 Emergency Department Patients			|
		|				National Weighted Activity Unit Template		|
		|				Use to set out data set for NWAU20 Calculator	|
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
%let INPUT = SAMPLE_ED;
 
/*Output dataset*/	
%let OUTPUT = ED_OUPUT;

/*Root location of the NWAU calculator*/
%let LOCATION  =  C:\Calculators;


/*Turn on debug mode to display intermediate variables
(1= Turn On; 0= Turn Off*/
%let DEBUG_MODE = 1;

/*Clear intermediate datasets
NOTE: if on, the NWAU calculator will remove all datasets beginning with "_" from the working directory
(1= Turn On; 0= Turn Off)*/

%let CLEAR_DATA = 1; 

/*=====================================================================*/
/*Stage 2: Choose Classification Option*/
/*=====================================================================*/
/*Choose option here (1 = UDG (mapped) 2 = UDG (provided) or 3 = URG or 4 = AECC (SHADOW PRICING)*/
%let CLASSIFICATION_OPTION = 3;

	/*
	Option 1 - UDG (mapped - slow)
	Provide Episode End Status, Type of Visit and Triage Category 
	*/

															/*METeOR ID*/			/*Required Format*/
	%let episode_end_status = episode_end_status;			/*551305*/				/*Integer 1-9*/
	%let type_of_visit = type_of_visit;						/*550725*/				/*Integer 1-9*/
	%let triage_category = triage_category;					/*474185*/				/*Integer 1-9*/

	/*
	Option 2 (UDG provided)
	Provide Mapped UDG 
	*/
	%let UDG = UDG;											/*Character - length 5: UDGNN*/

	/*
	Option 3 - URG v1.4
	*/

	%let URG = URG;											/*447800*/				/*Character - length 6: URGNNN*/
	
	/*
	Option 4 - AECC V1.0 - SHADOW PRICING ONLY - NOT TO BE USED FOR FUNDING 
	*/

	%let AECC = AECC;											/*Character - length 5: URGNNN*/



/*=====================================================================*/
/*Stage 3: Select required variables */
/*=====================================================================*/

/*Patient variables*/									/*METeOR ID*/			/*Required Format*/
%let INDSTAT = indstat;									/*291036*/				/*Integer 1-4*/
%let COMPENSABLE_STATUS = compstatus;					/*270100*/				/*Integer 1:Yes 2:No*/
%let DVA_STATUS = dvastatus;								/*270092*/				/*Integer 1:Yes 2:No*/
%let BIRTH_DATE = bir_date;								/*287007*/				/*Date*/
%let ADM_DATE = adm_date;								/*269967*/				/*Date*/


/*=====================================================================*/
/*Stage 4: Select other required variables */
/*=====================================================================*/

/*Patient Geographical variables*/						/*METeOR ID*/			/*Required Format*/
%let Pat_POSTCODE = pcode;							/*429894*/				/*Character PC1234	*/
%let Pat_SA2 = pat_rem;										/*469909*/				/*Integer 123456789*/

														/*Character - length 4*/

/*Establishment variables*/
%let EST_REMOTENESS = treat_rem;												/*Integer 0-4*/


/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU20_CALCULATOR_ED.sas";
