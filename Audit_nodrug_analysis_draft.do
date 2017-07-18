/*-----------------------------------------------------------				
*	Goal:			No Drug paper analysis

*	Input Data:		1) nodrug_paper.dta;
					
*	Output Data:	1) Audit_nodrug.do
										
*   Author(s):      Hao Xue  
*	Created: 		2016-07-10
*   Last Modified: 	2016-11-09 Hao
-----------------------------------------------------------*/
/*---------------------------------------------------------
 Note: primary steps of this do file
 
	Step 1: Table 1: Sample Distribution of Observations (Clinics) by Experimental Arm
	Step 2: Table 2: Provider Characteristics
	Step 3: Table 3: Diarrhea main outcomes of interactions with standardized patients
	Step 4: Table 4: Correlates of Process Quality, Diagnosis, and Treatment in Clinics
	Step 5: Appendix Table 2: Adherence to Checklist of Recommended Questions and Exams
	Step 6: Appendix Table 3: Standardized Patient Measures of Provider Quality for Two Disease Cases
	Step 7: Appendix Table 4: Correlates of Process Quality, Diagnosis, and Treatment in Village Clinics for Two Disease Cases
	
	* Appendix Table 1 is not generated automatically.
	
-----------------------------------------------------------*/

clear all
set more off
capture log close
set maxvar  30000

*Xuehao
global datadir "/Users/apple/Dropbox (REAP)/Standardized_Patients_II/Std_Patient_2/Papers/4_Audit_Exp_EconofScale/Data"
global output "/Users/apple/Dropbox (REAP)/Standardized_Patients_II/Std_Patient_2/Papers/4_Audit_Exp_EconofScale/Output"

	

use "$datadir/nodrug_paper.dta", clear
	

/*-------
Step 3: Regression
--------*/		
	/*-------
	Step 3.1: Table 2 Nodrug and process
	--------*/	
	
	replace nodrug_a=0 if nodrug_a==.
	replace nodrug_b=0 if nodrug_b==.
	
	global doccha "pracdoc age male patientload"
	

	eststo clear
	qui foreach out of varlist diagtime_min diagtime arq arqe {
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1 & drugpres==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode if drugpres==1, absorb(groupcode) vce(robust)
	}

	esttab using "$output/nodrug_test.csv", b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) replace 
	
	eststo clear
	qui foreach out of varlist gavediag corrdiag wrongdiag {
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1 & drugpres==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode if drugpres==1, absorb(groupcode) vce(robust)
	}

	esttab using "$output/nodrug_test.csv", b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) append 


	eststo clear
	qui foreach out of varlist corrtreat pcorrtreat partcorrtreat referral corrdrug pcorrdrug ///
	drugpres numofdrug antibiotic numedl numnonedl numedlprov numnonprovedl nonedldrug harmful uselessdrug {
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1 & drugpres==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode if drugpres==1, absorb(groupcode) vce(robust)
	}

	esttab using "$output/nodrug_test.csv", b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) append 
			
			
			eststo clear
	qui foreach out of varlist diagtime_min diagtime arq arqe {
		eststo: reg 	`out' nodrug_b nodrug_a angina  		if THC==1, 					vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina  		if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1 & drugpres==1, absorb(towncode) vce(robust)

		eststo: reg		`out' nodrug_b nodrug_a angina tuberc THC MVC	 					 , 					 vce(robust)
		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode if drugpres==1, absorb(groupcode) vce(robust)
	}

	esttab using "$output/nodrug_test.csv", b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) replace 
			
	/*-------
	Step 2.3: Table 3 Nodrug and diagnosis
	--------*/	

	eststo clear

	qui foreach out of varlist gavediag corrdiag wrongdiag  {
		eststo: reg 	`out' nodrug_b nodrug_a angina  		if THC==1, 					vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina  		if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)

		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if VC==1, absorb(groupcode) vce(robust)

		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, 				  vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if MVC==1, absorb(groupcode) vce(robust)


		eststo: reg		`out' nodrug_b nodrug_a angina tuberc THC MVC	 					 , 					 vce(robust)
		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
	}

	esttab using nodrug_diag.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) replace

	/*-------
	Step 2.4: Table 4 Nodrug and Treatment
	--------*/	
	
	set matsize 10000
	eststo clear
	qui foreach out of varlist  corrtreat pcorrtreat partcorrtreat referral corrdrug pcorrdrug ///
	drugpres numofdrug antibiotic numedl numnonedl numedlprov numnonprovedl nonedldrug harmful uselessdrug  {
		eststo: reg 	`out' nodrug_b nodrug_a angina  		if THC==1, 					vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina  		if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)

		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if VC==1, absorb(groupcode) vce(robust)

		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, 				  vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if MVC==1, absorb(groupcode) vce(robust)


		eststo: reg		`out' nodrug_b nodrug_a angina tuberc THC MVC	 					 , 					 vce(robust)
		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
	}

	esttab using nodrug_treat.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) replace


	preserve 
		replace nodrug_a=0 if nodrug==0 & nodrug_a==1
		
		set matsize 10000
		eststo clear
		qui foreach out of varlist  corrtreat pcorrtreat partcorrtreat referral corrdrug pcorrdrug ///
		drugpres numofdrug antibiotic {
			eststo: reg 	`out' nodrug_b nodrug_a angina  		if THC==1, 					vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina  		if THC==1, absorb(towncode) vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)

			eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, 					 vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, absorb(groupcode) vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if VC==1, absorb(groupcode) vce(robust)

			eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, 				  vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, absorb(groupcode) vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if MVC==1, absorb(groupcode) vce(robust)


			eststo: reg		`out' nodrug_b nodrug_a angina tuberc THC MVC	 					 , 					 vce(robust)
			eststo: reg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , 					 vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , absorb(groupcode) vce(robust)
			eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
		}

		esttab using nodrug_treat_new.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
				ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) replace
	restore

	
	/*-------
	Step 2.4: Table 5 Nodrug and Fees
	--------*/	
