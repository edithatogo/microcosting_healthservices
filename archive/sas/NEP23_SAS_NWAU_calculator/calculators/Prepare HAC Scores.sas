
/******************************************************************************************************
	This program sets up the variables required to calculate a complexity score
	These are:
		-	Gender
		-	Age (5 year age bands)
		-	Charlson Score (1 to 10)
		-	drg11 type (Medical or Intervention)
		- 	MDC	
		-	Admission Transfer flag (0 or 1)
		-	ICU hours flag (0 or 1)
		-	Emergency election status terms

******************************************************************************************************/

data drg11_MASTERLIST_RA (index=(_drg11)); 
	set CALCREF.drg11_MASTERLIST (rename=(	drg11 = _drg11 
											mdc11 = an110mdc_ra));
	if _drg11 in ("801A", "801B", "801C") then an110mdc_ra="23";
run;
%global achi;
%macro icd;
	%if &icd10am_edition.*1 = 7 or &icd10am_edition.*1 = 8 or &icd10am_edition.*1 = 9 %then
		%let achi = "9047002"	,	"9047004"	,	"9046800"	,	"9046801"	,	"9046802"
				,	"9046803"	,	"9046804"	,	"9046805"	,	"9046900"	,	"9046901";
	%else %if &icd10am_edition.*1 = 10 or &icd10am_edition.*1 = 11 or &icd10am_edition.*1 = 12 %then
		%let achi = "9047002"	,	"9047004"	,	"9046800"	,	"9046801"	,	"9046802"
				,	"9046803"	,	"9046804"	,	"9046805"	,	"9046900"	,	"9046901"	,	"9046806";
%mend icd;
%icd;

data &output. (drop = _drg11);
	set &input. (rename=(&sex. = gender));

	sex=gender;
	if gender in (3,9) then do;
		gender = 1;
	end;

	/*Create drg11 type*/
	_drg11 = &drg.;
	set drg11_MASTERLIST_RA (keep = _drg11 
									drg11_type 
									an110mdc_ra) 
							key = _drg11 / unique;
	if _error_ ne 0 then do;
		_error_ = 0; 
		drg11_type = "";
		an110mdc_ra = "";
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
	if srg in: ( &achi.)
			then flag_instrument_use = 1;
	end;

	do i=1 to MAXDDXVAR;
		if missing(DDXARRAY[i]) = 1 then MAXDDXVAR = dim(DDXARRAY); 
	end;

	do i = 1 to MAXDDXVAR;

		onset = ONSETARRAY[i]; 
		ddx = DDXARRAY[i];

	*CHARLSON COMORBIDITY INDEX;
	 		if DDX in: 		('I21'  ,'I22'  ,'I252' )																	then cc_Acute_myocardial_function = 1;
			else if DDX in: ('I50' 	)																					then cc_Congestive_heart_failure = 1;
			else if DDX in: ('I71'  ,'I790' ,'I739' ,'R02'  ,'Z958' ,'Z959' )											then cc_Peripheral_vascular_disease = 1;
			else if DDX in: ('I60'  ,'I61'  ,'I62'  ,'I63'  ,'I65'  ,'I66'  ,'G450' ,'G451' ,'G452' ,'G458' ,'G459' ,
							 'G46'  ,'I64'  ,'G454' ,'I670' ,'I671' ,'I672' ,'I674' ,'I675' ,'I676' ,'I677' ,'I678' ,
							 'I679' ,'I681' ,'I682' ,'I688' ,'I69'  )													then cc_Cerebral_vascular_accident = 1;
			else if DDX in: ('F00'  ,'F01'  ,'F02'  ,'F051' )															then cc_Dementia = 1;
			else if DDX in: ('J40'  ,'J41'  ,'J42'  ,'J44'  ,'J43'  ,'J45'  ,'J46'  ,'J47'  ,'J67'  ,'J60'  ,'J61'  ,
							 'J62'  ,'J63'  ,'J66'  ,'J64'  ,'J65'  )													then cc_Pulmonary_disease = 1;
			else if DDX in: ('M32'  ,'M34'  ,'M332' ,'M053' ,'M058' ,'M059' ,'M060' ,'M063' ,'M069' ,'M050' ,'M052' ,
							 'M051' ,'M353' )																			then cc_Connective_tissue_disorder = 1;
			else if DDX in: ('K25'  ,'K26'  ,'K27'  ,'K28'  )															then cc_Peptic_ulcer = 1;
			else if DDX in: ('K702' ,'K703' ,'K73'  ,'K717' ,'K740' ,'K742' ,'K746' ,'K743' ,'K744' ,'K745' )			then cc_Liver_disease = 1;
			else if DDX in: ('E109' ,'E119' ,'E139' ,'E149' ,'E101' ,'E111' ,'E131' ,'E141' ,'E105' ,'E115' ,'E135' ,
							 'E145' )																					then cc_Diabetes = 1;
			else if DDX in: ('E102' ,'E112' ,'E132' ,'E142' ,'E103' ,'E113' ,'E133' ,'E143' ,'E104' ,'E114' ,'E134' ,
							 'E144' )																					then cc_Diabetes_complications = 2;
			else if DDX in: ('G81'  ,'G041' ,'G820' ,'G821' ,'G822' )													then cc_Paraplegia = 2;
			else if DDX in: ('N03'  ,'N052' ,'N053' ,'N054' ,'N055' ,'N056' ,'N072' ,'N073' ,'N074' ,'N01'  ,'N18'  ,
							 'N19'  ,'N25'  )																			then cc_Renal_disease = 2;
			else if DDX in: ('C0'   ,'C1'   ,'C2'   ,'C3'   ,'C40'  ,'C41'  ,'C43'  ,'C45'  ,'C46'  ,'C47'  ,'C48'  ,
							 'C49'  ,'C5'   ,'C6'   ,'C70'  ,'C71'  ,'C72'  ,'C73'  ,'C74'  ,'C75'  ,'C76'  ,'C80'  ,
							 'C81'  ,'C82'  ,'C83'  ,'C84'  ,'C85'  ,'C883' ,'C887' ,'C889' ,'C900' ,'C901' ,'C91'  ,
							 'C92'  ,'C93'  ,'C940' ,'C941' ,'C942' ,'C943' ,'C9451','C947' ,'C95'  ,'C96'  )			then cc_Cancer = 2;
			else if DDX in: ('C77'  ,'C78'  ,'C79'	)																	then cc_Metastatic_cancer = 3;
			else if DDX in: ('K729' ,'K766' ,'K767' ,'K721' )															then cc_Severe_liver_disease = 3;
			else if DDX in: ('B20'  ,'B21'  ,'B22'  ,'B23'  ,'B24'  )													then cc_HIV = 6;
	*More HAC15 risk factors;	
			if DDX in: 		('Z3551','Z356' )																	then flag_primiparity = 1;
			else if DDX in: ('O328'	,'O640'	)  																	then flag_PPOP = 1;
			else if DDX in: ('O68'	)																			then flag_foetal_distress = 1;
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
		drop cc_: k i;
	
	*Create flag for Emergency, Treat Emergency, Not assigned and Not Known as Emergency;
	attrib flag_emergency length = 3.;
	if &urgadm. = '2' then flag_emergency = 0;
	else flag_emergency = 1;

run;