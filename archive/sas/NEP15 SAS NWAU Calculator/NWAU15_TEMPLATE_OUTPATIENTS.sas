/*
		+---------------------------------------------------------------+
		| Name:			NWAU15_TEMPLATE_OUTPATIENTS.sas					|
		| Description:	2015-16 Outpatients								|
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
(1= Turn On; 0= Turn Off)*/
%let DEBUG_MODE = 0;

/*=====================================================================*/
/*Stage 2: Select required variables */
/*=====================================================================*/
/*Patient variables*/									/*METeOR ID*/			/*Required Format*/
%let INDSTAT = indstat;									/*291036*/				/*Integer 1-4*/
%let FUNDSC = fundingsource;							/*553314*/				/*Integer 1-13,99*/

/*Provide name of column containing multi provider flag (or set to 0/1) where: 
	1 - Yes; 2 - No; 9 - Unknown*/
%let pat_multiprov_flag=pat_multiprov_flag;										/*Integer 1 or 2 or 9*/						

/*Classification variables*/
%let TIER2_CLINIC = t2cLINIC;							/*501669*/				/*Numeric NN.NN*/

/*=====================================================================*/
/*Stage 3: Choose Inscope Funding sources*/
/*=====================================================================*/
/*MODIFY ONLY IF USING DIFFERENT CODES FOR FUNDING SOURCE*/
%let INSCOPEFS = (1,2,8);

/*=====================================================================*/
/*Stage 4:include SAS code that runs the calculator - DO NOT MODIFY*/
/*=====================================================================*/
%include "&LOCATION.\NWAU15_CALCULATOR_OUTPATIENTS.sas";