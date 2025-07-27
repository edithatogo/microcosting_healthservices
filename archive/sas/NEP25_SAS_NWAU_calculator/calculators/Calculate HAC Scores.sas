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

/*----------------------------------------------------------------------------
	Starting disaggregate risk factor import block
-----------------------------------------------------------------------------*/

data p_cc_acute_myocardial_function 	(index=(cc_acute_myocardial_function)); 
	set cPoints.p_cc_acute_myocardial_function; 
run;

data p_cc_cancer 	(index=(cc_cancer)); 
	set cPoints.p_cc_cancer; 
run;

data p_cc_cerebral_vascular_accident 	(index=(cc_cerebral_vascular_accident)); 
	set cPoints.p_cc_cerebral_vascular_accident; 
run;

data p_cc_congestive_heart_failure 	(index=(cc_congestive_heart_failure)); 
	set cPoints.p_cc_congestive_heart_failure; 
run;

data p_cc_connective_tissue_disorder 	(index=(cc_connective_tissue_disorder)); 
	set cPoints.p_cc_connective_tissue_disorder; 
run;

data p_cc_dementia 	(index=(cc_dementia)); 
	set cPoints.p_cc_dementia; 
run;

data p_cc_diabetes 	(index=(cc_diabetes)); 
	set cPoints.p_cc_diabetes; 
run;

data p_cc_diabetes_complications 	(index=(cc_diabetes_complications)); 
	set cPoints.p_cc_diabetes_complications; 
run;

data p_cc_hiv 	(index=(cc_hiv)); 
	set cPoints.p_cc_hiv; 
run;

data p_cc_liver_disease 	(index=(cc_liver_disease)); 
	set cPoints.p_cc_liver_disease; 
run;

data p_cc_metastatic_cancer 	(index=(cc_metastatic_cancer)); 
	set cPoints.p_cc_metastatic_cancer; 
run;

data p_cc_paraplegia 	(index=(cc_paraplegia)); 
	set cPoints.p_cc_paraplegia; 
run;

data p_cc_peptic_ulcer 	(index=(cc_peptic_ulcer)); 
	set cPoints.p_cc_peptic_ulcer; 
run;

data p_cc_peripheral_vascular_disease 	(index=(cc_peripheral_vascular_disease)); 
	set cPoints.p_cc_peripheral_vascular_disease; 
run;

data p_cc_pulmonary_disease 	(index=(cc_pulmonary_disease)); 
	set cPoints.p_cc_pulmonary_disease; 
run;

data p_cc_renal_disease 	(index=(cc_renal_disease)); 
	set cPoints.p_cc_renal_disease; 
run;

data p_cc_severe_liver_disease 	(index=(cc_severe_liver_disease)); 
	set cPoints.p_cc_severe_liver_disease; 
run;


/*----------------------------------------------------------------------------
	Ending disaggregate risk factor import block
-----------------------------------------------------------------------------*/

data p_flag_AdmTransfer 	(index=(flag_AdmTransfer)); 
	set cPoints.p_flag_AdmTransfer; 
run;

data p_flag_emergency 		(index=(flag_emergency)); 
	set cPoints.p_flag_emergency; 
run;

data p_sex 				(index=(sex_cat)); 
	set cPoints.p_sex; 
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

/*MH - NEP24 - 64 HAC disaggregate: Updated macro loop to account for individual risk factors. */
%macro loop;
%let list = 01 02 03 04 06 07 08 09 10 11 12 13 14	;
	
	%let k=1;
	%do %while(%scan(&list., &k.) ne );
		%let hh = %scan(&list., &k.);
		hac_points&hh. = min(100,max(1,round(sum(0
								,_p_intercept&hh.
								,_p_agegroup&hh.
								,_p_an110mdc_RA&hh.
								,_p_flag_ICUHours&hh.
								, _p_cc_Acute_myo&hh.
								, _p_cc_Congestive_heart&hh.
								, _p_cc_Peripheral_vasc&hh.
								, _p_cc_Cerebral_vasc&hh.
								, _p_cc_Dementia&hh.
								, _p_cc_Pulmonary&hh.
								, _p_cc_Connective_tissue&hh.
								, _p_cc_Peptic_ulcer&hh.
								, _p_cc_Liver_disease&hh.
								, _p_cc_Diabetes&hh.
								, _p_cc_Diabetes_comp&hh.
								, _p_cc_Paraplegia&hh.
								, _p_cc_Renal_disease&hh.
								, _p_cc_Cancer&hh.
								, _p_cc_Metastatic_cancer&hh.
								, _p_cc_Severe_liver&hh.
								, _p_cc_HIV&hh.

								,_p_flag_AdmTransfer&hh.
								,_p_flag_emergency&hh.
								,_p_sex_cat&hh.
								,_p_drg11_type&hh.
							  )
						  ,1))); 
		%let k = %eval(&k.+1);
	%end;
