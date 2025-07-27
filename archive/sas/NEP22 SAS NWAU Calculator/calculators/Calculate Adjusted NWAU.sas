
data hac_risk_adj_factors (index=(points));
	set CALCREF.hac_risk_adj_factors;
run;

data complexitygroups (index=(complexity));
	set CALCREF.complexitygroups;
run;

%macro mergepoints;
%macro temp; %mend temp;
proc sql;
	%if &risk_adjustment. ne 0 %then %do;	
	create table &input._0 as
		select t0.*,
			coalesce(t01.riskadj_01,0) as riskadj_01,
			coalesce(t02.riskadj_02,0) as riskadj_02,
			coalesce(t03.riskadj_03,0) as riskadj_03,
			coalesce(t04.riskadj_04,0) as riskadj_04,
			coalesce(t06.riskadj_06,0) as riskadj_06,
			coalesce(t07.riskadj_07,0) as riskadj_07,
			coalesce(t08.riskadj_08,0) as riskadj_08,
			coalesce(t09.riskadj_09,0) as riskadj_09,
			coalesce(t10.riskadj_10,0) as riskadj_10,
			coalesce(t11.riskadj_11,0) as riskadj_11,
			coalesce(t12.riskadj_12,0) as riskadj_12,
			coalesce(t13.riskadj_13,0) as riskadj_13,
			coalesce(t14.riskadj_14,0) as riskadj_14,
			coalesce(t15.riskadj_15,0) as riskadj_15
		from &input.  as t0
			left join hac_risk_adj_factors(idxwhere=YES) as t01 on (t0.points01 = t01.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t02 on (t0.points02 = t02.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t03 on (t0.points03 = t03.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t04 on (t0.points04 = t04.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t06 on (t0.points06 = t06.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t07 on (t0.points07 = t07.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t08 on (t0.points08 = t08.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t09 on (t0.points09 = t09.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t10 on (t0.points10 = t10.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t11 on (t0.points11 = t11.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t12 on (t0.points12 = t12.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t13 on (t0.points13 = t13.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t14 on (t0.points14 = t14.points)
			left join hac_risk_adj_factors(idxwhere=YES) as t15 on (t0.points15 = t15.points)
		;
	%end;
	%else %do;
		create table &input._0 as
		select * from &input.;
	%end;
	
	%if &readmissions. ne 0 %then %do;	
	create unique index temp_idx
		on inter_readm_complexity(temp_idx);
	create unique index temp_idx
		on inter_readm_prepared(temp_idx);
	%end;
quit;

data &output.;
	set &input._0;
	
	%if &readmissions. ne 0 %then %do;
		length w01_readm 8.;
		set inter_readm_complexity(keep= temp_idx dampening: risk_category:
								&ahr_prefix.01_flag &ahr_prefix.02_flag &ahr_prefix.03_flag 
								&ahr_prefix.04_flag &ahr_prefix.05_flag &ahr_prefix.06_flag 
								&ahr_prefix.07_flag &ahr_prefix.08_flag &ahr_prefix.09_flag 
								&ahr_prefix.10_flag &ahr_prefix.11_flag &ahr_prefix.12_flag
			rename=(
				dampening1		=	readm_adj01	
				dampening2		=	readm_adj02	
				dampening3		=	readm_adj03	
				dampening4		=	readm_adj04	
				dampening5		=	readm_adj05	
				dampening6		=	readm_adj06	
				dampening7		=	readm_adj07	
				dampening8		=	readm_adj08	
				dampening9		=	readm_adj09	
				dampening10		=	readm_adj10
				dampening11		=	readm_adj11
				dampening12		=	readm_adj12
				
				risk_category1	=	readm_risk_category01	
				risk_category2	=	readm_risk_category02	
				risk_category3	=	readm_risk_category03	
				risk_category4	=	readm_risk_category04	
				risk_category5	=	readm_risk_category05	
				risk_category6	=	readm_risk_category06	
				risk_category7	=	readm_risk_category07	
				risk_category8	=	readm_risk_category08	
				risk_category9	=	readm_risk_category09	
				risk_category10	=	readm_risk_category10
				risk_category11	=	readm_risk_category11
				risk_category12	=	readm_risk_category12
				)
			
			
			
			
					) key = temp_idx/unique; 
		if _IORC_ ne 0 then do; 
			_error_ = 0; 
			
			readm_adj01		=  0;
			readm_adj02		=  0;
			readm_adj03		=  0;
			readm_adj04		=  0;
			readm_adj05		=  0;
			readm_adj06		=  0;
			readm_adj07		=  0;
			readm_adj08		=  0;
			readm_adj09		=  0;
			readm_adj10		=  0;
			readm_adj11		=  0;
			readm_adj12		=  0;
								
			readm_risk_category01	=  0;
			readm_risk_category02	=  0;
			readm_risk_category03	=  0;
			readm_risk_category04	=  0;
			readm_risk_category05	=  0;
			readm_risk_category06	=  0;
			readm_risk_category07	=  0;
			readm_risk_category08	=  0;
			readm_risk_category09	=  0;
			readm_risk_category10	=  0;
			readm_risk_category11	=  0;
			readm_risk_category12	=  0;
				
			&ahr_prefix.01_flag = 0;
			&ahr_prefix.02_flag = 0;
			&ahr_prefix.03_flag = 0;
			&ahr_prefix.04_flag= 0;
			&ahr_prefix.05_flag= 0;
			&ahr_prefix.06_flag= 0;
	 
			&ahr_prefix.07_flag= 0;
			&ahr_prefix.08_flag= 0;
			&ahr_prefix.09_flag= 0;
	 
			&ahr_prefix.10_flag= 0;
			&ahr_prefix.11_flag= 0;
			&ahr_prefix.12_flag= 0;

			
			
		end;
		
		
		%if &readmissions. = 1 %then %do;
			set inter_readm_prepared(keep= temp_idx &EP_ID._readm &EST_ID._readm readmflag) key = temp_idx/unique; 
			if _IORC_ ne 0 then do; 
				_error_ = 0; 
				&EP_ID._readm  = ""; 	
				&EST_ID._readm = "";
				readmflag = 0;
			end;
			
			length w01_readm 8.; /*&EP_ID._readm $80. &EST_ID._readm $9.;*/
			if _n_=1 then do;
				dcl hash h_readm (dataset:"inter_NWAU(keep=&EP_ID. &EST_ID. _w01  
							rename=(&EP_ID.=&EP_ID._readm &EST_ID.=&EST_ID._readm _w01=w01_readm))");
				h_readm.definekey("&EP_ID._readm","&EST_ID._readm");
				h_readm.definedata('w01_readm');
				h_readm.definedone();
			end;

			rc0 = h_readm.find();
			if rc0 ne 0 then w01_readm = 0;
		%end;
		%else %if &readmissions. = 2 %then %do;
			w01_readm = &W01_READM.;
			readmflag = max(0,	&ahr_prefix.01_flag,&ahr_prefix.02_flag,&ahr_prefix.03_flag,
								&ahr_prefix.04_flag,&ahr_prefix.05_flag,&ahr_prefix.06_flag,
								&ahr_prefix.07_flag,&ahr_prefix.08_flag,&ahr_prefix.09_flag,
								&ahr_prefix.10_flag,&ahr_prefix.11_flag,&ahr_prefix.12_flag);
			/*%macroAssign(w01_readm,&W01_READM.);*/
		%end;
		%else %do;
			w01_readm = 0;
		%end;
		
		array readm_flags 	&ahr_prefix.01_flag &ahr_prefix.02_flag &ahr_prefix.03_flag 
							&ahr_prefix.04_flag &ahr_prefix.05_flag &ahr_prefix.06_flag 
							&ahr_prefix.07_flag &ahr_prefix.08_flag &ahr_prefix.09_flag 
							&ahr_prefix.10_flag &ahr_prefix.11_flag &ahr_prefix.12_flag;
		array readm_adjs readm_adj:;
		
		do i=1 to dim(readm_flags);
			readm_adjs[i] = max(0, readm_adjs[i] * readm_flags[i]);
		end;
		
		if _pat_covid_flag then readm_adj = 0;
		else readm_adj = max(of readm_adjs[*]);
		
		riskAdjustment_readm = w01_readm*readm_adj;
		
	%end;
	%else %do;
		riskAdjustment_readm = 0;
	%end;
			

	%if &risk_adjustment. ne 0 %then %do;	
	/*	Merge on NWAU adjustments*/

		array hacflags 		hacflag01-hacflag04 	hacflag06-hacflag14 	hacflag15p02;
		array riskadjs 		riskadj_01-riskadj_04 	riskadj_06-riskadj_14 	riskadj_15;


	/*	HAC16*/
		riskadj_16 = 0;

	/*	Flag non zero HAC adjustments*/
		do i=1 to dim(hacflags);
			riskadjs[i] = riskadjs[i]*hacflags[i]; 
		end; 

		/*array riskadjs			riskadj_01-riskadj_04	riskadj_06-riskadj_14	riskadj_15;*/
	
		if _pat_covid_flag then HAC_adj = 0;
		else HAC_adj = max(of riskadjs[*]);

		HACindex = whichn(HAC_adj, of riskadjs[*]);
		array riska				riskadj_01-riskadj_04	riskadj_06-riskadj_14	riskadj_15;
		HACgroup = substr(vname(riskadjs[HACindex]),9,2);

		array complexitypoints	points01-points04 		points06-points14		points15;
		complexity = complexitypoints[HACindex];

		set complexitygroups key=complexity/unique;
			if _error_ ne 0 then do;
				_error_ = 0;
				HAC01 = .; HAC02 = .; HAC03 = .; HAC04 = .;
				HAC06 = .; HAC07 = .; HAC08 = .; HAC09 = .;
				HAC10 = .; HAC11 = .; HAC12 = .; HAC13 = .; 
				HAC14 = .; HAC15 = .; HAC16 = .;
			end;

		array complexityGroups	HAC01-HAC04 			HAC06-HAC14				HAC15;
		complexityGroup=complexityGroups[HACindex];



		if Error_Code ne 0 then do;
			HAC_adj = 0;
		end;

		if HAC_adj = 0 then do;
			HACgroup = "";
			complexity = .;
			complexityGroup = .;
		end;

		drop 	HACindex 
				HAC0: 
				HAC1:
				;
	%end;
	%else %do; 
		HAC_adj = 0;


	%end;
	
	riskAdjustment_HAC = _w01*HAC_adj;
	
	nwau22_temp = max(0, nwau22 - riskAdjustment_HAC - riskAdjustment_readm);

	%if &risk_adjustment. ne 0 %then %do;

		if max(0, nomatch_age, nomatch_mdc, nomatch_icu, nomatch_cc, 
					nomatch_tfr, nomatch_emergency, nomatch_gender, nomatch_drg10,
					nomatch_flag_primiparity, nomatch_age15, nomatch_flag_foetal_distress, 
					nomatch_flag_PPOP,nomatch_flag_primiparity,
					nomatch_flag_instrument_use) ne 0 and hacflag = 1 then do;
				if Error_Code = 0 then do;
					Error_Code = 3;
				end;
				nwau22_temp = 0;
		end;

	%end;
	
run; 
%mend;

%mergepoints;