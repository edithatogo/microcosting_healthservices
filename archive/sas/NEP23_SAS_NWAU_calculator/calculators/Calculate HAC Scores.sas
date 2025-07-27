libname cPoints "&location." access=readonly;

data p_age 					(index=(agegroup)); 
	set cPoints.p_age; 
run;

data p_mdc 					(index=(an110mdc_ra)); 
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

data p_DRG11_type 		(index=(DRG11_type)); 
	set cPoints.p_DRG11_type; 
run;

data p_age15 				(index=(age_15g));
	set cPoints.p_age15; 
run;

data p_flag_foetal_distress	(index=(flag_foetal_distress));
	set cPoints.p_flag_foetal_distress; 
run;

data p_flag_PPOP 			(index=(flag_PPOP));
	set cPoints.p_flag_PPOP; 
run;

data p_flag_primiparity 	(index=(flag_primiparity));
	set cPoints.p_flag_primiparity; 
run;

data p_flag_instrument_use	(index=(flag_instrument_use));
	set cPoints.p_flag_instrument_use; 
run;

%macro loop;
%let list = 01 02 03 04 06 07 08 09 10 11 12 13 14	;
	
	%let k=1;
	%do %while(%scan(&list., &k.) ne );
		%let hh = %scan(&list., &k.);
		hac_points&hh. = round(sum(		0
								,_p_intercept&hh.
								,_p_agegroup&hh.
								,_p_an110mdc_RA&hh.
								,_p_flag_ICUHours&hh.
								,_p_Charlson_Score&hh.
								,_p_flag_AdmTransfer&hh.
								,_p_flag_emergency&hh.
								,_p_gender&hh.
								,_p_drg11_type&hh.
							  )
						  );
		%let k = %eval(&k.+1);
	%end;
%mend loop;
data &output.0;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &input.;

	set p_age 				key=agegroup/unique;  			if _error_ ne 0 then do; _error_ = 0; nomatch_age=1; 			end;
	set p_mdc		 		key=an110mdc_ra/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_mdc=1;			end;
	set p_flag_ICUHours 	key=flag_ICUHours/unique; 		if _error_ ne 0 then do; _error_ = 0; nomatch_icu=1; 			end;
	set p_cc 				key=Charlson_Score/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_cc=1; 			end;
	set p_flag_AdmTransfer 	key=flag_AdmTransfer/unique; 	if _error_ ne 0 then do; _error_ = 0; nomatch_tfr=1; 			end;
	set p_flag_emergency 	key=flag_emergency/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_emergency=1;		end;
	set p_gender 			key=gender/unique;  			if _error_ ne 0 then do; _error_ = 0; nomatch_gender=1; 		end;
	set p_drg11_type 		key=drg11_type/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_drg11=1; 			end;

/*	array	_p_intercept					_p_intercept: ;*/
/*	array	_p_agegroup						_p_agegroup: ;*/
/*	array	_p_an110mdc						_p_an110mdc_RA: ;*/
/*	array	_p_flag_ICUHours				_p_flag_ICUHours: ;*/
/*	array	_p_Charlson_Score				_p_Charlson_Score: ;*/
/*	array	_p_flag_AdmTransfer				_p_flag_AdmTransfer: ;*/
/*	array	_p_flag_emergency				_p_flag_emergency: ;*/
/*	array	_p_gender						_p_gender: ;*/
/*	array	_p_drg11_type					_p_drg11_type: ;*/
/**/
/*	array points					points01-points04  points06-points14;*/

%loop;


run;

data &output.;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &output.0;

	set p_age15 				key=age_15g/unique;  				if _error_ ne 0 then do; _error_ = 0; nomatch_age15=1;				 _p_age_15g=0; 				end;
	set p_flag_foetal_distress 	key=flag_foetal_distress/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_flag_foetal_distress=1;_p_flag_foetal_distress=0; end;
	set p_flag_PPOP 			key=flag_PPOP/unique; 				if _error_ ne 0 then do; _error_ = 0; nomatch_flag_PPOP=1; 			 _p_flag_PPOP=0; 			end;
	set p_flag_Primiparity 		key=flag_primiparity/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_flag_primiparity=1;	 _p_flag_primiparity=0; 	end;
	set p_flag_instrument_use	key=flag_instrument_use/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_flag_instrument_use=1; _p_flag_instrument_use=0; 	end;

	hac_points15 = min(100,max(0,round(sum(0	, 	_p_age_15g	
							,	_p_intercept15
							,	_p_flag_emergency15
							,	_p_flag_PPOP
							,	_p_flag_Primiparity
							,	_p_flag_foetal_distress
							,	_p_flag_instrument_use
						),1)));
	temp_idx = _n_;
	
/*	drop _p_:  ;*/

run;

proc datasets library=work nolist;
	delete
		p_age
		p_mdc
		p_flag_icuhours
	 	p_cc
	 	p_flag_admtransfer
	 	p_flag_emergency
	 	p_gender
	 	p_drg11_type
		p_age15 
		p_flag_instrument_use
		p_flag_PPOP
		p_flag_Primiparity
		p_flag_foetal_distress
	 	&output.0;
quit;