%mend loop;
data &output.0;
	if _n_ eq 1 then set cPoints.p_intercept;
	set &input.;

	set p_age 				key=agegroup/unique;  			if _error_ ne 0 then do; _error_ = 0; nomatch_age=1; 			end;
	set p_mdc		 		key=an110mdc_ra/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_mdc=1;			end;
	set p_flag_ICUHours 	key=flag_ICUHours/unique; 		if _error_ ne 0 then do; _error_ = 0; nomatch_icu=1; 			end;
	set p_cc_Acute_myocardial_function        	key=cc_Acute_myocardial_function/unique;        if _error_ ne 0 then do;  _error_=0; nomatch_Acute_myocardial=1;            end; else nomatch_Acute_myo=0;
	set p_cc_Congestive_heart_failure       	key=cc_Congestive_heart_failure/unique;         if _error_ ne 0 then do;  _error_=0; nomatch_Congestive_heart=1;            end; else nomatch_Congestive_heart=0;
	set p_cc_Peripheral_vascular_disease      	key=cc_Peripheral_vascular_disease/unique;      if _error_ ne 0 then do;  _error_=0; nomatch_Peripheral_vasc=1;          	end; else nomatch_Peripheral_vascular=0;
	set p_cc_Cerebral_vascular_accident       	key=cc_Cerebral_vascular_accident/unique;       if _error_ ne 0 then do;  _error_=0; nomatch_Cerebral_vasc=1;            	end; else nomatch_Cerebral_vascular=0;
	set p_cc_Dementia       					key=cc_Dementia/unique;        				 	if _error_ ne 0 then do;  _error_=0; nomatch_Dementia=1;             		end; else nomatch_Dementia=0;
	set p_cc_Pulmonary_disease       		 	key=cc_Pulmonary_disease/unique;        		if _error_ ne 0 then do;  _error_=0; nomatch_Pulmonary=1;            		end; else nomatch_Pulmonary=0;
	set p_cc_Connective_tissue_disorder       	key=cc_Connective_tissue_disorder/unique;       if _error_ ne 0 then do;  _error_=0; nomatch_Connective_tissue=1;           end; else nomatch_Connective_tissue=0;
	set p_cc_Peptic_ulcer      				 	key=cc_Peptic_ulcer/unique;        			 	if _error_ ne 0 then do;  _error_=0; nomatch_Peptic_ulcer=1;             	end; else nomatch_Peptic_ulcer=0;
	set p_cc_Liver_disease     				 	key=cc_Liver_disease/unique;        			if _error_ ne 0 then do;  _error_=0; nomatch_Liver_disease=1;           	end; else nomatch_Liver_disease=0;
	set p_cc_Diabetes       					key=cc_Diabetes/unique;        				 	if _error_ ne 0 then do;  _error_=0; nomatch_Diabetes=1;            		end; else nomatch_Diabetes=0;
	set p_cc_Diabetes_complications       		key=cc_Diabetes_complications/unique;         	if _error_ ne 0 then do;  _error_=0; nomatch_Diabetes_comp=1;           	end; else nomatch_Diabetes_comp=0;
	set p_cc_Paraplegia       				 	key=cc_Paraplegia/unique;       				if _error_ ne 0 then do;  _error_=0; nomatch_Paraplegia=1;           		end; else nomatch_Paraplegia=0;
	set p_cc_Renal_disease       			 	key=cc_Renal_disease/unique;    			    if _error_ ne 0 then do;  _error_=0; nomatch_Renal_disease=1;         	    end; else nomatch_Renal_disease=0;
	set p_cc_Cancer       					 	key=cc_Cancer/unique;        					if _error_ ne 0 then do;  _error_=0; nomatch_Cancer=1;             		  	end; else nomatch_Cancer=0;
	set p_cc_Metastatic_cancer       		 	key=cc_Metastatic_cancer/unique;        		if _error_ ne 0 then do;  _error_=0; nomatch_Metastatic_cancer=1;          	end; else nomatch_Metastatic_cancer=0;
	set p_cc_Severe_liver_disease       		key=cc_Severe_liver_disease/unique;        	 	if _error_ ne 0 then do;  _error_=0; nomatch_Severe_liver=1;            	end; else nomatch_Severe_liver=0;
	set p_cc_HIV       						 	key=cc_HIV/unique;        						if _error_ ne 0 then do;  _error_=0; nomatch_HIV=1;           				end; else nomatch_HIV=0;

	set p_flag_AdmTransfer 	key=flag_AdmTransfer/unique; 	if _error_ ne 0 then do; _error_ = 0; nomatch_tfr=1; 			end;
	set p_flag_emergency 	key=flag_emergency/unique;  	if _error_ ne 0 then do; _error_ = 0; nomatch_emergency=1;		end;
	set p_sex 				key=sex_cat/unique;  					if _error_ ne 0 then do; _error_ = 0; nomatch_sex=1; 		end;
	set p_drg11_type 		key=drg11_type/unique;  		if _error_ ne 0 then do; _error_ = 0; nomatch_drg11=1; 			end;

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

	hac_points15 = min(100,max(1,round(sum(0  	
							,	_p_age_15g	
							,	_p_intercept15
							,	_p_flag_emergency15
							,	_p_flag_PPOP
							,	_p_flag_Primiparity
							,	_p_flag_foetal_distress
							,	_p_flag_instrument_use
						),1)));
	temp_idx = _n_;
	
run;

proc datasets library=work nolist;
	delete
		p_age
		p_mdc
		p_flag_icuhours
		p_cc_acute_myocardial_function
		p_cc_cancer
		p_cc_cerebral_vascular_accident
		p_cc_congestive_heart_failure
		p_cc_connective_tissue_disorder
		p_cc_dementia
		p_cc_diabetes
		p_cc_diabetes_complications
		p_cc_hiv
		p_cc_liver_disease
		p_cc_metastatic_cancer
		p_cc_paraplegia
		p_cc_peptic_ulcer
		p_cc_peripheral_vascular_disease
		p_cc_pulmonary_disease
		p_cc_renal_disease
		p_cc_severe_liver_disease

	 	p_flag_admtransfer
	 	p_flag_emergency
	 	p_sex
	 	p_drg11_type
		p_age15 
		p_flag_instrument_use
		p_flag_PPOP
		p_flag_Primiparity
		p_flag_foetal_distress
	 	&output.0;
quit;