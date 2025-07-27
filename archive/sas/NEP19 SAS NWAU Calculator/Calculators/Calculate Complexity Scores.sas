libname cPoints "&location." access=readonly;

%macro createindex; 
/*%macro temp; %mend temp;	*show colours in macro;*/

	data p_age (index=(agegroup)); 
		set cPoints.p_age; 
	run;

	data p_mdc (index=(an90mdc_ra)); 
		set cPoints.p_mdc; 
	run;

	data p_flag_ICUHours (index=(flag_ICUHours)); 
		set cPoints.p_flag_ICUHours; 
	run;

	data p_cc (index=(Charlson_Score)); 
		set cPoints.p_cc; 
	run;

	data p_flag_AdmTransfer (index=(flag_AdmTransfer)); 
		set cPoints.p_flag_AdmTransfer; 
	run;

	data p_flag_emergency (index=(flag_emergency)); 
		set cPoints.p_flag_emergency; 
	run;

	data p_gender (index=(gender)); 
		set cPoints.p_gender; 
	run;

	data p_drg9_type (index=(drg9_type)); 
		set cPoints.p_drg9_type; 
	run;

%mend; 

%createindex;


data &output.;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &input.;

	set p_age key=agegroup/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_age=1; end;;
	set p_mdc key=an90mdc_ra/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_mdc=1; end;;
	set p_flag_ICUHours key=flag_ICUHours/unique; if _error_ ne 0 then do; _error_ = 0; nomatch_icu=1; end;;
	set p_cc key=Charlson_Score/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_cc=1; end;;
	set p_flag_AdmTransfer key=flag_AdmTransfer/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_tfr=1; end;;
	set p_flag_emergency key=flag_emergency/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_emergency=1; end;;
	set p_gender key=gender/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_gender=1; end;;
	set p_drg9_type key=drg9_type/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_drg9=1; end;;

	array	_p_intercept					_p_intercept: ;
	array	_p_agegroupc					_p_agegroupc: ;
	array	_p_an90mdc_ra					_p_an90mdc_ra: ;
	array	_p_flag_ICUHours				_p_flag_ICUHours: ;
	array	_p_Charlson_Score				_p_Charlson_Score: ;
	array	_p_flag_AdmTransfer				_p_flag_AdmTransfer: ;
	array	_p_flag_emergency				_p_flag_emergency: ;
	array	_p_gender						_p_gender: ;
	array	_p_drg9_type					_p_drg9_type: ;

	array points					points01-points04  points06-points14;
			
	do over _p_intercept;
		points = sum(0, 	_p_intercept,
							_p_agegroupc,
							_p_an90mdc_ra,
							_p_flag_ICUHours,
							_p_Charlson_Score,
							_p_flag_AdmTransfer,
							_p_flag_emergency,
							_p_gender,
							_p_drg9_type
);
	end;

	*Rounding;
	do over _p_intercept;
		points = round(points, 1);
	end;

	drop _p_:  ;

run;

proc sql;
	drop table p_age, p_mdc, p_flag_icuhours, p_cc, p_flag_admtransfer, p_flag_emergency, p_gender, p_drg9_type;
quit;