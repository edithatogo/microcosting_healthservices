/*
		+---------------------------------------------------------------------------+
		| Name:			Calculate Adjusted NWAU.sas									|
		| Description:	2023-24 Acute Admitted Patients								|
		|				Calculates the record-level NWAU(23) after the application	|
		|				of safety and quality adjustments.							|											
		| Version:		1.1															|
		| Author:		Pricing Implementation Section								|
		|				Independent Health and Aged Care Pricing Authority			|
		| Date:			August 2024													|
		+---------------------------------------------------------------------------+

*/

data hac_risk_adj_factors (index=(points));
	set CALCREF.hac_risk_adj_factors;
run;

data complexitygroups (index=(complexity));
	set CALCREF.complexitygroups;
run;
%global input2;
%macro mergepoints;
%macro temp; %mend temp;
proc sql ;
	%if &hac_adjustment. ne 0 %then %do;
		create table &input._0 as
			select t0.*,
				coalesce(t01.riskadj_01,0) as hac_adj01,
				coalesce(t02.riskadj_02,0) as hac_adj02,
				coalesce(t03.riskadj_03,0) as hac_adj03,
				coalesce(t04.riskadj_04,0) as hac_adj04,
				coalesce(t06.riskadj_06,0) as hac_adj06,
				coalesce(t07.riskadj_07,0) as hac_adj07,
				coalesce(t08.riskadj_08,0) as hac_adj08,
				coalesce(t09.riskadj_09,0) as hac_adj09,
				coalesce(t10.riskadj_10,0) as hac_adj10,
				coalesce(t11.riskadj_11,0) as hac_adj11,
				coalesce(t12.riskadj_12,0) as hac_adj12,
				coalesce(t13.riskadj_13,0) as hac_adj13,
				coalesce(t14.riskadj_14,0) as hac_adj14,
				coalesce(t15.riskadj_15,0) as hac_adj15
			from &input.  as t0
				left join hac_risk_adj_factors(idxwhere=YES) as t01 on (t0.hac_points01 = t01.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t02 on (t0.hac_points02 = t02.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t03 on (t0.hac_points03 = t03.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t04 on (t0.hac_points04 = t04.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t06 on (t0.hac_points06 = t06.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t07 on (t0.hac_points07 = t07.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t08 on (t0.hac_points08 = t08.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t09 on (t0.hac_points09 = t09.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t10 on (t0.hac_points10 = t10.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t11 on (t0.hac_points11 = t11.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t12 on (t0.hac_points12 = t12.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t13 on (t0.hac_points13 = t13.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t14 on (t0.hac_points14 = t14.points)
				left join hac_risk_adj_factors(idxwhere=YES) as t15 on (t0.hac_points15 = t15.points)
			;
		%let input2=&input._0;
	%end;
	%else %let input2=&input.;
	%if &AHR_adjustment. ne 0 %then %do;	
		create unique index temp_idx
			on inter_ahr_complexity(temp_idx);
		create unique index temp_idx
			on inter_ahr_prepared(temp_idx);
	%end;
quit;

data &output.;
	set &input2.;
	
	%if &AHR_adjustment. ne 0 %then %do;
		length w01_ahr 8.;
		set inter_ahr_complexity(keep= temp_idx dampening: risk_category: readm_points:
								&ahr_prefix.c01_flag &ahr_prefix.c02_flag &ahr_prefix.c03_flag 
								&ahr_prefix.c04_flag &ahr_prefix.c05_flag &ahr_prefix.c06_flag 
								&ahr_prefix.c07_flag &ahr_prefix.c08_flag &ahr_prefix.c09_flag 
								&ahr_prefix.c10_flag &ahr_prefix.c11_flag &ahr_prefix.c12_flag
			rename=(
				dampening1		=	ahr_adj01	
				dampening2		=	ahr_adj02	
				dampening3		=	ahr_adj03	
				dampening4		=	ahr_adj04	
				dampening5		=	ahr_adj05	
				dampening6		=	ahr_adj06	
				dampening7		=	ahr_adj07	
				dampening8		=	ahr_adj08	
				dampening9		=	ahr_adj09	
				dampening10		=	ahr_adj10
				dampening11		=	ahr_adj11
				dampening12		=	ahr_adj12
				
				risk_category1	=	ahr_risk_category01	
				risk_category2	=	ahr_risk_category02	
				risk_category3	=	ahr_risk_category03	
				risk_category4	=	ahr_risk_category04	
				risk_category5	=	ahr_risk_category05	
				risk_category6	=	ahr_risk_category06	
				risk_category7	=	ahr_risk_category07	
				risk_category8	=	ahr_risk_category08	
				risk_category9	=	ahr_risk_category09	
				risk_category10	=	ahr_risk_category10
				risk_category11	=	ahr_risk_category11
				risk_category12	=	ahr_risk_category12
				
				readm_points1	=	ahr_points01	
				readm_points2	=	ahr_points02	
				readm_points3	=	ahr_points03	
				readm_points4	=	ahr_points04	
				readm_points5	=	ahr_points05	
				readm_points6	=	ahr_points06	
				readm_points7	=	ahr_points07	
				readm_points8	=	ahr_points08	
				readm_points9	=	ahr_points09	
				readm_points10	=	ahr_points10
				readm_points11	=	ahr_points11
				readm_points12	=	ahr_points12
				)
			
					) key = temp_idx/unique; 
		if _IORC_ ne 0 then do; 
			_error_ = 0; 
			
			ahr_adj01 = 0;		ahr_adj02 = 0;		ahr_adj03 = 0;
			ahr_adj04 = 0;		ahr_adj05 = 0;		ahr_adj06 = 0;
			ahr_adj07 = 0;		ahr_adj08 = 0;		ahr_adj09 = 0;
			ahr_adj10 = 0;		ahr_adj11 = 0;		ahr_adj12 = 0;
								
			ahr_risk_category01	=  0;			ahr_risk_category02	=  0;
			ahr_risk_category03	=  0;			ahr_risk_category04	=  0;
			ahr_risk_category05	=  0;			ahr_risk_category06	=  0;
			ahr_risk_category07	=  0;			ahr_risk_category08	=  0;
			ahr_risk_category09	=  0;			ahr_risk_category10	=  0;
			ahr_risk_category11	=  0;			ahr_risk_category12	=  0;
				
			&ahr_prefix.c01_flag = 0;			&ahr_prefix.c02_flag = 0;
			&ahr_prefix.c03_flag = 0;			&ahr_prefix.c04_flag = 0;
			&ahr_prefix.c05_flag = 0;			&ahr_prefix.c06_flag = 0;
			&ahr_prefix.c07_flag = 0;			&ahr_prefix.c08_flag = 0;
			&ahr_prefix.c09_flag = 0;			&ahr_prefix.c10_flag = 0;
			&ahr_prefix.c11_flag = 0;			&ahr_prefix.c12_flag = 0;

			ahr_points01 = .;		ahr_points02 = .;		ahr_points03 = .;	
			ahr_points04 = .;		ahr_points05 = .;		ahr_points06 = .;	
			ahr_points07 = .;		ahr_points08 = .;		ahr_points09 = .;
			ahr_points10 = .;		ahr_points11 = .;		ahr_points12 = .;
			
		end;
		
		
		%if &AHR_adjustment. = 1 %then %do;
			set inter_ahr_prepared(keep= temp_idx &EP_ID._ahr &apcid._ahr &ahr_prefix._flag) key = temp_idx/unique; 
			if _IORC_ ne 0 then do; 
				_error_ = 0; 
				&EP_ID._ahr  = ""; 	
				&apcid._ahr = "";
				&ahr_prefix._flag = 0;
			end;
			
			length w01_ahr 8.; /*&EP_ID._ahr $80. &apcid._ahr $9.;*/
			if _n_=1 then do;
				dcl hash h_ahr (dataset:"inter_NWAU(keep=&EP_ID. &apcid. _w01  
							rename=(&EP_ID.=&EP_ID._ahr &apcid.=&apcid._ahr _w01=w01_ahr))");
				h_ahr.definekey("&EP_ID._ahr","&apcid._ahr");
				h_ahr.definedata('w01_ahr');
				h_ahr.definedone();
			end;

			rc0 = h_ahr.find();
			if rc0 ne 0 then w01_ahr = 0;
		%end;
		%else %if &AHR_adjustment. = 2 %then %do;
			/* w01_ahr = &W01_ahr.; */
			set inter_ahr_prepared(keep= temp_idx &EP_ID_ahr. &EST_ID_AHR. &ahr_prefix._flag rename = (&EP_ID_ahr. = ep_id_readm &EST_ID_AHR. = est_id_readm)) key = temp_idx/unique; 
			if _IORC_ ne 0 then do; 
				_error_ = 0; 
				ep_id_readm = 0;
				est_id_readm = 0;
				&ahr_prefix._flag = 0;
			end;
			
			length w01_ahr 8.;
			if _n_=1 then do;
				dcl hash h_ahr (dataset:"inter_NWAU(keep = temp_idx &EP_ID. &EST_ID. _w01  
							rename = (_w01 = w01_ahr &EP_ID. = ep_id_readm &EST_ID. = est_id_readm))");
				h_ahr.definekey("ep_id_readm", "est_id_readm");
				h_ahr.definedata('w01_ahr');
				h_ahr.definedone();
			end;

			rc0 = h_ahr.find();
			if rc0 ne 0 then w01_ahr = 0;
			&ahr_prefix._flag = max(0,	&ahr_prefix.c01_flag,&ahr_prefix.c02_flag,&ahr_prefix.c03_flag,
										&ahr_prefix.c04_flag,&ahr_prefix.c05_flag,&ahr_prefix.c06_flag,
										&ahr_prefix.c07_flag,&ahr_prefix.c08_flag,&ahr_prefix.c09_flag,
										&ahr_prefix.c10_flag,&ahr_prefix.c11_flag,&ahr_prefix.c12_flag);
			/*%macroAssign(w01_ahr,&W01_ahr.);*/
		%end;
		%else %do;
			w01_ahr = 0;
		%end;
		
		array ahr_flags 	&ahr_prefix.c01_flag &ahr_prefix.c02_flag &ahr_prefix.c03_flag 
							&ahr_prefix.c04_flag &ahr_prefix.c05_flag &ahr_prefix.c06_flag 
							&ahr_prefix.c07_flag &ahr_prefix.c08_flag &ahr_prefix.c09_flag 
							&ahr_prefix.c10_flag &ahr_prefix.c11_flag &ahr_prefix.c12_flag;
		array ahr_adjs ahr_adj:;
		
		do i=1 to dim(ahr_flags);
			ahr_adjs[i] = max(0, ahr_adjs[i] * ahr_flags[i]);
		end;
		
		if _pat_covid_flag then AHR_adj = 0;
		else AHR_adj=max(of AHR_adj:);
		
		AHRindex = whichn(AHR_adj, of AHR_adjs[*]);
		AHRgroup = substr(vname(AHR_adjs[AHRindex]),8,2);

		riskAdjustment_AHR = w01_AHR*AHR_adj;

		if AHR_adj = 0 then do;
			AHRgroup = "";
		end;
	%end;
	%else %do;
		riskAdjustment_ahr = 0;
	%end;
			

	%if &HAC_adjustment. ne 0 %then %do;	
	/*	Merge on NWAU adjustments*/

		array hac_flags 	&hac_prefix.c01_flag &hac_prefix.c02_flag &hac_prefix.c03_flag &hac_prefix.c04_flag 
							&hac_prefix.c06_flag &hac_prefix.c07_flag &hac_prefix.c08_flag &hac_prefix.c09_flag &hac_prefix.c10_flag 
							&hac_prefix.c11_flag &hac_prefix.c12_flag &hac_prefix.c13_flag &hac_prefix.c14_flag &hac_prefix.c15p02_flag;
		array hac_adjs 		hac_adj01-hac_adj04 	hac_adj06-hac_adj15;

	/*	Flag non zero HAC adjustments*/
		do i=1 to dim(hac_flags);
			hac_adjs[i] = hac_adjs[i]*hac_flags[i]; 
		end; 

		/*array riskadjs			riskadj_01-riskadj_04	riskadj_06-riskadj_14	riskadj_15;*/
	
		if _pat_covid_flag then HAC_adj = 0;
		else HAC_adj = max(of hac_adjs[*]);

		HACindex = whichn(HAC_adj, of hac_adjs[*]);
		HACgroup = substr(vname(hac_adjs[HACindex]),8,2);

		array complexitypoints	hac_points01-hac_points04 		hac_points06-hac_points14		hac_points15;
		complexity = complexitypoints[HACindex];

		set complexitygroups (rename=(	HAC01=HAC_risk_category01	HAC02=HAC_risk_category02	HAC03=HAC_risk_category03	HAC04=HAC_risk_category04
										HAC06=HAC_risk_category06	HAC07=HAC_risk_category07	HAC08=HAC_risk_category08	HAC09=HAC_risk_category09	HAC10=HAC_risk_category10
										HAC11=HAC_risk_category11	HAC12=HAC_risk_category12	HAC13=HAC_risk_category13	HAC14=HAC_risk_category14	HAC15=HAC_risk_category15)) key=complexity/unique;
			if _error_ ne 0 then do;
				_error_ = 0;
				HAC_risk_category01 = .;	HAC_risk_category02 = .;	HAC_risk_category03 = .;	HAC_risk_category04 = .;
											HAC_risk_category06 = .;	HAC_risk_category07 = .;	HAC_risk_category08 = .;
				HAC_risk_category09 = .;	HAC_risk_category10 = .;	HAC_risk_category11 = .;	HAC_risk_category12 = .;
				HAC_risk_category13 = .;	HAC_risk_category14 = .;	HAC_risk_category15 = .;
			end;

		array complexityGroups	HAC_risk_category01-HAC_risk_category04 		HAC_risk_category06-HAC_risk_category15;
		complexityGroup=complexityGroups[HACindex];



		if Error_Code ne 0 then do;
			HAC_adj = 0;
		end;

		if HAC_adj = 0 then do;
			HACgroup = "";
			complexity = .;
			complexityGroup = .;
		end;

	%end;
	%else %do; 
		HAC_adj = 0;


	%end;
	
	riskAdjustment_HAC = _w01*HAC_adj;
	
	nwau23_temp = max(0, nwau23 - riskAdjustment_HAC - riskAdjustment_ahr);

	%if &HAC_adjustment. ne 0 %then %do;

		if max(0, nomatch_age, nomatch_mdc, nomatch_icu, nomatch_cc, 
					nomatch_tfr, nomatch_emergency, nomatch_gender, nomatch_drg10,
					nomatch_flag_primiparity, nomatch_age15, nomatch_flag_foetal_distress, 
					nomatch_flag_PPOP,nomatch_flag_primiparity,
					nomatch_flag_instrument_use) ne 0 and &HAC_prefix._flag = 1 then do;
				if Error_Code = 0 then do;
					Error_Code = 3;
				end;
				nwau23_temp = 0;
		end;

	%end;
	drop i 
		%if &hac_adjustment. ne 0 %then %do;
		 	MAXDDXVAR	MAXSRGVAR srg	onset ddx complexity complexityGroup
			HACindex  tablec tabled
			%if &keep_hacs. = 0 %then %do;
		    	&hac_prefix.c:
			%end;	
			%if &keep_hac_points. = 0 %then %do;
				hac_points: hac_adj: hac_risk_category:
			%end;
		%end;
		%if &ahr_adjustment. ne 0 %then %do;
			ahrindex rc0
			%if &keep_ahrs. = 0 %then %do;
			    &ahr_prefix.c01_flag &ahr_prefix.c02_flag &ahr_prefix.c03_flag 
				&ahr_prefix.c04_flag &ahr_prefix.c05_flag &ahr_prefix.c06_flag 
				&ahr_prefix.c07_flag &ahr_prefix.c08_flag &ahr_prefix.c09_flag 
				&ahr_prefix.c10_flag &ahr_prefix.c11_flag &ahr_prefix.c12_flag
			%end;
			%if &keep_ahr_points. = 0 %then %do;
				ahr_points: ahr_adj: ahr_risk_category:
			%end;
		%end;
			;
;
run; 
%mend;

%mergepoints;