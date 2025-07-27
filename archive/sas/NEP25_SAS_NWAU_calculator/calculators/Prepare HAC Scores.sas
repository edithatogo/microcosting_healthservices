/*
		+---------------------------------------------------------------------------------------------------------------------------------------------+ 
		| Name:			Prepare HAC Scores.sas																					  					  |		
		|																																			  |		
		| Description:	Prepares flags for hospital acquired complications risk factors. Currently uses ICD-10-AM 12th edition codes.		          |
        |                                                                                                                                             |                              
		|																																			  |
		| Version:		1.0.1																														  |
		|																																			  |		
		| Authors:		Jada Ching									                                                                              	  |
		|				Matthew Hughes																												  |
		| 				Amanda Lieu																													  |
		| 																																			  |
		|				Independent Hospital Pricing Authority																						  |	
		|																																			  |	
		| Date:			Sep 2024																													  |	
		+---------------------------------------------------------------------------------------------------------------------------------------------+
*/

/******************************************************************************************************
	This program sets up the variables required to calculate a complexity score
	These are:
		-	Sex category
		-	Age (5 year age bands)
		-	Charlson Comorbidity Conditions
		-	drg10/11 type (Medical or Intervention)
		- 	MDC	
		-	Admission Transfer flag (0 or 1)
		-	ICU hours flag (0 or 1)
		-	Emergency election status terms

******************************************************************************************************/

data drg&drg_version._MASTERLIST_RA (index=(_DRG&drg_version.)); 
	set CALCREF.DRG&drg_version._MASTERLIST (rename=(	DRG&drg_version. = _DRG&drg_version. 
											mdc&drg_version. = an&drg_version.0mdc_ra));
	if _DRG&drg_version. in ("801A", "801B", "801C") then an&drg_version.0mdc_ra="23";
run;
%global achi;
%macro icd;
	%if &icd10am_edition.*1 = 7 or &icd10am_edition.*1 = 8 or &icd10am_edition.*1 = 9 %then
		%let achi = "9047002"	,	"9047004"	,	"9046800"	,	"9046801"	,	"9046802"
				,	"9046803"	,	"9046804"	,	"9046805"	,	"9046900"	,	"9046901";
	%else %if &icd10am_edition.*1 = 10 or &icd10am_edition.*1 = 11 or &icd10am_edition.*1 = 12 or &icd10am_edition.*1 = 13 %then
		%let achi = "9047002"	,	"9047004"	,	"9046800"	,	"9046801"	,	"9046802"
				,	"9046803"	,	"9046804"	,	"9046805"	,	"9046900"	,	"9046901"	,	"9046806";
%mend icd;
%icd;

data &output. (drop = _drg&drg_version.);
	set &input. (rename=(&sex. = sex_cat));

	sex=sex_cat;
	if sex_cat in ('3','9') then do;
		sex_cat = 1;
	end;

	/*Create drg type*/
	_drg&drg_version. = &drg.;
	set drg&drg_version._MASTERLIST_RA (keep = _drg&drg_version.
									drg&drg_version._type 
									an&drg_version.0mdc_ra) 
							key = _drg&drg_version. / unique;
	if _error_ ne 0 then do;
		_error_ = 0; 
		drg&drg_version._type = "";
		an&drg_version.0mdc_ra = "";
	end;

	/*Age group*/
	agegroup = floor(min(_pat_age_years,99)/5);
	if _pat_age_years = . then agegroup = .;

	/*Age group 15*/
	if _pat_age_years <= 15 then 		age_15g = 1;
	else if _pat_age_years >= 35 then 	age_15g = 3;
	else 								age_15g = 2;
	
	/*Flag ICU hours*/
	flag_ICUHours = (&ICU_HOURS. gt 0);

	/*Flag admission transfer*/
	flag_AdmTransfer = (&admmode. eq 1);	*SET TO 1 IF THE ADMISSION WAS A TRANSFER FROM ANOTHER HOSPITAL;

	/*set up arrays*/
	array SRGARRAY &PROC_PREFIX:;
	array ONSETARRAY &ONSET_PREFIX:;
	array ddxarray &DIAG_PREFIX:;

	MAXDDXVAR = dim(DDXARRAY) - cmiss(of  &DIAG_PREFIX:);
	MAXSRGVAR = max(1,dim(SRGARRAY) - cmiss(of  &PROC_PREFIX:));

	do i = 1 to MAXSRGVAR;
		if missing(SRGARRAY[i]) = 1 then MAXSRGVAR = dim(SRGARRAY); 
	end;

			flag_instrument_use = 0;
			flag_primiparity = 0;
			flag_PPOP = 0;
			flag_foetal_distress = 0;

	do i = 1 to MAXSRGVAR;
		srg = SRGARRAY[i];
	
