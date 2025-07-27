libname cPoints "&location." access=readonly;

data p_age 					(index=(agegroup)); 
	set cPoints.p_age; 
run;

data p_mdc 					(index=(an100mdc_ra)); 
	set cPoints.p_mdc; 
run;

data p_flag_ICUHours 		(index=(flag_ICUHours)); 
	set cPoints.p_flag_ICUHours; 
run;

data p_cc 					(index=(Charlson_Score)); 
	set cPoints.p_cc; 
run;

data p_flag_AdmTransfer 	(index=(flag_AdmTransfer)); 
	set cPoints.p_flag_AdmTransfer; 
run;

data p_flag_emergency 		(index=(flag_emergency)); 
	set cPoints.p_flag_emergency; 
run;

data p_gender 				(index=(gender)); 
	set cPoints.p_gender; 
run;

data p_drg10_type 			(index=(drg10_type)); 
	set cPoints.p_drg10_type; 
run;

data p_age15 				(index=(age_15g));
	set cPoints.p_age15; 
run;

data p_foetal_distress_flag (index=(foetal_distress_flag));
	set cPoints.p_foetal_distress_flag; 
run;

data p_PPOP_flag 			(index=(PPOP_flag));
	set cPoints.p_PPOP_flag; 
run;

data p_primiparity_flag 	(index=(primiparity_flag));
	set cPoints.p_primiparity_flag; 
run;

data p_instrument_use_flag	(index=(instrument_use_flag));
	set cPoints.p_instrument_use_flag; 
run;

%macro loop;
%let list = 01 02 03 04 06 07 08 09 10 11 12 13 14	;
	
	%let k=1;
	%do %while(%scan(&list., &k.) ne );
		%let hh = %scan(&list., &k.);
		points&hh. = round(sum(		0
								,_p_intercept&hh.
								,_p_agegroup&hh.
								,_p_an100mdc&hh.
								,_p_flag_ICUHours&hh.
								,_p_Charlson_Score&hh.
								,_p_flag_AdmTransfer&hh.
								,_p_flag_emergency&hh.
								,_p_gender&hh.
								,_p_drg10_type&hh.
							  )
						  );
		%let k = %eval(&k.+1);
	%end;
%mend loop;
data &output.0;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &input.;

	set p_age 				key=agegroup/unique;  			if _error_ ne 0 then do; _error_ = 0; nomatch_age=1; 			end;
	set p_mdc		 		key=an100mdc_ra/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_mdc=1;			end;
	set p_flag_ICUHours 	key=flag_ICUHours/unique; 		if _error_ ne 0 then do; _error_ = 0; nomatch_icu=1; 			end;
	set p_cc 				key=Charlson_Score/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_cc=1; 			end;
	set p_flag_AdmTransfer 	key=flag_AdmTransfer/unique; 	if _error_ ne 0 then do; _error_ = 0; nomatch_tfr=1; 			end;
	set p_flag_emergency 	key=flag_emergency/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_emergency=1;		end;
	set p_gender 			key=gender/unique;  			if _error_ ne 0 then do; _error_ = 0; nomatch_gender=1; 		end;
	set p_drg10_type 		key=drg10_type/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_drg10=1; 			end;

	array	_p_intercept					_p_intercept: ;
	array	_p_agegroup						_p_agegroup: ;
	array	_p_an100mdc						_p_an100mdc: ;
	array	_p_flag_ICUHours				_p_flag_ICUHours: ;
	array	_p_Charlson_Score				_p_Charlson_Score: ;
	array	_p_flag_AdmTransfer				_p_flag_AdmTransfer: ;
	array	_p_flag_emergency				_p_flag_emergency: ;
	array	_p_gender						_p_gender: ;
	array	_p_drg10_type					_p_drg10_type: ;

	array points					points01-points04  points06-points14;

%loop;


run;

data &output.;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &output.0;

	set p_age15 				key=age_15g/unique;  				if _error_ ne 0 then do; _error_ = 0; nomatch_age15=1; _p_age_15g=0; 					end;
	set p_foetal_distress_flag 	key=foetal_distress_flag/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_foetal_distress_flag=1; _p_foetal_distress_flag=0; 	end;
	set p_PPOP_flag 			key=PPOP_flag/unique; 				if _error_ ne 0 then do; _error_ = 0; nomatch_PPOP_flag=1; _p_PPOP_flag=0; 				end;
	set p_Primiparity_flag 		key=primiparity_flag/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_primiparity_flag=1; _p_primiparity_flag=0; 		end;
	set p_instrument_use_flag 	key=instrument_use_flag/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_instrument_use_flag=1; _p_instrument_use_flag=0; 	end;

	points15 = min(100,max(0,round(sum(0	, 	_p_age_15g	
							,	_p_intercept15
							,	_p_flag_emergency15
							,	_p_PPOP_flag
							,	_p_Primiparity_flag
							,	_p_foetal_distress_flag
							,	_p_instrument_use_flag
						),1)));
	
	drop _p_:  ;

run;

proc datasets nolist library=work;
	delete
		p_age
		p_mdc
		p_flag_icuhours
	 	p_cc
	 	p_flag_admtransfer
	 	p_flag_emergency
	 	p_gender
	 	p_drg10_type
		p_age15 
		p_instrument_use_flag
		p_PPOP_flag
		p_Primiparity_flag
		p_foetal_distress_flag
	 	&output.0;
quit;