*Fees
/*
// Are drug fees imputed for when we do not buy? (using average price of drugs in data)
we have 23 cases (14 Diarrhea and 9 Angina in THC) have drug recommended but the SPs did not buy, 
buy only 1 of 23 cases we know the price for the drug. VC does not have this kind of case.
thc_d_v_Q4_8 thc_d_v_Q4_9 thc_a_v_Q4_8 thc_a_v_Q4_8
	
*/		
*Excluding when SP for got to say...
//vill_no_drug1 vill_no_drug2 thc_nodrug_b thc_nodrug_a

	replace drugfee=totfee if drugfee==. & totfee!=.

	eststo clear
	qui foreach out of varlist totfee drugfee {
		eststo: reg 	`out' nodrug_b nodrug_a angina  		if THC==1, 					vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina  		if THC==1, absorb(towncode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina $doccha 	if THC==1, absorb(towncode) vce(robust)

		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if VC==1, absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if VC==1, absorb(groupcode) vce(robust)

		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, 				  vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc 			i.countycode if MVC==1, absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc $doccha 	i.countycode if MVC==1, absorb(groupcode) vce(robust)


		eststo: reg		`out' nodrug_b nodrug_a angina tuberc THC MVC	 					 , 					 vce(robust)
		eststo: reg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , 					 vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC 			i.countycode , absorb(groupcode) vce(robust)
		eststo: areg 	`out' nodrug_b nodrug_a angina tuberc THC MVC $doccha 	i.countycode , absorb(groupcode) vce(robust)
	}

	esttab using nodrug_fee.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
			ar2(2) keep(nodrug_b nodrug_a pracdoc angina tuberc THC MVC) replace
	
Stop

eststo clear
foreach out of varlist diagtime_min theta_mle arqe corrtreat pcorrtreat referral drugpres numofdrug harmful uselessdrug antibiotic numedl numnonedl nonedldrug {	
	eststo: areg `out' nodrug_b nodrug_a angina if VC==0, absorb(towncode) vce(robust)
			test nodrug_b=nodrug_a
			estadd scalar pval = `r(p)'
			
			su `out' if VC==0 & nodrug_a==0 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	
	eststo: reg `out' nodrug_b  angina tuberc i.countycode if VC==1,  vce(robust)
			
			su `out' if VC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
}
esttab using nodrug_forprez.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
		ar2(2) keep(nodrug_b nodrug_a ) scalar(pval mean) replace
			
eststo clear
foreach out of varlist diagtime_min theta_mle arqe corrtreat pcorrtreat referral drugpres numofdrug harmful uselessdrug antibiotic numedl numnonedl nonedldrug {	
	eststo: areg `out' nodrug_b nodrug_a angina if VC==0 & disease!="D", absorb(countycode) vce(robust)
			test nodrug_b=nodrug_a
			estadd scalar pval = `r(p)'
			
			su `out' if VC==0 & nodrug_a==0 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	
	eststo: reg `out' nodrug_b  angina tuberc i.countycode if VC==1 & disease!="D",  vce(robust)
			
			su `out' if VC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
}
esttab using nodrug_forprez_nodiar.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
		ar2(2) keep(nodrug_b nodrug_a ) scalar(pval mean) replace
			
			
eststo clear
foreach out of varlist diagtime_min theta_mle arqe corrtreat pcorrtreat referral drugpres numofdrug harmful uselessdrug antibiotic numedl numnonedl nonedldrug {	
	
	eststo: areg `out' nodrug_b nodrug_a angina age pracdoc  i.MFgrouptype if VC==0, absorb(towncode) vce(robust)
			test nodrug_b=nodrug_a
			estadd scalar pval = `r(p)'
			
			su `out' if VC==0 & nodrug_a==0 & nodrug_b==0
			estadd scalar mean = `r(mean)'
	
	eststo: reg `out' nodrug_b  angina tuberc i.countycode age pracdoc  i.MFgrouptype if VC==1,  vce(robust)
			
			su `out' if VC==1 & nodrug_b==0
			estadd scalar mean = `r(mean)'
}
esttab using nodrug_forprez_cont.csv, b(%9.3fc) se(%9.3fc) starlevels( * 0.1 ** 0.05 *** 0.01) ///
		ar2(2) keep(nodrug_b nodrug_a ) scalar(pval mean) replace
			
			

		
