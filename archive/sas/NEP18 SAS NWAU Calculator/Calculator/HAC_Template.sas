/*
		+---------------------------------------------------------------------------------------------------------------------------------------------+ 
		| Name:			HAC_Template.sas																											  |		
		|																																			  |		
		| Description:	Hospital-Acquired Complications (HAC) Grouper according to criteria and categories                                            |
		|				established by the Australian Commission on Safety and Quality in Health Care (ACSQHC).                                       |
        |               For more information regarding the criteria please visit                                                                      |
        |               www.safetyandquality.gov.au/our-work/information-strategy/indicators/hospital-acquired-complications/                         |
        |                                                                                                                                             |
		|				This grouper calculates the number of occurences for each HAC. 														    	  |
		|				For more information relating to the output variables please see supporting documentation.                                    |
		|																																			  |
		| Version:		1.0																															  |
		|																																			  |		
		| Authors:		Sean Heng										                                                                              |
		|				Paul Lin									                                                                              	  |
		|				Independent Hospital Pricing Authority			                                                                              |
		+---------------------------------------------------------------------------------------------------------------------------------------------+
*/

/*=====================================================================*/
/*Stage 1: Set out relevant input and output datasets*/
/*=====================================================================*/
libname tryme "C:\Data";
data HAC_INPUT;
	set tryme.data;
run;


/*Input dataset*/
%let INPUT = HAC_INPUT;
 
/*Output dataset*/	
%let OUTPUT = HAC_OUTPUT;

/*Root location of the HAC Grouper and Reference Tables*/
%let LOCATION  = C:\Data;


/*=====================================================================*/
/*Stage 2: Set prefix for diagnosis codes, procedure codes and onset flags*/
/*=====================================================================*/

																	/*Required Format*/
/*Prefix for Procedure Array */
%let PROC_PREFIX = x09srg;											/*Character Format 'NNNNNNN'
																		Note: remove '-' */
/*Prefix for Diagnosis Array */
%let DIAG_PREFIX = x09ddx; 											/* Character Format ANN{N[N]} 
																		Note: remove '.' */
/*Prefix for Onset Array */
%let ONSET_PREFIX = onset; 											/*Character Format
																	'1' = Condition with onset during the episode of admitted patient care
																	'2' = Condition not noted as arising during the episode of admitted patient care 
																	'9' = Not reported */

%let DRG_VERSION = DRG9; 											/*Either DRG8 or DRG9*/ 
%let DRG = AN90DRG; 

%let ICD10AM_Edition=9;												/*Either 7,8,9 or 10*/		
/*=====================================================================*/
/*Stage 3: Episode Characteristics*/

/*=====================================================================*/
											/*METeOR ID*/			/*Required Format*/
%let admmode = admm;  						/*269976x */			/*Integer*/
%let care_type= care; 						/*491557*/				/*Decimal e.g. 7.1*/
%let adm_date=adm_date;
%let sep_date=sep_date;


%include "&location.\Hospital Acquired Complication Grouper.sas";
