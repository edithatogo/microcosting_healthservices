libname cPoints "&location." access=readonly;

data &output.;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &input.;

	set cPoints.p_age key=agegroupc/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_age=1; end;;
	set cPoints.p_mdc key=an90mdc_ra/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_mdc=1; end;;
	set cPoints.p_flag_ICUHours key=flag_ICUHours/unique; if _error_ ne 0 then do; _error_ = 0; nomatch_icu=1; end;;
	set cPoints.p_cc key=Charlson_Score/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_cc=1; end;;
	set cPoints.p_flag_AdmTransfer key=flag_AdmTransfer/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_tfr=1; end;;
	set cPoints.p_flag_emergency key=flag_emergency/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_emergency=1; end;;
	set cPoints.p_gender key=gender/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_gender=1; end;;
	set cPoints.p_drg9_type key=drg9_type/unique;  if _error_ ne 0 then do; _error_ = 0; nomatch_drg9=1; end;;

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

	if an90mdc_ra in (19,20) then do;
		nomatch_mdc=.;
	end;
run;