*HAC15 risk flag;
	if srg in: ( &achi. )
			then flag_instrument_use = 1;
	end;

	do i=1 to MAXDDXVAR;
		if missing(DDXARRAY[i]) = 1 then MAXDDXVAR = dim(DDXARRAY); 
	end;

	do i = 1 to MAXDDXVAR;

		onset = ONSETARRAY[i]; 
		ddx = DDXARRAY[i];

	*CHARLSON COMORBIDITY INDEX;
	 		if DDX in: 		('I21'  ,'I22'  )																											then cc_Acute_myocardial_function = 1;
			else if DDX in: 	('I50', 'I110', 'I130', 'I132')
				or DDX in 		('U822')																												then cc_Congestive_heart_failure = 1;
			else if DDX in: ('I70', 'I71', 'I73'  )																										then cc_Peripheral_vascular_disease = 1;
			else if DDX in: ('I60'  ,'I61'  ,'I62'  ,'I63'  ,'I65'  ,'I66'  , 
							'I64'  ,'I670' ,'I671' ,'I672', 'I673' ,'I674' ,'I675' ,'I676' ,'I677' ,'I678' ,
							 'I679', 'I680' ,'I681' ,'I682' ,'I688' ,'I69'  )																			then cc_Cerebral_vascular_accident = 1;
			else if DDX in: ('F00'  ,'F01'  , 'F03', 'U791' )																							then cc_Dementia = 1;
			else if DDX in: 	('J40'  ,'J41'  ,'J42'  ,'J44'  ,'J43'  ,'J45'  ,'J46'  ,'J47'  ,'J67'  ,'J60'  ,'J61'  ,
							 'J62'  ,'J63'  ,'J66'  ,'J64'  ,'J65')
			or 	DDX in 		('U831', 'U832', 'U833', 'U834'  )																							then cc_Pulmonary_disease = 1;
			else if DDX in: 	('M30', 'M31', 'M32', 'M33', 'M34', 'M35', 'M05', 'M06', 'M36')
			or 	DDX in 		('U861', 'U863')																											then cc_Connective_tissue_disorder = 1;
			else if DDX in: ('K25'  ,'K26'  ,'K27'  ,'K28'  )																							then cc_Peptic_ulcer = 1;
			else if DDX in: 	('K700', 'K701', 'K702' ,'K703', 'K709', 'K71', 'K720', 'K73', 'K74', 'K75', 'K760', 'K761',
								'K762', 'K763', 'K764', 'K768', 'K769', 'B18')				
				and	DDX not in ('K711')  																												then cc_Liver_disease = 1;
			
			/* For diabetes without complications, the code set is all E10-14: less those codes in Diabestes_complications. */
			else if DDX in	 	('E108', 'E109', 'E118', 'E119', 'E138', 'E139', 'E148') or DDX in: ('E149')											then cc_Diabetes = 1;
			else if DDX in: ('E100', 'E101', 'E102','E103' ,'E104','E105' ,'E106', 'E107', 'E110',
							'E111' ,'E112' ,'E113' ,'E114' ,'E115' ,'E116', 'E117', 'E130',
							'E131' ,'E132' ,'E133' ,'E134' ,'E135' ,'E136', 'E137', 'E140',
							'E141' , 'E142'  ,'E143' ,'E144' ,'E145' , 'E146', 'E147')																	then cc_Diabetes_complications = 1; 
			else if DDX in: ('G81'  , 'G820' ,'G821' ,'G822' )																							then cc_Paraplegia = 1; 
			else if DDX in: ('N03'  ,'N052' ,'N053' ,'N054' ,'N055' ,'N056' ,'N072' ,'N073' ,'N074' ,'N01'  ,
							'N183', 'N184', 'N185', 'N189'
							 'N19'  ,'N25', 'I120', 'I131', 'Z490', 'Z491', 'Z492'  )		
							or DDX in  	('U871') 																										then cc_Renal_disease = 1; 
			else if DDX in: ('C0'   ,'C1'   ,'C2'   ,'C3'   ,'C40'  ,'C41'  ,'C43'  ,'C45'  ,'C46'  ,'C47'  ,'C48'  ,
							 'C49'  ,'C5'   ,'C6'   ,'C70'  ,'C71'  ,'C72'  ,'C73'  ,'C74'  ,'C75'  ,'C76'  ,'C80'  ,
							 'C81'  ,'C82'  ,'C83'  ,'C84'  ,'C85', 'C86', 'C880', 'C882'  ,'C883', 'C884' ,'C887' ,'C889' ,'C900' ,'C901'  , 'C902',
							 'C903', 'C911', 'C913', 'C914', 'C915', 'C916', 'C917', 'C918', 'C919', 'C92', 
							 'C930', 'C931', 'C933', 'C937', 'C939', 'C940' ,'C942' , 'C943', 'C944', 'C946',
							 'C947', 'C950', 'C951', 'C957', 'C959','D46'  )																					
					or DDX in ('D45') 																														then cc_Cancer = 1; 
			else if DDX in: ('C77'  ,'C78'  ,'C79'	)																									then cc_Metastatic_cancer = 1; 
			else if DDX in: 	('K704','K711','K721','K729' ,'K765','K766' ,'K767' , 'Z944' )
			or	DDX in 		('U843')																													then cc_Severe_liver_disease = 1; 
			else if DDX in: ('B20'  ,'B21'  ,'B22'  ,'B23'  ,'B24', 'R75', 'Z21'  )																		then cc_HIV = 1; 
	*More HAC15 risk factors;	
			if DDX in: 		('Z3551','Z356' )																											then flag_primiparity = 1;
			else if DDX in: ('O328'	,'O640'	)  																											then flag_PPOP = 1;
			else if DDX in: ('O68'	)																													then flag_foetal_distress = 1;
	end;

		array charlson{*} 	cc_Acute_myocardial_function
							cc_Congestive_heart_failure
							cc_Peripheral_vascular_disease
							cc_Cerebral_vascular_accident
							cc_Dementia
							cc_Pulmonary_disease
							cc_Connective_tissue_disorder
							cc_Peptic_ulcer
							cc_Liver_disease
							cc_Diabetes
							cc_Diabetes_complications
							cc_Paraplegia
							cc_Renal_disease
							cc_Cancer
							cc_Metastatic_cancer
							cc_Severe_liver_disease
							cc_HIV;

		charlson_score = 0;
		do k=1 to 17;
			charlson[k] = sum(0, charlson[k]);
			charlson_score = sum(charlson_score, charlson[k]);
		end;
		charlson_score = min(charlson_score,16);
		drop k i; 
	
	*Create flag for Emergency, Treat Emergency, Not assigned and Not Known as Emergency;
	attrib flag_emergency length = 3.;
	if &urgadm. = '2' then flag_emergency = 0;
	else flag_emergency = 1;

run;