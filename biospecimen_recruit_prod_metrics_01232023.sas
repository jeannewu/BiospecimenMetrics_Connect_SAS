****
the clinical biospecimen metrics template iniation is Clinical Metrics Draft: https://nih.app.box.com/file/1037513568428
https://github.com/Analyticsphere/metricsReportsRequests/issues/8
https://github.com/Analyticsphere/metricsReportsRequests/files/9811840/Metrics.clinical.additioanal.mock.ups.10.13.22.docx
Below is a list of QC checks we would like Jing to check for regularly on the clinical biospecimen data. from Domonique via 
email on Oct. 27, 2022 


These items will be an overall review/check and an output listing of any of these occurrences.

A comparison of the blood accession ID sent from KP (BioClin_SntBloodAccID_v1r0) and the blood accession ID entered in the 
biospecimen dashboard (BioClin_DBBloodID_v1r0). The output for this comparison is a list of any blood accession IDs that do 
not match and should only include samples with a blood accession ID from both sources. The list should include the Site, 
Connect ID, and blood accession ID from both sources.

A comparison of the urine accession ID sent from KP (BioClin_SntUrineAccID_v1r0) and the urine accession ID entered in the 
biospecimen dashboard (BioClin_DBUrineID_v1r0). The output for this comparison is a list of any urine accession IDs that do 
not match and should only include samples with a urine accession ID from both sources. The list should include the Site, 
Connect ID, and urine accession ID from both sources.

A comparison of the blood date received at the RRL from KP data (BioClin_SiteBloodRRLDt_v1r0) with the blood date received at 
the RRL from the biospecimen dashboard (BioClin_DBBloodRRLDt_v1r0). The output for this comparison is a list of any dates 
received that do not match and should only include samples with a blood date received from both sources. The list should 
include the Site, Connect ID, blood accession ID, and blood date received from both sources.

A comparison of the urine date received at the RRL from KP data (BioClin_SiteUrineRRLDt_v1r0) with the urine date received at 
the RRL from the biospecimen dashboard (BioClin_DBUrineRRLDt_v1r0). The output for this comparison is a list of any dates 
received that do not match and should only include samples with a urine date received from both sources. The list should 
include the Site, Connect ID, urine accession ID, and urine date received from both sources.

Output list of any instances where data sent by KP says a baseline blood sample was collected (BioClin_SiteBloodColl_v1r0 = Yes), 
but the biospecimen dashboard does not have a record of receiving a baseline blood sample at the RRL 
(BioClin_DBBloodRRL_v1r0 = No). This output list should include the Site, the Connect ID, the accession ID from KP, the date 
blood collected sent by KP, and the blood collection location sent by KP.

Output list of any instances where data sent by KP says a baseline blood sample was not collected 
(BioClin_SiteBloodColl_v1r0 = No), but the biospecimen dashboard has a record of receiving a baseline blood sample at the RRL 
(BioClin_DBBloodRRL_v1r0 = Yes). This output list should include the Site, the Connect ID, the accession ID from KP, the date 
blood collected sent by KP, and the blood collection location sent by KP.

Output list of any instances where data sent by KP says a baseline urine sample was collected (BioClin_SiteUrineColl_v1r0=Yes), 
but the biospecimen dashboard does not have a record of receiving a baseline urine sample at the RRL 
(BioClin_DBUrineRRL_v1r0=No). This output list should include the Site, the Connect ID, the accession ID from KP, the date urine 
collected sent by KP, and the urine collection location sent by KP.

Output list of any instances where the data sent by KP says a baseline urine sample was not collected 
(BioClin_SiteUrineColl_v1r0=No), but the biospecimen dashboard has a record of receiving a baseline urine sample at the RRL 
(BioClin_DBUrineRRL_v1r0=Yes). This output list should include the Site, the Connect ID, the accession ID from KP, the date 
urine collected sent by KP, and the urine collection location sent by KP.
*****;
***Nov. 16, 2022, as Michelle recommended, the survey complete with biospecimen collection would be censored by the "check-in" time 
not the flag for the checkin completion;

libname data "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data";
option nofmterr;
ods listing;ods html close;
filename tab1ctsp '\\Mac\Home\Documents\My SAS Files\9.4\SASmacro\Table1_CTSPedia_local.sas';
%include tab1ctsp ;

filename tab1prt '\\Mac\Home\Documents\My SAS Files\9.4\SASmacro\Table1Print_CTSPedia.sas';
%include tab1prt;
proc format;
	VALUE BioColTubeCompleFmt
			104430631 = "No"
			353358909 = "Complete"
			200000000 = "Partial";
	VALUE BioSpecimenFmt
			104430631 = "No Blood, or Urine or MouthWash Collection"
			353358909 = "Any Collections of Blood, or Urine or MouthWash"; 

data bio_settingfmt; 
attrib BioSpm_Setting_v1r0 label = "Collection Setting" format = BioSpmSettingFmt.;
input BioSpm_Setting_v1r0 @@;
cards;
534621077 664882224 103209024
run;
proc sort data=recr_prod_biosum; by connect_Id BioSpm_Setting_v1r0; run;
data bio_settingfmt;
length Label $20.;
set bio_settingfmt;
if BioSpm_Setting_v1r0=534621077 then Label="   Research";
if BioSpm_Setting_v1r0=664882224 then Label="   Clinical";
if BioSpm_Setting_v1r0=103209024 then Label="   Home"; run;

data tmp0; set RECR_PROD_BIOSUM;/*n=4992*/
by connect_id; 
if BioBld_Complete_resh in ( .,104430631) and BioBld_Complete_clc in ( .,104430631) then biobld_complete =104430631;
else if BioBld_Complete_resh > 104430631  or BioBld_Complete_clc >104430631 then biobld_complete =min(BioBld_Complete_resh,BioBld_Complete_clc);

if UrineTube1_TubeCollected_yes=. then UrineTube1_TubeCollected_yes=104430631;
if MWTube1_TubeCollected_yes=. then MWTube1_TubeCollected_yes=104430631;
if BioFin_BaseBloodCol_v1r0=. then BioFin_BaseBloodCol_v1r0=104430631;
if BioFin_BaseUrineCol_v1r0=. then BioFin_BaseUrineCol_v1r0=104430631;
if BioFin_BaseMouthCol_v1r0=. then BioFin_BaseMouthCol_v1r0=104430631;
if BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0=104430631 then BioFin_BaseSpeci_v1r0=104430631;
else BioFin_BaseSpeci_v1r0=353358909;

format biobld_complete BioColTubeCompleFmt. UrineTube1_TubeCollected_yes BioColTubeCollFmt. MWTube1_TubeCollected_yes BioColTubeCollFmt.
BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt. BioFin_BaseUrineCol_v1r0 BioColTubeCollFmt. BioFin_BaseMouthCol_v1r0 BioColTubeCollFmt.
BioFin_BaseSpeci_v1r0 BioSpecimenFmt. BioSpm_Visit_v1r0 BioSpmVisitFmt.;
run;
data tmp; set RECR_PROD_BIOSUM;/*n=4992*/
by connect_id; 
if BioBld_Complete_resh in ( .,104430631) and BioBld_Complete_clc in ( .,104430631) then biobld_complete =104430631;
else if BioBld_Complete_resh > 104430631  or BioBld_Complete_clc >104430631 then biobld_complete =min(BioBld_Complete_resh,BioBld_Complete_clc);

if UrineTube1_TubeCollected_yes=. then UrineTube1_TubeCollected_yes=104430631;
if MWTube1_TubeCollected_yes=. then MWTube1_TubeCollected_yes=104430631;
if BioFin_BaseBloodCol_v1r0=. then BioFin_BaseBloodCol_v1r0=104430631;
if BioFin_BaseUrineCol_v1r0=. then BioFin_BaseUrineCol_v1r0=104430631;
if BioFin_BaseMouthCol_v1r0=. then BioFin_BaseMouthCol_v1r0=104430631;
if BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0=104430631 then BioFin_BaseSpeci_v1r0=104430631;
else BioFin_BaseSpeci_v1r0=353358909;

format biobld_complete BioColTubeCompleFmt. UrineTube1_TubeCollected_yes BioColTubeCollFmt. MWTube1_TubeCollected_yes BioColTubeCollFmt.
BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt. BioFin_BaseUrineCol_v1r0 BioColTubeCollFmt. BioFin_BaseMouthCol_v1r0 BioColTubeCollFmt.
BioFin_BaseSpeci_v1r0 BioSpecimenFmt. BioSpm_Visit_v1r0 BioSpmVisitFmt.;
if first.connect_id=1 then output;
run;/*n=5195 removed 1 dup on clinical setting */
title;
footnote;
proc print data=concept_idsbios;var BioCol_ColNote1_v1r0 connect_id BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0 BioRec_CollectFinal_v1r0 BioRec_CollectFinalTime_v1r0
BioCol_ColTime_v1r0 BioSpm_ColIDScan_v1r0;
where connect_id=2310991421;
run;
***Obs BioCol_ColNote1_v1r0

 172
 173 CXA000929 was accidentally tied to this connect participant as a clinical specimen collection. That kit will not be used as this is a research specimen collection

                                                                                             BioRec_                                                         BioSpm_
                     BioSpm_                                               RcrtES_Site_      Collect             BioRec_Collect                             ColIDScan_
 Obs Connect_ID    Setting_v1r0           BioSpm_Location_v1r0                 v1r0         Final_v1r0           FinalTime_v1r0      BioCol_ColTime_v1r0       v1r0

 172 2310991421      Clinical                                        .    HealthPartners         .                            .                        .    CXA000929
 173 2310991421      Research      HP Research Clinic                     HealthPartners       Yes        13DEC2022:15:35:57.39    13DEC2022:15:09:26.59    CXA003561
*******;
proc print data=recr_prod_biosum noobs;
var connect_id BL_BioSpm_BloodSetting_v1r0 BL_BioClin_SntBloodAccID_v1r0 BioFin_BaseBloodCol_v1r0 BioBld_Complete_clc BioBld_Complete_resh;
where BioFin_BaseUrineCol_v1r0>0 and  UrineTube1_TubeCollected_clc>0 and BioFin_BaseUrineCol_v1r0=UrineTube1_TubeCollected_clc;
run;

proc freq data=tmp; table biobld_complete*BioFin_BaseBloodCol_v1r0 BioFin_baseUrineCol_v1r0*UrineTube1_TubeCollected_yes
BioFin_BaseMouthCol_v1r0*MWTube1_TubeCollected_yes/list missing; run;
****
                                                       BioFin_Base                             Cumulative    Cumulative
                               biobld_complete       BloodCol_v1r0    Frequency     Percent     Frequency      Percent
                               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                               No                 No                      4036       74.73          4036        74.73
                               Partial            Yes                       58        1.07          4094        75.80
                               Complete           Yes                     1307       24.20          5401       100.00


                                   BioFin_Base     UrineTube1_Tube                             Cumulative    Cumulative
                                 UrineCol_v1r0       Collected_yes    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              No                  No                      3991       73.89          3991        73.89
                              Yes                 Yes                     1410       26.11          5401       100.00


                                   BioFin_Base        MWTube1_Tube                             Cumulative    Cumulative
                                 MouthCol_v1r0       Collected_yes    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              No                  No                      3982       73.73          3982        73.73
                              Yes                 Yes                     1419       26.27          5401       100.00
******;
proc freq data=recr_prod_biosum; table RcrtES_Site_v1r0*BioSpm_Setting_v1r0*( checkvisit_resh checkvisit_clc)/list missing; run;

proc freq data=tmp; tables RcrtES_Site_v1r0 BioSpm_Setting_v1r0 BioFin_BaseSpeci_v1r0
RcrtES_Site_v1r0*BioSpm_Setting_v1r0*BioFin_BaseSpeci_v1r0*SrvBLM_ResSrvCompl_v1r0
BioSpm_Setting_v1r0*BioBld_Complete*BioBld_Complete_resh*BioBld_Complete_clc SrvBLM_ResSrvCompl_v1r0*checkvisit_resh 
RcrtES_Site_v1r0*BioSpm_Setting_v1r0*SrvBlU_BaseComplete_v1r0*SrvBLM_ResSrvCompl_v1r0/list missing; run; 
***********;
proc freq data=tmp; table BioFin_BaseSpeci_v1r0*BioFin_BaseBloodCol_v1r0*BioFin_BaseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list missing;run;
proc freq data=tmp; table BioFin_BaseSpeci_v1r0*MWTube1_TubeCollected_yes*MWTube1_TubeCollected_yes*biobld_complete/list missing;run;

data no_biospe;
set tmp;
if BioFin_BaseSpeci_v1r0= 353358909 then do;
if biobld_complete=104430631 and UrineTube1_TubeCollected_yes=104430631 and MWTube1_TubeCollected_yes=104430631 then
output;
end;
run;/*0*/
ods html;
proc print data=no_biospe noobs;
var connect_ID RcrtES_Site_v1r0 BioSpm_Setting_v1r0 BioFin_BaseBloodCol_v1r0 BioFin_BaseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0;
run;
****                                                                                  BioFin_      BioFin_      BioFin_
                                                                                   Base         Base         Base
                                                RcrtES_Site_       BioSpm_       BloodCol_    UrineCol_    MouthCol_
                                 Connect_ID         v1r0         Setting_v1r0      v1r0         v1r0         v1r0

                                 2310991421    HealthPartners      Clinical         Yes          Yes          Yes
******;
proc sort data=tmp;
by BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 descending BL_BioChk_Complete_v1r0 BioFin_BaseBloodCol_v1r0;
run;
/*Table8.Total number (and percent) of checked-in baseline blood collections;*/
proc freq data=tmp;
table BioSpm_Setting_v1r0*BioSpm_Visit_v1r0*BioFin_BaseBloodCol_v1r0 /out=FreqCount cumcol TOTPCT OUTPCT list missing noprint;
where BL_BioChk_Time_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt.;
run;***NOTE: There were 1341 observations read from the data set WORK.TMP.
      WHERE (BL_BioChk_Time_v1r0 not = .) and (BioSpm_Visit_v1r0=266600170)
NOTE: The data set WORK.FREQCOUNT has 2 observations and 8 variables.;

proc print data=freqcount noobs; run;/*to check the people after their check-in on their blood collections by their collection settings*/
***
                                                                          BioFin_
                                                                           Base
                                             BioSpm_        BioSpm_      BloodCol_
                                           Setting_v1r0    Visit_v1r0      v1r0       COUNT    PERCENT    PCT_TABL    PCT_ROW    PCT_COL

                                             Research       Baseline        No           61     4.5488      4.5488     4.5488      100
                                             Research       Baseline        Yes        1280    95.4512     95.4512    95.4512      100******;
proc freq data=tmp; 
tables UrineTube1_TubeCollected_yes MWTube1_TubeCollected_yes biobld_complete BioFin_BaseBloodCol_v1r0*biobld_complete
BioFin_BaseUrineCol_v1r0*UrineTube1_TubeCollected_yes BioFin_BaseMouthCol_v1r0*MWTube1_TubeCollected_yes 
UrineTube1_TubeCollected_yes*MWTube1_TubeCollected_yes*biobld_complete*SrvBLM_ResSrvCompl_v1r0/list missing; run;
***
                                                               Urine
                                                              Tube1_
                                                                Tube
                                                          Collected_                             Cumulative    Cumulative
                                                                 yes    Frequency     Percent     Frequency      Percent
                                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                 No         3865       74.40          3865        74.40
                                                                 Yes        1330       25.60          5195       100.00


                                                            MWTube1_
                                                                Tube
                                                          Collected_                             Cumulative    Cumulative
                                                                 yes    Frequency     Percent     Frequency      Percent
                                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                 No         3856       74.23          3856        74.23
                                                                 Yes        1339       25.77          5195       100.00


                                                            biobld_                             Cumulative    Cumulative
                                                           complete    Frequency     Percent     Frequency      Percent
                                                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                           No              3907       75.21          3907        75.21
                                                           Partial           49        0.94          3956        76.15
                                                           Complete        1239       23.85          5195       100.00


                                                   BioFin_Base                                                Cumulative    Cumulative
                                                 BloodCol_v1r0    biobld_complete    Frequency     Percent     Frequency      Percent
                                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                              No                  No                     3907       75.21          3907        75.21
                                              No                  Complete                  1        0.02          3908        75.23
                                              Yes                 Partial                  49        0.94          3957        76.17
                                              Yes                 Complete               1238       23.83          5195       100.00


                                                  BioFin_Base     UrineTube1_Tube                             Cumulative    Cumulative
                                                UrineCol_v1r0       Collected_yes    Frequency     Percent     Frequency      Percent
                                             ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                             No                  No                      3865       74.40          3865        74.40
                                             No                  Yes                        1        0.02          3866        74.42
                                             Yes                 Yes                     1329       25.58          5195       100.00

                                                  BioFin_Base        MWTube1_Tube                             Cumulative    Cumulative
                                                MouthCol_v1r0       Collected_yes    Frequency     Percent     Frequency      Percent
                                             ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                             No                  No                      3856       74.23          3856        74.23
                                             No                  Yes                        1        0.02          3857        74.24
                                             Yes                 Yes                     1338       25.76          5195       100.00


                           UrineTube1_Tube        MWTube1_Tube                          SrvBLM_ResSrv                             Cumulative    Cumulative
                             Collected_yes       Collected_yes    biobld_complete          Compl_v1r0    Frequency     Percent     Frequency      Percent
                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                          No                  No                  No                 Started                    1        0.02             1         0.02
                          No                  No                  No                 Not Started             3847       74.05          3848        74.07
                          No                  Yes                 No                 Submitted                  1        0.02          3849        74.09
                          No                  Yes                 No                 Not Started                1        0.02          3850        74.11
                          No                  Yes                 Complete           Submitted                 10        0.19          3860        74.30
                          No                  Yes                 Complete           Started                    1        0.02          3861        74.32
                          No                  Yes                 Complete           Not Started                4        0.08          3865        74.40
                          Yes                 No                  Partial            Not Started                7        0.13          3872        74.53
                          Yes                 No                  Complete           Not Started                1        0.02          3873        74.55
                          Yes                 Yes                 No                 Submitted                 38        0.73          3911        75.28
                          Yes                 Yes                 No                 Started                    2        0.04          3913        75.32
                          Yes                 Yes                 No                 Not Started               17        0.33          3930        75.65
                          Yes                 Yes                 Partial            Submitted                 28        0.54          3958        76.19
                          Yes                 Yes                 Partial            Not Started               14        0.27          3972        76.46
                          Yes                 Yes                 Complete           Submitted               1124       21.64          5096        98.09
                          Yes                 Yes                 Complete           Started                   13        0.25          5109        98.34
                          Yes                 Yes                 Complete           Not Started               86        1.66          5195       100.00
******;
proc print data=tmp;
var Connect_id BioSpm_Location_v1r0 biobld_complete BioFin_BaseBloodCol_v1r0 BioFin_BaseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0
UrineTube1_TubeCollected_yes MWTube1_TubeCollected_yes SrvBLM_ResSrvCompl_v1r0;
where BioFin_BaseBloodCol_v1r0=BioFin_BaseUrineCol_v1r0= 104430631 and UrineTube1_TubeCollected_yes=MWTube1_TubeCollected_yes=353358909;
run;
***                                                                                                                  Urine
                                                                              BioFin_      BioFin_      BioFin_       Tube1_       MWTube1_
                                                                               Base         Base         Base          Tube          Tube        SrvBLM_
                                                   BioSpm_       biobld_     BloodCol_    UrineCol_    MouthCol_    Collected_    Collected_      ResSrv
                           Obs    Connect_ID    Location_v1r0    complete      v1r0         v1r0         v1r0          yes           yes        Compl_v1r0

                          3877    5312274299       UC-DCAM       Complete       No           No           No           Yes           Yes        Submitted
*******;
proc freq data=tmp; table BioSpm_Setting_v1r0*BioFin_BaseSpeci_v1r0/list missing; run;
**                               BioSpm_Setting_                                                                                Cumulative    Cumulative
                                          v1r0                              BioFin_BaseSpeci_v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                     .            No Blood, or Urine or MouthWash Collection             3847       74.05          3847        74.05
                              Research            No Blood, or Urine or MouthWash Collection                2        0.04          3849        74.09
                              Research            Any Collections of Blood, or Urine or MouthWash        1339       25.77          5188        99.87
                              Clinical            Any Collections of Blood, or Urine or MouthWash           7        0.13          5195       100.00
*****;
proc print data=tmp noobs; /* before removal of these two dup*/
var BioSpm_Setting_v1r0 Connect_ID BioFin_BaseSpeci_v1r0 RcrtES_Site_v1r0 BioFin_BaseBloodCol_v1r0 BioFin_BaseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0;
where BioSpm_Setting_v1r0 >0 and BioFin_BaseSpeci_v1r0=104430631;
run;
***                                                                                                                             BioFin_      BioFin_      BioFin_
                                                                                                                                 Base         Base         Base
                   BioSpm_                                                                                                     BloodCol_    UrineCol_    MouthCol_
                 Setting_v1r0    Connect_ID              BioFin_BaseSpeci_v1r0                      RcrtES_Site_v1r0             v1r0         v1r0         v1r0

                   Research      5312274299    No Blood, or Urine or MouthWash Collection    University of Chicago Medicine       No           No           No
                   Research      9214463637    No Blood, or Urine or MouthWash Collection    Henry Ford Health System             No           No           No
********;
*Table 1. Percent (and number) of verified participants with baseline biospecimens. 
Any samples includes blood, urine, and/or mouthwash based on data entered into Connect biospecimen dashboard.
Note: Make sure Any Samples Collected includes all of the additional blood tubes for clinical samples.
**********;

%macro freq_t(var, note, date,condition, format,t);
proc freq data=tmp;
title "Percent (and number) of verified participants with the baseline &note collected from participants of all sites &date";
tables &var /list missing out=&t. noprint;
format &var &format;
where connect_id &condition.;
run;

proc transpose data=&t out=t_&t. prefix=&var._;
format &var &format;
id &var.;
idlabal &var.;
run;

data tmp_c; set tmp; 
where connect_id &condition.;run;

%Table1_CTSPedia(DSName=tmp_c, GroupVar=&var,
                NumVars=,
FreqVars = RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=Biospec_&t.);

%mend;
%freq_t(BioFin_BaseSpeci_v1r0, any biospecimen, 01232023,  >0,BioSpecimenFmt.,zero);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_BaseBloodCol_v1r0 , blood, 01232023,  >0, BioColTubeCollFmt.,one);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_baseUrineCol_v1r0, Urine, 01232023,  >0,BioColTubeCollFmt., two);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_BaseMouthCol_v1r0, Mouthwash, 0123023, >0,BioColTubeCollFmt.,three);/*the table is freqcell=N(RP)*/

%freq_t(BioBld_Complete, complete blood collection of all biospecimen collection, 01232023, =connectbio_id and BioFin_BaseBloodCol_v1r0=353358909,BioColTubeCollFmt.,six);
%freq_t(BioBld_Complete, complete blood collection of all biospecimen collection, 01232023,
=connectbio_id and BioRec_CollectFinal_v1r0>0, BioColTubeCollFmt., seven);


***for the research collections;
%freq_t(BioFin_BaseSpeci_v1r0, any biospecimen, 01232023,>0 and BioSpm_Setting_v1r0= 534621077,BioSpecimenFmt.,zero1);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_BaseBloodCol_v1r0 , blood, 01232023, >0 and BioSpm_Setting_v1r0= 534621077, BioColTubeCollFmt.,one1);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_baseUrineCol_v1r0, Urine, 01232023, >0 and BioSpm_Setting_v1r0= 534621077,BioColTubeCollFmt., two1);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_BaseMouthCol_v1r0, Mouthwash, 01232023,>0 and  BioSpm_Setting_v1r0= 534621077,BioColTubeCollFmt.,three1);/*the table is freqcell=N(RP)*/

%freq_t(BioBld_Complete, complete blood collection of all biospecimen collection, 01232023, =connectbio_id and BioSpm_Setting_v1r0= 534621077,BioColTubeCollFmt.,seven1);
proc freq data=Recrbio_clinic;table BioBld_Complete_clc/list missing cumcol out=eight;run;

data zero;
set zero;
total=count*100/percent; 
N_percent=put(count, 4.2)||" ("||put(percent,4.2)||")";
run;
proc transpose data=zero out=t_zero prefix=_;
format BioFin_BaseSpeci_v1r0 BioSpecimenFmt.;
var N_percent;
id BioFin_BaseSpeci_v1r0;
idlabel BioFin_BaseSpeci_v1r0;
run;
/*here the total numbero of biospecimen should be manually input due to the difference in each biospecimen data by week***/
data t_zero;
set t_zero;
total="5401 (100)";
label total="total verified participants";
run;



%Table1_CTSPedia(DSName=tmp, GroupVar=BioFin_BaseSpeci_v1r0,
                  NumVars=,
FreqVars = RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=Biospe);


proc freq data=tmp;
*title "Percent (and number) of verified participants Blood, Urine and Mouthwash collected with the baseline participants 11082022";
tables BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0*BioFin_BaseBloodCol_v1r0/list missing out=one;
run;
***                                        BioFin_Base         BioFin_Base         BioFin_Base                             Cumulative    Cumulative
                                      UrineCol_v1r0       MouthCol_v1r0       BloodCol_v1r0    Frequency     Percent     Frequency      Percent
                                   ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                   No                  No                  No                       149       67.12           149        67.12
                                   No                  No                  Yes                        2        0.90           151        68.02
                                   No                  Yes                 No                         5        2.25           156        70.27
                                   No                  Yes                 Yes                        4        1.80           160        72.07
                                   Yes                 No                  No                         1        0.45           161        72.52
                                   Yes                 No                  Yes                        9        4.05           170        76.58
                                   Yes                 Yes                 Yes                       52       23.42           222       100.00
*********;
ods html;
proc freq data=tmp;
tables BL_BioSpm_UrineSetting_v1r0*BioFin_BaseUrineCol_v1r0*BL_BioClin_DBUrineRRL_v1r0*BL_BioClin_SiteUrineColl_v1r0
BL_BioClin_SiteUrineRRL_v1r0*BL_BioClin_DBUrineRRL_v1r0*BL_BioClin_SiteUrineColl_v1r0
BL_BioClin_SiteBloodRRL_v1r0*BL_BioClin_DBBloodRRL_v1r0*BL_BioClin_SiteBloodColl_v1r0/list missing;run;
***                          BL_BioSpm_Urine         BioFin_Base         BL_BioClin_     BL_BioClin_Site                             Cumulative    Cumulative
                             Setting_v1r0       UrineCol_v1r0     DBUrineRRL_v1r0      UrineColl_v1r0    Frequency     Percent     Frequency      Percent
                         ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                .            No                    .                   .                      158       71.17           158        71.17
                                .            No                    .                 Yes                        2        0.90           160        72.07
                         Research            Yes                   .                   .                       57       25.68           217        97.75
                         Clinical            Yes                 Yes                 Yes                        5        2.25           222       100.00
                                 BL_BioClin_Site         BL_BioClin_     BL_BioClin_Site                             Cumulative    Cumulative
                                      UrineRRL_v1r0     DBUrineRRL_v1r0      UrineColl_v1r0    Frequency     Percent     Frequency      Percent
                                   ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                     .                   .                   .                      215       96.85           215        96.85
                                   Yes                   .                 Yes                        2        0.90           217        97.75
                                   Yes                 Yes                 Yes                        5        2.25           222       100.00
                    BL_BioClin_Site         BL_BioClin_     BL_BioClin_Site                             Cumulative    Cumulative
                       BloodRRL_v1r0     DBBloodRRL_v1r0      BloodColl_v1r0    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                      .                   .                   .                      214       96.40           214        96.40
                    Yes                   .                 Yes                        3        1.35           217        97.75
                    Yes                 Yes                 Yes                        5        2.25           222       100.00
**********;
***Table 12. a table after this pie chart to compare KP blood per API vs KP blood per dashboard:
****a. Any Blood Collected (data from dashboard)
****b, Any Blood Collected (data sent by KP)
***denominator is all verified participants that is used as the percent denominator for all cells;



***Table 13.Urine collected status according to data sent by KP vs data entered into Connect dashboard at RRL;
***the RRL is Regional Reference Lab. This is where clinical collections arrive for processing and shipping;
******BL_BioClin_DBUrineRRL_v1r0 ="Clinical DB Urine RRL Received"
		BL_BioClin_SiteUrineColl_v1r0 ="Clinical Site Urine collected"
		BL_BioClin_SiteUrineRRL_v1r0 ="Clinical Site Urine RRL Received";
*%freq_t(BioBld_Complete_clc, complete blood collection of all biospecimen collection, 01092023, =connectbio_id and BioSpm_Setting_v1r0= 664882224,BioColTubeCollFmt.,eight);
%Table1_CTSPedia(DSName=Recrbio_clinic, GroupVar=BioBld_Complete_clc,
                  NumVars=,
FreqVars = RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=Biospe);


*Table 2. Change title to drop words 'by site' and add sentence to title: Based on data entered into Connect Biospecimen Dashboard.
Note: Make sure Blood Collected includes all clinical blood tubes.

Table 3. Drop words 'by site' from title. Add sentence to title: Based on data entered into Connect Biospecimen Dashboard.
Table 4. Change title to drop words 'by site'

Table 5. Add sentence to title: Based on data entered into Connect Biospecimen Dashboard.
Note: Make sure blood collected includes the additional clinical blood tubes.
After Table 5, add this same table by site (add a column on the far left for Site). Then renumber all the tables that follow.

Table 6. Make sure blood collected includes the additional clinical blood tubes.
Commments_M: Add in new table after table 6. Title will be Table X: Blood completeness among baseline clinical blood collections. Stephanie will provide mockup.

Comments_S: Denominator is participants with any clinical blood collection: Table X: Blood completeness among baseline clinical blood collections. 
***********;

%macro coll_check(type);
data biospec; set tmp; where connect_id=connectbio_id ; run;

%Table1_CTSPedia(DSName=biospec, GroupVar=BioFin_Base&type.Col_v1r0,
                NumVars=,
FreqVars = BioSpm_Setting_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=&type);

proc sort data=bio_settingfmt; by label;run;
proc sort data=&type; by label; run;
data combo; merge bio_settingfmt  &type.;
by label;
run;
data &type.1; set combo;
if BioSpm_Setting_v1r0=. and label=" " then delete;

if total=" " then  total="0";
if GroupVal1=" " then  GroupVal1="0";
if GroupVal2=" " then GroupVal2="0";
if Label="Collection Setting" then delete;
drop BioSpm_Setting_v1r0;
Label Label="Collection Setting";
rename GroupVal1=&type._Val1 GroupVal2=&type._Val2 Pvalue1=&type._PValue1 Pvalue2=&type._Pvalue2 total=&type._total;

/*keep GroupVal1 GroupVal2 label Total Pvalue1 pvalue2;*/
run;
%mend;
%coll_check(Blood);
%coll_check(Urine);
%coll_check(Mouth);
/*data tmp2;set tmp; if BioSpm_Setting_v1r0=534621077 then output;run;
 data bloodcollect;set tmp2;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
run;*/
/*Table 13 (original table8) Total number (and percent) of checked-in baseline blood collections
As Michelle corrected on Nov. 16, 2022 " the check-in would be the check-in time and the check-in completion flag 
Therefore, this table is to present the counts of the participants who had their check-in time with their blood collections*/
proc freq data=tmp;
table BioSpm_Setting_v1r0*BioSpm_Visit_v1r0*BioFin_BaseBloodCol_v1r0 /out=FreqCount cumcol TOTPCT OUTPCT list noprint;
where BL_BioChk_Time_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt. BioSpm_Visit_v1r0 BioSpmVisitFmt. ;
run;

proc sort data=freqcount; by BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 BioFin_BaseBloodCol_v1r0;run;

proc print data=freqcount noobs; run;
*** Nov. 11,2022
                               BioSpm     Baseline      Baseline                   Percent of     Percent of     Percent     Percent of
               Collection      Visit      Check-In    blood sample    Frequency       Total      2-Way Table      of Row       Column
                Setting         v1r0      Complete     collected        Count       Frequency     Frequency     Frequency     Frequency

                Research     Baseline      No            No               6          8.8235        8.8235        14.286       100.000
                Research     Baseline      No            Yes             36         52.9412       52.9412        85.714        58.065
                Research     Baseline      Yes           Yes             26         38.2353       38.2353       100.000        41.935
After Michelle's correction:                                                        BioFin_
                                                            Base
                              BioSpm_        BioSpm_      BloodCol_
                            Setting_v1r0    Visit_v1r0      v1r0       COUNT    PERCENT    PCT_TABL    PCT_ROW    PCT_COL

                              Research       Baseline        No           57     4.6117      4.6117     4.6117      100
                              Research       Baseline        Yes        1179    95.3883     95.3883    95.3883      100
*******;

data freqcount_w;length N_percent $16.; set freqcount;
by BioSpm_Setting_v1r0 BioSpm_Visit_v1r0;
total=count*100/percent; 
N_percent=put(count, 4.0)||" ("||put(percent,4.2)||")";
if first.BioSpm_Visit_v1r0=1 and BioFin_BaseBloodCol_v1r0 =104430631 then do;
BioFin_BaseBloodCol_v1r0_Yes=put((total-count), 6.0)||" ("||put(round((PCT_col-percent),0.01),4.2)||")";
BioFin_BaseBloodCol_v1r0_No=N_percent;output; end;
label BioFin_BaseBloodCol_v1r0_Yes="Collected"
 BioFin_BaseBloodCol_v1r0_No="Not Collected";run;
proc print data=freqcount_w noobs; run;
 *Table 14 (original table 9) Total number (and percent) of checked-in baseline samples collections;
proc format;
 value typeyesnofmt
 0 = "no blood, no urine, no mouthwash"
 1 = "only blood"
 2 = "only urine"
 3 = "only mouthwash"
 4 = "blood and urine, no mouthwash"
 5 = "blood and mouthwash, no urine"
 6 = "mouthwash and urine, no blood"
 7 = "all blood, urine and mouthwash";
data eight0;
set tmp;
if  BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0=104430631 then BioCollections_v1r0=0;
if BioFin_BaseBloodCol_v1r0=353358909 and BioFin_baseUrineCol_v1r0=104430631 and BioFin_BaseMouthCol_v1r0= 104430631 then BioCollections_v1r0=1;
if BioFin_BaseBloodCol_v1r0=104430631 and BioFin_baseUrineCol_v1r0=353358909 and BioFin_BaseMouthCol_v1r0= 104430631 then BioCollections_v1r0=2;
if BioFin_BaseBloodCol_v1r0= 104430631 and BioFin_baseUrineCol_v1r0= 104430631 and BioFin_BaseMouthCol_v1r0=353358909 then BioCollections_v1r0=3;
if BioFin_BaseBloodCol_v1r0=353358909 and BioFin_baseUrineCol_v1r0=353358909 and BioFin_BaseMouthCol_v1r0= 104430631 then BioCollections_v1r0=4;
if BioFin_BaseBloodCol_v1r0=353358909 and BioFin_baseUrineCol_v1r0= 104430631 and BioFin_BaseMouthCol_v1r0=353358909  then BioCollections_v1r0=5;
if BioFin_BaseBloodCol_v1r0= 104430631 and BioFin_baseUrineCol_v1r0=353358909 and BioFin_BaseMouthCol_v1r0=353358909  then BioCollections_v1r0=6;
if BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0= 353358909 then BioCollections_v1r0=7;
format BioCollections_v1r0 typeyesnofmt.;
run;
data checkin;set eight0;
if BioCollections_v1r0=0 then Bio_BLBUM_collected_v1r0=104430631;
else Bio_BLBUM_collected_v1r0=353358909;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
attrib Bio_BLBUM_collected_v1r0 format=BioColTubeCollFmt. 
label="any blood, urine or MW samples of any type collected at baseline check-in"; 
format BioSpm_Visit_v1r0 BioSpmVisitFmt. ;
run;/*NOTE: There were 1236 observations read from the data set WORK.EIGHT.
WHERE (BL_BioChk_Complete_v1r0 not = .) and (BioSpm_Visit_v1r0=266600170);
NOTE: The data set WORK.CHECKIN has 1236 observations and 82 variables.*/
proc print data=tmp;where BL_BioChk_Complete_v1r0=353358909 and BioSpm_Visit_v1r0=.; var connect_id; run;
/*Connect_id= 9355022053*/

proc freq data=tmp;table BL_BioChk_Complete_v1r0*BioSpm_Visit_v1r0/list missing; run;
***                                   BL_BioChk_       BioSpm_Visit_                             Cumulative    Cumulative
                                 Complete_v1r0                v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                .                           .             3746       75.07          3746        75.07
                                .                 Baseline                   7        0.14          3753        75.21
                              No                  Baseline                1233       24.71          4986        99.92
                              Yes                           .                1        0.02          4987        99.94
                              Yes                 Baseline                   3        0.06          4990       100.00
******;
proc sort data=checkin; by BL_BioChk_Complete_v1r0;run;

proc freq data=checkin;
table BioSpm_Setting_v1r0*BioSpm_Visit_v1r0* Bio_BLBUM_collected_v1r0 /missing cumcol list noprint out=bumincomple;
where BL_BioChk_Time_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format Bio_BLBUM_collected_v1r0 BioColTubeCollFmt.;
run;/*NOTE: The data set WORK.BUMINCOMPLE has 2 observations and 6 variables.*/

***           BioSpm_Setting_       BioSpm_Visit_          BL_BioChk_          Bio_BLBUM_                             Cumulative    Cumulative
                      v1r0                v1r0       Complete_v1r0      collected_v1r0    Frequency     Percent     Frequency      Percent
          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
          Research            Baseline            No                  No                         1        1.47             1         1.47
          Research            Baseline            No                  Yes                       41       60.29            42        61.76
          Research            Baseline            Yes                 Yes                       26       38.24            68       100.00
******;
***NOTE: There were 68 observations read from the data set WORK.CHECKIN.
      WHERE (BL_BioChk_Complete_v1r0 not = .) and (BioSpm_Visit_v1r0=266600170)
NOTE: The data set WORK.BUMINCOMPLE has 3 observations and 5 variables.
******;
proc sort data=bumincomple; by Bio_BLBUM_collected_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0;run;/*n=3*/
data bumincomple_w;length N_percent $16.; set bumincomple; 
by BioSpm_Setting_v1r0 BioSpm_Visit_v1r0;
total=count*100/percent; 
N_percent=put(count, 4.0)||" ("||put(percent,4.2)||"%)";
Bio_BLBUM_collected_v1r0_char=lag(N_percent);
length Bio_BLBUM_collected_v1r0_Yes $16; length Bio_BLBUM_collected_v1r0_No $16.;

if first.BioSpm_Setting_v1r0=1 then do;
if first.BioSpm_Visit_v1r0=1 and last.BioSpm_Visit_v1r0=1 then do;
if Bio_BLBUM_collected_v1r0 =104430631 then do;
 Bio_BLBUM_collected_v1r0_No=N_percent;Bio_BLBUM_collected_v1r0_yes="0 (0%)";
end;
if Bio_BLBUM_collected_v1r0 ^=104430631 then do;
 Bio_BLBUM_collected_v1r0_Yes=N_percent;Bio_BLBUM_collected_v1r0_no="0 (0%)";
end;
end;
end;

 if first.BioSpm_Visit_v1r0=0 and last.BioSpm_Visit_v1r0=1 then do;
	Bio_BLBUM_collected_v1r0_yes=N_percent;
	Bio_BLBUM_collected_v1r0_no=Bio_BLBUM_collected_v1r0_char; end;
if last.BioSpm_Visit_v1r0=1 then output;
label total="Total Number of Baseline Check-in"
Bio_BLBUM_collected_v1r0_Yes="any sample collected"
Bio_BLBUM_collected_v1r0_No="No sample collected";
run;
/*Table 15. */
proc print data=bumincomple_w label noobs split='/' ;
title "Table 15. Total number (and percent) of checked-in baseline samples collections";
var BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 Bio_BLBUM_collected_v1r0_Yes Bio_BLBUM_collected_v1r0_No total;
/*where Bio_BLBUM_collected_v1r0=104430631;*/
run; 

****below are the tables for the biospecimen check, including KP site
***Table 15 Number (and percent) of tubes with any deviation by site;
proc freq data=concept_idsbios; table BioSpm_Setting_v1r0*BioSpm_Visit_v1r0/list missing; run;
data tmp_clin;set tmp0;
keep connect_id RcrtES_Site_v1r0 BioSpm_setting_v1r0 SrvBlU_TmComplete_v1r0
		BL_BioClin_DBBloodRRL_v1r0 /*"Clinical DB Blood RRL Received"*/
		BL_BioClin_SiteBloodColl_v1r0 /*"Clinical Site Blood Collected"*/
		BL_BioClin_BldOrderPlaced_v1r0/*"Blood Order Placed"*/
		BL_BioClin_SntBloodAccID_v1r0 /*"Sent Clinical Blood accession ID"*/
		BL_BioClin_DBBloodRRLDt_v1r0 /*"Clinical DB blood RRL Date/Time Received"*/
		BL_BioClin_SiteBloodRRL_v1r0 /*"Clinical Site Blood RRL Received"*/
		BL_BioClin_BldOrderPlacdDt_v1r0 /*"Date/time Blood order placed"*/
		BL_BioClin_SiteBloodRRLDt_v1r0 /*"Clinical Site Blood RRL Date / Time Received"*/
		BL_BioClin_ClinBloodTime_v1r0 /*="Autogenerated date/time stamp for clinical collection of blood sample"*/
		BL_BioClin_SiteUrLocation_v1r0 /*"Urine Location ID"*/
		BL_BioClin_DBUrineRRL_v1r0 /*"Clinical DB Urine RRL Received"*/
		BL_BioClin_SntUrineAccID_v1r0 /*"Sent Clinical Urine accession ID"*/
		BL_BioClin_SiteUrineRRLDt_v1r0 /*"Clinical Site Urine RRL Date / Time Received"*/
		BL_BioClin_SiteUrineColl_v1r0 /*"Clinical Site Urine collected"*/
		BL_BioClin_ClinicalUrnTime_v1r0 /*"Autogenerated date/time stamp for clinical collection of urine."*/
		BL_BioClin_SiteUrineRRL_v1r0 /*"Clinical Site Urine RRL Received"*/
		BL_BioClin_DBUrineRRLDt_v1r0 /*"Clinical DB Urine RRL Date/Time Received"*/
		BL_BioClin_UrnOrderPlaced_v1r0 /*"Urine Order placed"*/
		BL_BioClin_UrnOrderPlacdDt_v1r0 /*"Date/time Urine order placed"*/;	
where BioSpm_setting_v1r0=664882224;
run;/*n=10*/

data tmp_clin;set tmp0;
if BioSpm_Setting_v1r0=664882224 then do;
	if	BL_BioClin_DBBloodRRL_v1r0 = . then BL_BioClin_DBBloodRRL_v1r0= 104430631;/*"Clinical DB Blood RRL Received"*/
	if	BL_BioClin_SiteBloodColl_v1r0 = . then  BL_BioClin_SiteBloodColl_v1r0 = 104430631;/*"Clinical Site Blood Collected"*/
	if	BL_BioClin_SiteBloodRRL_v1r0 = . then BL_BioClin_SiteBloodRRL_v1r0 = 104430631; /*"Clinical Site Blood RRL Received"*/

	if	BL_BioClin_DBUrineRRL_v1r0 = . then BL_BioClin_DBUrineRRL_v1r0= 104430631; /*"Clinical Site Urine RRL Received"*/
	if	BL_BioClin_SiteUrineRRL_v1r0 = . then BL_BioClin_SiteUrineRRL_v1r0= 104430631;/*"Clinical Site Urine RRL Received"*/
	if	BL_BioClin_SiteUrineColl_v1r0 = . then BL_BioClin_SiteUrineColl_v1r0 = 104430631; /*"Clinical DB Urine RRL Date/Time Received"*/
format BL_BioClin_DBBloodRRL_v1r0 YesNoFmt. BL_BioClin_SiteBloodColl_v1r0 YesNoFmt. BL_BioClin_SiteBloodRRL_v1r0 YesNoFmt.
BL_BioClin_DBUrineRRL_v1r0 YesNoFmt. BL_BioClin_SiteUrineColl_v1r0 YesNoFmt. BL_BioClin_SiteUrineRRL_v1r0 YesNoFmt.;
output;
end;
run;

proc freq data=tmp_clin;
tables BL_BioClin_SiteBloodColl_v1r0*BL_BioClin_DBBloodRRL_v1r0
BL_BioClin_SiteUrineColl_v1r0*BL_BioClin_DBUrineRRL_v1r0
/list missing cumcol TOTPCT OUTPCT  out=bld_api_db noprint;  run;

%Table1_CTSPedia(DSName=tmp_clin, GroupVar=BL_BioClin_DBBloodRRL_v1r0  , NumVars=,
           FreqVars =BL_BioClin_SiteBloodColl_v1r0,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=bld_api_db); 
%Table1_CTSPedia(DSName=tmp_clin, GroupVar=BL_BioClin_DBUrineRRL_v1r0  , NumVars=,
           FreqVars =BL_BioClin_SiteUrineColl_v1r0,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=urine_api_db);
/*n=6*/

proc freq data=concept_idsbios;table EDTATUBE2_BIOCOL_DEVIATIONNOTES/list missing; run;

proc sort data=concept_idsbios;by RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0;
run;
data tmp4;
set concept_idsbios;
by RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0;
array tube_coll {13} SSTube1_BioCol_TubeColl SSTube2_BioCol_TubeCollected SSTube3_BioCol_TubeColl SSTube4_BioCol_TubeColl
SSTube5_BioCol_TubeColl ACDTube1_BioCol_TubeCollected HepTube1_BioCol_TubeCollected  HepTube2_BioCol_TubeCollected
EDTATube1_Biocol_TubeCollected EDTATube2_BioCol_TubeCollected EDTATube3_BioCol_TubeCollected 
MWTube1_BioCol_TubeCollected UrineTube1_BioCol_TubeCollected;
tubecol_sum=0; 
do i =1 to 13;
if tube_coll{i}=353358909 then tubecol_sum=tubecol_sum +(tube_coll{i}/353358909);
else tubecol_sum=tubecol_sum;
end;
output;
EDTATUBE2_BIOCOL_DEVIATIONNOTES=" ";
SSTube5_BioCol_DeviationNotes=" "; 
drop i;
run;
proc sort data=tmp4; by tubecol_sum BioRec_CollectFinal_v1r0; run;
proc freq data=tmp4;tables BioRec_CollectFinal_v1r0*tubecol_sum BioRec_CollectFinal_v1r0*BioSpm_Setting_v1r0*tubecol_sum/list missing;
where BioReg_ArRegTime_v1r0 ^=. or BioRec_CollectFinalTime_v1r0 ^=.;run;

option ls=150;
proc freq data=tmp4;tables BioRec_CollectFinal_v1r0*BioSpm_Setting_v1r0*tubecol_sum/list missing;run;
*********;
proc sort data=tmp4; by RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0;
run;
proc format;
value biotubefmt
1= "SSTube1"
2= "SSTube2"
3= "SSTube3"
4= "SSTube4"
5= "SSTube5"
6= "ACDTube1"
7= "EDTATube1"
8= "EDTATube2"
9= "EDTATube3"
10= "HepTube1"
11= "HepTube2"
12= "MWTube1"
13= "UrineTube1"
;
data deviation_long; length BioTube_type_v1r0 $10.; 
set tmp4;

by RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0;
array tubeid {13} $ SSTube1_BioCol_TubeID SSTube2_BioCol_TubeID SSTube3_BioCol_TubeID SSTube4_BioCol_TubeID 
SSTube5_BioCol_TubeID ACDTube1_BioCol_TubeID EDTATube1_BioCol_TubeID EDTATube2_BioCol_TubeID EDTATube3_BioCol_TubeID 
HepTube1_BioCol_TubeID HepTube2_BioCol_TubeID MWTube1_BioCol_TubeID UrineTube1_BioCol_TubeID;
array tube_coll {13} SSTube1_BioCol_TubeColl SSTube2_BioCol_TubeCollected SSTube3_BioCol_TubeColl SSTube4_BioCol_TubeColl 
SSTube5_BioCol_TubeColl ACDTube1_BioCol_TubeCollected EDTATube1_BioCol_TubeCollected EDTATube2_BioCol_TubeCollected 
EDTATube3_BioCol_TubeCollected HepTube1_BioCol_TubeCollected HepTube2_BioCol_TubeCollected MWTube1_BioCol_TubeCollected 
UrineTube1_BioCol_TubeCollected;
array deviatio {13} SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation SSTube3_BioCol_Deviation SSTube4_BioCol_Deviation 
SSTube5_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation EDTATube2_BioCol_Deviation EDTATube3_BioCol_Deviation 
HepTube1_BioCol_Deviation HepTube2_BioCol_Deviation MWTube1_BioCol_Deviation UrineTube1_BioCol_Deviation;
***only EDTA  UrineTube1 with DeveiationNotes;
array discard {13} SSTube1_BioCol_Discard SSTube2_BioCol_Discard SSTube3_BioCol_Discard SSTube4_BioCol_Discard SSTube5_BioCol_Discard 
ACDTube1_BioCol_Discard EDTATube1_BioCol_Discard EDTATube2_BioCol_Discard EDTATube3_BioCol_Discard HepTube1_BioCol_Discard 
HepTube2_BioCol_Discard MWTube1_BioCol_Discard UrineTube1_BioCol_Discard;
***only ACD with notcollected and Notes;

array notcoll {13} SSTube1_BioCol_NotCol SSTube2_BioCol_NotCol SSTube3_BioCol_NotCol SSTube4_BioCol_NotCol SSTube5_BioCol_NotCol 			
ACDTube1_BioCol_NotCol EDTATube1_BioCol_NotCol EDTATube2_BioCol_NotCol EDTATube3_BioCol_NotCol HepTube1_BioCol_NotCol 
HepTube2_BioCol_NotCol MWTube1_BioCol_NotCol UrineTube1_BioCol_NotCol;
array notcoll_Note {13} $ SSTube1_BioCol_NotCollNotes SSTube2_BioCol_NotCollNotes SSTube3_BioCol_NotCollNotes 
SSTube4_BioCol_NotCollNotes SSTube5_BioCol_NotCollNotes ACDTube1_BioCol_NotCollNotes EDTATube1_Biocol_NotCollNotes 
EDTATube2_Biocol_NotCollNotes EDTATube3_Biocol_NotCollNotes HepTube1_BioCol_NotCollNotes HepTube2_BioCol_NotCollNotes
MWTube1_BioCol_NotCollNotes	UrineTube1_BioCol_NotCollNotes;
array deviNotes {13} $ SSTube1_BioCol_DeviationNotes SSTube2_BioCol_DeviationNotes SSTube3_BioCol_DeviationNotes 
SSTube4_BioCol_DeviationNotes SSTube5_BioCol_DeviationNotes ACDTube1_BioCol_DeviationNotes EDTATube1_BioCol_DeviationNotes 
EDTATube2_BioCol_DeviationNotes  EDTATube3_BioCol_DeviationNotes HepTube1_BioCol_DeviationNotes HepTube2_BioCol_DeviationNotes
MWTube1_BioCol_DeviationNotes UrineTube1_BioCol_DeviationNotes;

do i =1 to 13;
BioCol_TubeID_v1r0=tubeid{i};
BioCol_Tube_Notcoll=notcoll{i};
BioCol_Tube_notcoll_Notes=notcoll_note{i};
BioCol_Tube_Collected=tube_coll{i};

BioCol_TubeDeviation_v1r0=deviatio{i};
BioCol_Tube_Discard=discard{i};
BioCol_Tube_DeviationNote=deviNotes{i};

if i >0 and i < 12 then BioTube_type_v1r0 ="Blood";
if i=11 then BioTube_type_v1r0 ="MouthWash";
if i=13 then BioTube_type_v1r0 ="Urine";
BioTube_ID_v1r0=i;
output;
end;
keep RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0 bioTube_type_v1r0 BioTube_ID_v1r0 BioCol_TubeID_v1r0 BioCol_TubeDeviation_v1r0 
BioCol_Tube_DeviationNote BioCol_Tube_Discard BioCol_Tube_Notcoll BioCol_Tube_notcoll_Notes BioCol_Tube_Collected;
format BioCol_TubeDeviation_v1r0 DeviationSpecFmt. BioCol_Tube_Discard BioColDiscardFmt. BioCol_Tube_Collected BioColTubeCollFmt.
BioCol_Tube_Notcoll BioColRsnNotColFmt.;
attrib BioTube_ID_v1r0 format=biotubefmt. label="Tube Type";
run;/*NOTE: There were 1438 observations read from the data set WORK.TMP4.
NOTE: The data set WORK.DEVIATION_LONG has 18694 observations and 15 variables.
*/
proc freq data=deviation_long;
tables BioSpm_Setting_v1r0*BioTube_type_v1r0*(BioCol_TubeDeviation_v1r0 BioCol_Tube_Discard BioCol_Tube_Notcoll)
BioSpm_Setting_v1r0*BioTube_type_v1r0*BioCol_TubeDeviation_v1r0*BioCol_Tube_DeviationNote
BioSpm_Setting_v1r0*BioTube_type_v1r0*BioCol_Tube_Notcoll*BioCol_Tube_notcoll_Notes
BioSpm_Setting_v1r0*BioTube_type_v1r0*BioCol_Tube_Collected*BioCol_Tube_Notcoll
/list missing ;
format BioTube_ID_v1r0 biotubefmt.;run;
*** ***********;
proc freq data=deviation_long;
table BioSpm_Setting_v1r0*BioTube_type_v1r0*BioTube_ID_v1r0*(BioCol_TubeDeviation_v1r0 BioCol_Tube_Discard BioCol_Tube_Notcoll)/list missing ;
format BioTube_ID_v1r0 biotubefmt.;run;
****
*********;

/*for the deviation tubes*/
data dev; set deviation_long; where BioCol_TubeID_v1r0^=" " and BioCol_TubeDeviation_v1r0=353358909; run;/*n=326*/


***Jul. 18, 2022 with totoal collection vs the deviation part
***Sep. 12, 2022 requested by Michellel: Include row percents instead of column percents;

data collection_long;set deviation_long; 
if BioSpm_Setting_v1r0=534621077 and BioTube_ID_v1r0 in (3,4,5,8,9,11) then delete; /*Research no SStube3-5,hepatube2, or EDTA2,3*/;
if BioSpm_Setting_v1r0=664882224 and BioTube_ID_v1r0 =12 then delete;run;
***NOTE: There were 18694 observations read from the data set WORK.DEVIATION_LONG.
NOTE: The data set WORK.COLLECTION_LONG has 10116 observations and 15 variables.
*****;
data collection_long; set collection_long;
if BioCol_TubeID_v1r0=" " and BioCol_Tube_Collected=104430631 and BioCol_Tube_Notcoll=. then BioCol_Tube_Notcoll2=999999999;
else if BioCol_TubeID_v1r0 =" " and BioCol_Tube_Collected=104430631 and BioCol_Tube_Notcoll >0 then BioCol_Tube_Notcoll2=BioCol_Tube_Notcoll;
format BioCol_Tube_Notcoll2 TubeNotCollFmt. ;
run;
***Table 15. Number (and percent) of tubes with any deviation by site, including the KP sites in original 
Table10(Number (and percent) of tubes with any deviation by site);
proc freq data=collection_long;table BioSpm_Setting_v1r0*(BioCol_Tube_Collected BioCol_Tube_Notcoll2)/list missing; run;/*476*/
*                              BioSpm_Setting_        BioCol_Tube_                             Cumulative    Cumulative
                                          v1r0           Collected    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              Research            No                       496        4.90           496         4.90
                              Research            Yes                     9500       93.91          9996        98.81
                              Clinical            No                        28        0.28         10024        99.09
                              Clinical            Yes                       92        0.91         10116       100.00


                             BioSpm_Setting_                                                      Cumulative    Cumulative
                                        v1r0     BioCol_Tube_Notcoll2    Frequency     Percent     Frequency      Percent
                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                            Research                                .        9500       93.91          9500        93.91
                            Research            Other                          16        0.16          9516        94.07
                            Research            Short draw                     38        0.38          9554        94.44
                            Research            Participant refusal             5        0.05          9559        94.49
                            Research            Participant attempted         390        3.86          9949        98.35
                            Research            Supply Unavailable              3        0.03          9952        98.38
                            Research            missing reasons                44        0.43          9996        98.81
                            Clinical                                .          92        0.91         10088        99.72
                            Clinical            missing reasons                28        0.28         10116       100.00
***;
proc sort data=collection_long;by  BioSpm_Setting_v1r0;run;
proc freq data=collection_long;by BioSpm_Setting_v1r0;table RcrtES_Site_v1r0/list missing outcum out =bionotcol_site noprint;
where BioCol_Tube_Notcoll2>0;
run;
**NOTE: There were 524 observations read from the data set WORK.COLLECTION_LONG.
      WHERE BioCol_Tube_Notcoll2>0
NOTE: The data set WORK.BIONOTCOL_SITE has 10 observations and 5 variables.
******;
data bionotcol_site1;length label $50.;length cum_freq_pct  $16.; set bionotcol_site;
if 	RcrtES_Site_v1r0=	531629870 then label = "HealthPartners";
if 	RcrtES_Site_v1r0=	548392715 then label = "Henry Ford Health System";
if 	RcrtES_Site_v1r0=	125001209 then label= "Kaiser Permanente Colorado";
if 	RcrtES_Site_v1r0=	327912200 then label= "Kaiser Permanente Georgia";
if 	RcrtES_Site_v1r0=	300267574 then label= "Kaiser Permanente Hawaii";
if 	RcrtES_Site_v1r0=	452412599 then label= "Kaiser Permanente Northwest";
if 	RcrtES_Site_v1r0=	303349821 then label= "Marshfield Clinic Health System";
if 	RcrtES_Site_v1r0=	657167265 then label= "Sanford Health";
if 	RcrtES_Site_v1r0=	809703864 then label= "University of Chicago Medicine";
if 	RcrtES_Site_v1r0=	517700004 then label= "National Cancer Institute";
if 	RcrtES_Site_v1r0=	13 then label= "National Cancer Institute";
if 	RcrtES_Site_v1r0=	181769837 then label= "Other";
cum_freq_pct =put (cum_freq, 4.0)||" ("||put(round(cum_pct,0.01),5.2)||")";
run;
proc freq data=collection_long;by BioSpm_Setting_v1r0; 
table BioTube_ID_v1r0/list missing outcum out =bionotcol_type noprint;
where BioCol_Tube_Notcoll2>0;
run;/*n=19*/

data bionotcol_type1;length label $50.;length cum_freq_pct $16.;set bionotcol_type;
cum_freq_pct =put (cum_freq, 4.0)||" ("||put(round(cum_pct,0.01),5.2)||")";
if BioTube_ID_v1r0=1 then label = "SSTube1";
if BioTube_ID_v1r0=2 then label = "SSTube2";
if BioTube_ID_v1r0=3 then label = "SSTube3";
if BioTube_ID_v1r0=4 then label = "SSTube4";
if BioTube_ID_v1r0=5 then label = "SSTube5";
if BioTube_ID_v1r0=6 then label = "ACDTube1";
if BioTube_ID_v1r0=7 then label = "EDTATube1";
if BioTube_ID_v1r0=8 then label =  "EDTATube2";
if BioTube_ID_v1r0=9 then label = "EDTATube3";
if BioTube_ID_v1r0=10 then label = "HepTube1";
if BioTube_ID_v1r0=11 then label = "HepTube2";
if BioTube_ID_v1r0=12 then label = "MWTube1";
if BioTube_ID_v1r0=13 then label = "UrineTube1";
run;
data bionotcol_all;set bionotcol_site1 bionotcol_type1; 
label label="variable";run;/*19*/
/*data bionotcoll4;set bionotcoll4;
variable=trim(left(label));
order=_N_;run;
proc sql;
create table bionotcoll4_all as
select
a.*, b. cum_freq_pct
from
bionotcoll4 a
left join
bionotcol_all b
on a. variable = b. label
order by a. label;
run;
quit;/*n=23*/*/

proc sort data=bionotcoll4_all; by order; run;

/*For the collection/Not collection*/
data nocoll;set Collection_long; where BioCol_Tube_Collected=104430631; run;/*n=524 01/23/2023, 476 01/17/2023*/
proc freq data=nocoll;table BioSpm_Setting_v1r0*BioCol_Tube_Notcoll*biotube_id_v1r0/missing list out=notcol noprint; run;/*44 01/23/2023*/

data notcol_resh notcol_clc;
set nocoll;
if BioSpm_Setting_v1r0=534621077 then output  notcol_resh/*Research*/;
if BioSpm_Setting_v1r0=664882224 then output notcol_clc/*Clinical"*/;
run;
data bionotcol_site1;length label $50.;length cum_freq_pct  $16.; set bionotcol_site;
if 	RcrtES_Site_v1r0=	531629870 then label = "HealthPartners";
if 	RcrtES_Site_v1r0=	548392715 then label = "Henry Ford Health System";
if 	RcrtES_Site_v1r0=	125001209 then label= "Kaiser Permanente Colorado";
if 	RcrtES_Site_v1r0=	327912200 then label= "Kaiser Permanente Georgia";
if 	RcrtES_Site_v1r0=	300267574 then label= "Kaiser Permanente Hawaii";
if 	RcrtES_Site_v1r0=	452412599 then label= "Kaiser Permanente Northwest";
if 	RcrtES_Site_v1r0=	303349821 then label= "Marshfield Clinic Health System";
if 	RcrtES_Site_v1r0=	657167265 then label= "Sanford Health";
if 	RcrtES_Site_v1r0=	809703864 then label= "University of Chicago Medicine";
if 	RcrtES_Site_v1r0=	517700004 then label= "National Cancer Institute";
if 	RcrtES_Site_v1r0=	13 then label= "National Cancer Institute";
if 	RcrtES_Site_v1r0=	181769837 then label= "Other";
cum_freq_pct =put (cum_freq, 4.0)||" ("||put(round(cum_pct,0.01),5.2)||")";
run;/*n=10*/
proc freq data=collection_long;table BioTube_ID_v1r0/list missing outcum out =bionotcol_type noprint;
where BioCol_Tube_Notcoll2>0;
run;/*n=13*/

data bionotcol_type1;length label $50.;length cum_freq_pct $16.;set bionotcol_type;
cum_freq_pct =put (cum_freq, 4.0)||" ("||put(round(cum_pct,0.01),5.2)||")";
if BioTube_ID_v1r0=1 then label = "SSTube1";
if BioTube_ID_v1r0=2 then label = "SSTube2";
if BioTube_ID_v1r0=3 then label = "SSTube3";
if BioTube_ID_v1r0=4 then label = "SSTube4";
if BioTube_ID_v1r0=5 then label = "SSTube5";
if BioTube_ID_v1r0=6 then label = "ACDTube1";
if BioTube_ID_v1r0=7 then label = "EDTATube1";
if BioTube_ID_v1r0=8 then label =  "EDTATube2";
if BioTube_ID_v1r0=9 then label = "EDTATube3";
if BioTube_ID_v1r0=10 then label = "HepTube1";
if BioTube_ID_v1r0=11 then label = "HepTube2";
if BioTube_ID_v1r0=12 then label = "MWTube1";
if BioTube_ID_v1r0=13 then label = "UrineTube1";
run;
data bionotcol_all;set bionotcol_site1 bionotcol_type1; 
label label="variable";run;
%Table1_CTSPedia(DSName=collection_long, GroupVar=BioCol_Tube_Notcoll2 , NumVars=,
           FreqVars =BioTube_ID_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl4);/*table 13*/

data bionotcoll4;set bionotcoll4;
variable=trim(left(label));
order=_N_;run;
proc sql;
create table bionotcoll4_all as
select
a.*, b. cum_freq_pct
from
bionotcoll4 a
left join
bionotcol_all b
on a. variable = b. label
order by a. label;
run;
quit;/*n=34 for overall not collections*/

proc sort data=bionotcoll4_all; by order; run;


***Table 16(Original Table11). Number of deviations by biospecimen type and by tube type";

***Table 18. Number of deviations by biospecimen type and by tube type;
proc freq data=tmp4; tables EDTATUBE2_BIOCOL_DEVIATIONNOTES SSTube5_BioCol_DeviationNotes/list missing;run;
data tmp4; set tmp4;
 EDTATUBE2_BIOCOL_DEVIATIONNOTES=" ";
SSTube5_BioCol_DeviationNotes=" "; 
/*EDTATube1_BioCol_NotCollNotes=" "; EDTATube1_BioCol_NotCollNotes=" "; HepTube2_BioCol_NotCollNotes=" ";
SSTube5_BioCol_DeviationNotes=" "; EDTATube1_BioCol_DeviationNotes=" "; EDTATube1_BioCo3_DeviationNotes=" "; 
EDTATube3_BioCol_DeviationNotes=" ";
drop UrineTube1_BioCol_NotCollNotes;
rename UrineTube1_BioCol_NotCollNotes1=UrineTube1_BioCol_NotCollNotes;*/
run;
proc freq data=tmp4; 
tables SSTube1_BioCol_Deviation SSTube1_BioCol_DeviationNotes SSTube2_BioCol_Deviation SSTube2_BioCol_DeviationNotes 
SSTube3_BioCol_Deviation SSTube3_BioCol_Deviation SSTube4_BioCol_Deviation SSTube5_BioCol_Deviation  
EDTATube2_BioCol_Deviation EDTATube3_BioCol_Deviation HepTube1_BioCol_Deviation HepTube2_BioCol_Deviation
ACDTube1_BioCol_Deviation/list missing;run;
***                                                           Serum Separator Tube 1- Deviation

                                            SSTube1_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                    No         1378       95.83          1378        95.83
                                                    Yes          60        4.17          1438       100.00


                                                      Serum Separator Tube 1- Deviation Details

                                                                                                                    Cumulative    Cumulative
          SSTube1_BioCol_DeviationNotes                                                    Frequency     Percent     Frequency      Percent
          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                                               1413       98.26          1413        98.26
          #3                                                                                      1        0.07          1414        98.33
          1st sst tube poor suction. new sst tube was grabbed but last in order of draw           1        0.07          1415        98.40
          First attempt by participant, low volume of sst 1, not spun                             1        0.07          1416        98.47
          Hemolysis Present                                                                       1        0.07          1417        98.54
          Lipemia                                                                                 1        0.07          1418        98.61
          Lipemic                                                                                 1        0.07          1419        98.68
          Needle hub defective                                                                    1        0.07          1420        98.75
          Non SST, Red top                                                                        1        0.07          1421        98.82
          Original label damaged                                                                  1        0.07          1422        98.89
          Participant attempted twice , unsuccessful sticks both times                            1        0.07          1423        98.96
          Participant was a slow draw                                                             1        0.07          1424        99.03
          Slight hemolysis                                                                        4        0.28          1428        99.30
          Specimen is very cloudy after centrifuge                                                1        0.07          1429        99.37
          blood flow was slow.                                                                    1        0.07          1430        99.44
          floater present                                                                         1        0.07          1431        99.51
          low volume in tube as well as hemolysis present                                         1        0.07          1432        99.58
          not stood upright for 30 minutes prior to centrifuging                                  1        0.07          1433        99.65
          see below -Hemolysis and gel layer anomalies                                            1        0.07          1434        99.72
          serum is discolored (red), reason unknown                                               1        0.07          1435        99.79
          severely hemolyzed                                                                      1        0.07          1436        99.86
          slow draw                                                                               1        0.07          1437        99.93
          slow draw, first attempt                                                                1        0.07          1438       100.00

                                             SSTube2_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                    No         1388       96.52          1388        96.52
                                                    Yes          50        3.48          1438       100.00


                                                      Serum Separator Tube 2- Deviation Details

                                                                                                             Cumulative    Cumulative
                SSTube2_BioCol_DeviationNotes                                       Frequency     Percent     Frequency      Percent
                ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                                                        1422       98.89          1422        98.89
                Lipemia                                                                    1        0.07          1423        98.96
                Lipemic                                                                    1        0.07          1424        99.03
                Low volume                                                                 1        0.07          1425        99.10
                Needle hub defective                                                       1        0.07          1426        99.17
                Non SST, Red top                                                           1        0.07          1427        99.24
                Slight hemplysis                                                           1        0.07          1428        99.30
                Slow draw on attempt.                                                      1        0.07          1429        99.37
                Specimen is very cloudy after centrifuge                                   1        0.07          1430        99.44
                clot of gel seemed to form with blood on top of gel layer                  1        0.07          1431        99.51
                not stood upright for 30 minutes prior to centrifuging                     1        0.07          1432        99.58
                participant hadn                                                           1        0.07          1433        99.65
                second attempt by participant in other arm for rest of the tubes           1        0.07          1434        99.72
                see below -Hemolysis and gel layer anomalies                               1        0.07          1435        99.79
                serum is discolored (red), reason unknown                                  1        0.07          1436        99.86
                short draw from participant, petered out                                   1        0.07          1437        99.93
                slow draw, second attempt                                                  1        0.07          1438       100.00


                                                           Serum Separator Tube 3- Deviation

                                            SSTube3_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00
                                           SSTube3_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00


                                                           Serum Separator Tube 4- Deviation

                                            SSTube4_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00


                                            SSTube5_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00


                                                                EDTA Tube 2- Deviation

                                             EDTATube2_
                                                BioCol_                             Cumulative    Cumulative
                                              Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00


                                                                EDTA Tube 2- Deviation

                                             EDTATube3_
                                                BioCol_                             Cumulative    Cumulative
                                              Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00
                                                               Heparin Tube 1- Deviation

                                           HepTube1_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                    No         1402       97.50          1402        97.50
                                                    Yes          36        2.50          1438       100.00


                                                               Heparin Tube 2- Deviation

                                           HepTube2_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      .        1428       99.30          1428        99.30
                                                    No           10        0.70          1438       100.00


                                                                 ACD Tube 1- Deviation

                                           ACDTube1_Bio                             Cumulative    Cumulative
                                          Col_Deviation    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                    No         1354       94.16          1354        94.16
                                                    Yes          84        5.84          1438       100.00

*******;
%macro sstube_long(sstube,out,tubecoll);
proc sort data=tmp4; by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 &SSTube._BioCol_TubeID &SSTube._BioCol_&TubeColl. 
&SSTube._BioCol_Deviation &SSTube._BioCol_DeviationNotes; run;

proc transpose data=tmp4 out=&sstube._&out. prefix=deviation;
by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 &sstube._BioCol_TubeID &sstube._BioCol_&TubeColl. 
&sstube._BioCol_Deviation &sstube._BioCol_DeviationNotes ;
var &sstube._Deviation_Broken
&sstube._Deviation_ClotL
&sstube._Deviation_ClotS
&sstube._Deviation_Discard
&sstube._Deviation_Gel
&sstube._Deviation_Hemolyzed
&sstube._Deviation_Leak
&sstube._Deviation_LowVol
&sstube._Deviation_MislabelD
&sstube._Deviation_MislabelR
&sstube._Deviation_NotFound
&sstube._Deviation_Other
&sstube._Deviation_OutContam
&sstube._Deviation_SpeedH
&sstube._Deviation_SpeedL
&sstube._Deviation_TempH
&sstube._Deviation_TempL
&sstube._Deviation_TimeL
&sstube._Deviation_TimeS
&sstube._Deviation_TubeSz;
run;
proc freq data=&sstube._&out.; table deviation1/list missing ;run;
/*data deviat_&sstube;length Tube_BioCol_DeviationNote $60.;set &sstube._&out.; 
Tube_BioCol_TubeID=&SSTube._BioCol_TubeID;Tube_BioCol_TubeCollected=&SSTube._BioCol_&TubeColl.; 
Tube_BioCol_Deviation=&SSTube._BioCol_Deviation;Tube_BioCol_DeviationNotes=&SSTube._BioCol_DeviationNotes;
keep connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 Tube_BioCol_TubeID 
Tube_BioCol_TubeCollected Tube_BioCol_Deviation Tube_BioCol_DeviationNotes  _NAME_ _LABEL_;
if deviation1=353358909 then output; 
format Tube_BioCol_TubeCollected TubeCollectedFmt. Tube_BioCol_Deviation DeviationFmt. deviation1 DeviationFmt.; 
 run;
proc append data=deviat_&sstube. base=deviat_Tube force; run;*/
%mend;
%sstube_long(SSTube1,devialong,TubeColl);/*62*/
%sstube_long(SSTube2,devialong,TubeCollected);/*53*/
%sstube_long(SSTube3,devialong,TubeColl);
%sstube_long(SSTube4,devialong,TubeColl);
%sstube_long(SSTube5,devialong,TubeColl);

%macro tube_long(tube,out,tubecoll,deviationnotes);
proc sort data=tmp4; by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 &Tube._BioCol_TubeID &Tube._BioCol_&TubeColl. 
&Tube._BioCol_Deviation &DeviationNotes; run;

proc transpose data=tmp4 out=&tube._&out. prefix=deviation;
by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 &tube._BioCol_TubeID &tube._BioCol_&TubeColl. 
&tube._BioCol_Deviation &tube._BioCol_DeviationNotes ;
var 
&Tube._Deviation_Hemolyzed
&Tube._Deviation_MislabelR
&Tube._Deviation_OutContam
&Tube._Deviation_Other
&Tube._Deviation_Broken
&Tube._Deviation_TempL
&Tube._Deviation_MislabelD
&Tube._Deviation_TempH
&Tube._Deviation_LowVol
&Tube._Deviation_Leak
&Tube._Deviation_TubeSz
&Tube._Deviation_Discard
&Tube._Deviation_NotFound;
run;
proc freq data=&tube._&out.; table deviation1/list missing; run;
/*data deviat_&tube;length Tube_BioCol_DeviationNote $60.;set &tube._&out.; 
Tube_BioCol_TubeID=&Tube._BioCol_TubeID;Tube_BioCol_TubeCollected=&Tube._BioCol_&TubeColl.; 
Tube_BioCol_Deviation=&Tube._BioCol_Deviation;Tube_BioCol_DeviationNotes=&DeviationNotes;
keep connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 Tube_BioCol_TubeID 
Tube_BioCol_TubeCollected Tube_BioCol_Deviation Tube_BioCol_DeviationNotes _NAME_ _LABEL_;
if deviation1=353358909 then output; 
format Tube_BioCol_TubeCollected TubeCollectedFmt. Tube_BioCol_Deviation DeviationFmt. deviation1 DeviationFmt.; 
 run;
proc append data=deviat_&tube. base=deviat_Tube force; run;*/
%mend;
%tube_long(ACDTube1,devialong,TubeCollected,ACDTube1_BioCol_DeviationNotes);/*84*/
%tube_long(EDTATube1,devialong,TubeCollected,EDTATube1_BioCol_DeviationNotes);/*41*/
%tube_long(EDTATube2,devialong,TubeCollected,);
%tube_long(EDTATube3,devialong,TubeCollected,);/*no*/
%tube_long(HepTube1,devialong,TubeCollected,HepTube1_BioCol_DeviationNotes);/*35,excluding one without notes*/
%tube_long(HepTube2,devialong,TubeCollected,HepTube2_BioCol_DeviationNotes);

proc sort data=tmp4; by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 HepTube1_BioCol_TubeID UrineTube1_BioCol_TubeCollected 
UrineTube1_BioCol_Deviation UrineTube1_BioCol_DeviationNotes; run;
proc transpose data=tmp4 out=urinetube1_devia_long prefix=deviation;
by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 UrineTube1_BioCol_TubeID UrineTube1_BioCol_TubeCollected 
UrineTube1_BioCol_Deviation UrineTube1_BioCol_DeviationNotes;
var 
UrineTube1_Deviation_Broken
UrineTube1_Deviation_Leak
UrineTube1_Deviation_LowVol
UrineTube1_Deviation_MislabelD
UrineTube1_Deviation_MislabelR
UrineTube1_Deviation_NotFound
UrineTube1_Deviation_Other
UrineTube1_Deviation_OutContam
UrineTube1_Deviation_TempH
UrineTube1_Deviation_TempL
UrineTube1_Deviation_UrVol;run;

proc freq data=urinetube1_devia_long;table deviation1/list missing; run;
***                                                                                 Cumulative    Cumulative
                                           deviation1    Frequency     Percent     Frequency      Percent
                                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                  No        15781       99.77         15781        99.77
                                                  Yes          37        0.23         15818       100.00
*****;
proc sort data=tmp4; by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 MWTube1_BioCol_TubeID MWTube1_BioCol_TubeCollected 
MWTube1_BioCol_Deviation MWTube1_BioCol_DeviationNotes; run;

proc transpose data=tmp4 out=MWtube1_devialong prefix=deviation;
by connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 MWTube1_BioCol_TubeID MWTube1_BioCol_TubeCollected 
MWTube1_BioCol_Deviation MWTube1_BioCol_DeviationNotes;
var 
MWTube1_Deviation_Broken
MWTube1_Deviation_Leak
MWTube1_Deviation_LowVol
MWTube1_Deviation_MislabelD

MWTube1_Deviation_MislabelR
MWTube1_Deviation_MWUnder30s
MWTube1_Deviation_NotFound
MWTube1_Deviation_Other
MWTube1_Deviation_OutContam; run;/*no deviation*/

proc freq data=mwtube1_devialong; table deviation1/list missing; run;
***                                                                                 Cumulative    Cumulative
                                           deviation1    Frequency     Percent     Frequency      Percent
                                           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                    .          90        0.70            90         0.70
                                                  No        12835       99.17         12925        99.87
                                                  Yes          17        0.13         12942       100.00
****;


%macro devia_append(tube,out,tubecoll,DeviationNotes);
proc freq data=&tube._&out;table &Tube._BioCol_Deviation*deviation1/list missing ;run;
data deviat_&tube;length Tube_BioCol_DeviationNotes $60.;set &tube._&out.; 
Tube_BioCol_TubeID=&Tube._BioCol_TubeID;Tube_BioCol_TubeCollected=&Tube._BioCol_&TubeColl.; 
Tube_BioCol_Deviation=&Tube._BioCol_Deviation;Tube_BioCol_DeviationNotes=&DeviationNotes;
if &tube._BioCol_Deviation=353358909 and deviation1=353358909 then output; 

keep connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 Tube_BioCol_TubeID 
Tube_BioCol_TubeCollected Tube_BioCol_Deviation Tube_BioCol_DeviationNotes _NAME_ _LABEL_ deviation1 ;
format Tube_BioCol_TubeCollected TubeCollectedFmt. Tube_BioCol_Deviation DeviationFmt. deviation1 DeviationFmt.; 

 run;
proc append data=deviat_&tube. base=deviat_Tube force; run;
%mend;
%devia_append(SStube1,devialong,TubeCollected,SSTube1_BioCol_DeviationNotes); /*62*/
%devia_append(SSTube2,devialong,TubeCollected,SSTube2_BioCol_DeviationNotes); /*53*/
%devia_append(EDTAtube1,devialong,TubeCollected,EDTATube1_BioCol_DeviationNotes);/*41 */
%devia_append(ACDTube1,devialong,TubeCollected,ACDTube1_BioCol_DeviationNotes);/*84*/
%devia_append(HepTube1,devialong,TubeCollected,HepTube1_BioCol_DeviationNotes);/*35*/

%devia_append(MWtube1,devialong,TubeCollected,MWTube1_BioCol_DeviationNotes);/*17*/
%devia_append(UrineTube1,devia_long,TubeCollected,UrineTube1_BioCol_DeviationNotes);/*37*/


/*intotal 308 with deviation notes*/

proc sql;
create table dev_details as 
select 
a. *, b. deviation1, b. _label_, b. _name_
from 
dev a
left join 
deviat_Tube b 
on a. BioCol_TubeID_v1r0 = b. Tube_BioCol_TubeID and a.BioCol_TubeDeviation_v1r0=b. Tube_BioCol_Deviation
order by a. connect_id and a. BioCol_TubeID_v1r0;
run;
quit;
**NOTE: The query as specified involves ordering by an item that doesn't appear in its SELECT clause.
NOTE: Table WORK.DEV_DETAILS created, with 316 rows and 18 columns. 8 without any deviation categories
***;
proc sort data=dev_details; by connect_Id BioCol_TubeID_v1r0; run;
proc freq data=dev_details;table BioTube_type_v1r0*BioCol_TubeID_v1r0*_label_/list missing noprint out=dev_duptubes; 
run;
proc print data=dev_details noobs;
var connect_ID BioCol_TubeID_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 BioCol_TubeDeviation_v1r0
BioTube_ID_v1r0 BioCol_Tube_DeviationNote deviation1;
where deviation1=.;
run;
***                                                                         BioCol_
                                    BioSpm_                                Tube
                  BioCol_Tube      ColIDScan_    BioSpm_Location_       Deviation_    BioTube_
   Connect_ID       ID_v1r0           v1r0       v1r0                      v1r0       ID_v1r0     BioCol_Tube_DeviationNote              deviation1

   1976119497    CXA002384 0007    CXA002384     UC-DCAM                   Yes        MWTube1     Participant was chewing bubble gum.        .
   3983492332    CXA001467 0003    CXA001467     Marshfield                Yes        HepTube1                                               .
   4063464437    CXA001949 0001    CXA001949     SF Cancer Center LL       Yes        SSTube1     Slight hemolysis                           .
   4563945288    CXA001849 0001    CXA001849     SF Cancer Center LL       Yes        SSTube1     Slight hemolysis                           .
   4563945288    CXA001849 0002    CXA001849     SF Cancer Center LL       Yes        SSTube2     Slight hemplysis                           .
   5366003103    CXA001927 0001    CXA001927     SF Cancer Center LL       Yes        SSTube1     Slight hemolysis                           .
   7711413266    CXA001965 0001    CXA001965     SF Cancer Center LL       Yes        SSTube1     Slight hemolysis                           .
   8082015648    CXA001894 0002    CXA001894     SF Cancer Center LL       Yes        SSTube2     Lipemic                                    .
*******;
proc freq data=dev_details;
table BioSpm_Setting_v1r0*BioTube_type_v1r0*_label_/list missing out=dev_details_counts;
run;
***NOTE: 35 observations added.
;
/*%macro devia_tube(tube,out,TubeColl);
data deviat_&tube;set &tube._&out.; 
Tube_BioCol_TubeID=&Tube._BioCol_TubeID;Tube_BioCol_TubeCollected=&Tube._BioCol_&TubeColl.; 
Tube_BioCol_Deviation=&Tube._BioCol_Deviation;Tube_BioCol_DeviationNotes=&Tube._BioCol_DeviationNotes;
keep connect_id BioSpm_Setting_v1r0 BioSpm_ColIDScan_v1r0 BioSpm_Location_v1r0 Tube_BioCol_TubeID 
Tube_BioCol_TubeCollected Tube_BioCol_Deviation Tube_BioCol_DeviationNotes _NAME_ _LABEL_;
if deviation1=353358909 then output; 
format Tube_BioCol_TubeCollected TubeCollectedFmt. Tube_BioCol_Deviation DeviationFmt. deviation1 DeviationFmt.; 
 run;
proc append data=deviat_&tube. base=deviat_Tube force; run;
%mend;*/
proc freq data=deviation_long; table BioCol_TubeDeviation_v1r0/list missing;run;

%Table1_CTSPedia(DSName=deviation_long, GroupVar=BioCol_TubeDeviation_v1r0,
                  NumVars=,
FreqVars = RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=Biodev1);



option ls=160;
/*Table15*/
data dev1; set collection_long; where BioCol_TubeID_v1r0^=" " and BioCol_Tube_Discard=353358909; run;/*n=0, 11/11/2022, n=6 12/12/2022 6 same as before*/
%Table1_CTSPedia(DSName=dev1, GroupVar=BioTube_type_v1r0, NumVars=,
           FreqVars =BioCol_Tube_Discard RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(CP), 
Print=Y,Label=L,Out=Biodiscard);


/*For the collection/Not collection*/
/*For the collection/Not collection*/
data nocoll;set Collection_long; where BioCol_Tube_Collected=104430631; run;/*n=124 11/11/2022, n=381 12/02/2022 458 01/09/23 476 01/17/23*/
proc freq data=nocoll;table BioSpm_Setting_v1r0*BioCol_Tube_Notcoll*biotube_id_v1r0/missing list out=notcol noprint; run;/*44 01/17/2023*/

data notcol_resh notcol_clc;
set nocoll;
if BioSpm_Setting_v1r0=534621077 then output  notcol_resh/*Research*/;
if BioSpm_Setting_v1r0=664882224 then output notcol_clc/*Clinical"*/;
run;
*NOTE: There were 476 observations read from the data set WORK.NOCOLL.
NOTE: The data set WORK.NOTCOL_RESH has 454 observations and 16 variables.
NOTE: The data set WORK.NOTCOL_CLC has 22 observations and 16 variables.;


%Table1_CTSPedia(DSName=nocoll, GroupVar= BioTube_ID_v1r0 ,NumVars=,
                FreqVars =RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, 
FreqCell=N(CP), Print=Y,Label=L,Out=Biodev2);


%Table1_CTSPedia(DSName=nocoll, GroupVar=BioTube_ID_v1r0  , NumVars=,
           FreqVars =BioCol_Tube_Notcoll,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(CP), 
Print=Y,Label=L,Out=BioNotColl2); 

%Table1_CTSPedia(DSName=notcol_resh, GroupVar=BioTube_ID_v1r0  , NumVars=,
           FreqVars =/*BioCol_Tube_Notcoll*/ RcrtES_Site_v1r0,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl_re); /*Number of tube types not collected at research sites'*/

%Table1_CTSPedia(DSName=notcol_resh, GroupVar=BioCol_Tube_Notcoll2 , NumVars=,
           FreqVars =BioTube_ID_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl4_re);
/*%Table1_CTSPedia(DSName=notcol_resh, GroupVar=BioCol_Tube_Notcoll2 , NumVars=,
           FreqVars =BioTube_ID_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl4);*/


%Table1_CTSPedia(DSName=notcol_clc, GroupVar=BioTube_ID_v1r0  , NumVars=,
           FreqVars =RcrtES_Site_v1r0,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl_cc); /*Table X: Reason not collected by tube type and by site for clinical collections only*/
%Table1_CTSPedia(DSName=notcol_clc, GroupVar=BioCol_Tube_Notcoll2 , NumVars=,
           FreqVars =BioTube_ID_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl4_cc);/*Number of tube types not collected at clinical sites'*/

data nocoll;set Collection_long; where BioCol_Tube_Collected=104430631; run;/*n=124 11/11/2022, n=381 12/02/2022 476 01/17/23*/
proc freq data=nocoll;table BioSpm_Setting_v1r0*BioCol_Tube_Notcoll*biotube_id_v1r0/missing list out=notcol noprint; run;
/*29 11/11/2022, 34 12/02/2022 38 groups of 458 01092023 44from 476 01/17/23*/

proc print data=notcol noobs label;run;/*clinical collection doesn't have any reasons for no collections*/

proc print data=nocoll noobs;
var RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0
BioCol_Tube_Collected BioCol_Tube_Notcoll biotube_id_v1r0;
where BioCol_Tube_Collected=353358909 and BioCol_TubeID_v1r0=" ";
run;/*no obs*/

***Table 17. Number (and percent) of tubes with any deviation by site, including the KP sites in original ***;
%Table1_CTSPedia(DSName=collection_long, GroupVar=BioCol_Tube_Notcoll2 , NumVars=,
           FreqVars =BioTube_ID_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), 
Print=Y,Label=L,Out=BioNotColl4);/*table 13*/
proc freq data=collection_long;
table BioSpm_Setting_v1r0*BioCol_Tube_Collected*BioCol_TubeDeviation_v1r0*biotube_id_v1r0/missing list; 
where BioCol_TubeDeviation_v1r0= 353358909;run;/*all from the research settings*/
***
            BioSpm_Setting_        BioCol_Tube_         BioCol_Tube                                                Cumulative    Cumulative
                       v1r0           Collected      Deviation_v1r0    BioTube_ID_v1r0    Frequency     Percent     Frequency      Percent
           ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
           Research            Yes                 Yes                 SSTube1                  53       17.38            53        17.38
           Research            Yes                 Yes                 SSTube2                  43       14.10            96        31.48
           Research            Yes                 Yes                 ACDTube1                 83       27.21           179        58.69
           Research            Yes                 Yes                 EDTATube1                41       13.44           220        72.13
           Research            Yes                 Yes                 HepTube1                 34       11.15           254        83.28
           Research            Yes                 Yes                 MWTube1                  16        5.25           270        88.52
           Research            Yes                 Yes                 UrineTube1               35       11.48           305       100.00
*****;

ods html;

***Table 15 research 534621077.;
data tmp3;set tmp;
where connect_Id=connectbio_id;
run;***NOTE: There were 1430 observations read from the data set WORK.TMP.;

proc print data=tmp noobs;
var connect_ID BioSpm_Setting_v1r0 RcrtES_Site_v1r0 BL_BioChk_Complete_v1r0 SrvBLM_ResSrvCompl_v1r0 SrvBlU_BaseComplete_v1r0;
where BioSpm_Setting_v1r0^= . and 
(BioFin_BaseBloodCol_v1r0^= 353358909 and BioFin_BaseUrineCol_v1r0^=353358909 and  BioFin_BaseMouthCol_v1r0^=353358909);
run;
***                                                                                                                   SrvBlU_
                                                                                                      SrvBLM_Res        Base
                                     BioSpm_                                          BL_BioChk_       SrvCompl_      Complete_
                     Connect_ID    Setting_v1r0           RcrtES_Site_v1r0           Complete_v1r0       v1r0           v1r0

                     5312274299      Research      University of Chicago Medicine         No          Submitted      Not Started
                     9214463637      Research      Henry Ford Health System               No          Not Started    Not Started
*****;

proc freq data=tmp3 ; 
table SrvBLM_ResSrvCompl_v1r0/list missing outcum out=svcomplte_resh noprint; 
where BioSpm_Setting_v1r0=534621077;
run;/*n=3*/

data svcomplte_resh;length setting $12.; set svcomplte_resh;Setting="Research";
label setting="Collection Setting" SrvBLM_ResSrvCompl_v1r0="Survey Status"
count="Frequency"
Percent="Percent"
cum_pct="Cumulative Percent"
cum_freq="Cumulative Frequency";
run;
/*Table 15. Total number and percent of biospecimen survey status- research*/ 
proc print data=svcomplte_resh noobs label;
title "Table 15. Total number and percent of research biospecimen survey status";
run;
***Table 16  Total number and percent of biospecimen survey status- clinical;
proc freq data=tmp3 ; 
table SrvBlU_BaseComplete_v1r0/list missing outcum out=svcomplte_clc noprint; 
where BioSpm_Setting_v1r0 = 664882224;
run;/*1 from 7 all submitted*/

data svcomplte_clc;length setting $12.; set svcomplte_clc;Setting="Clinical";
label setting="Collection Setting" SrvBlU_BaseComplete_v1r0="Survey Status"
count="Frequency"
Percent="Percent"
cum_pct="Cumulative Percent"
cum_freq="Cumulative Frequency";
run;


*Table 17. Total number and percent of research biospecimen survey status";

proc sort data=tmp3; by SrvBLM_ResSrvCompl_v1r0;run;
proc freq data=tmp3; 
by  SrvBLM_ResSrvCompl_v1r0;
table checkvisit_resh/missing outcum out=sv_visittm_resh list noprint;
label checkvisit_resh ="Research Survey Completion Time"; format checkvisit_resh checktimefmt.;
where BL_BioChk_Time_v1r0^=. and BioSpm_Setting_v1r0=534621077;run;
data sv_visittm_resh; set sv_visittm_resh;
label	SrvBLM_ResSrvCompl_v1r0="Survey Status";
format checkvisit_resh checktimefmt.;
run;/*6*/

proc sort data=tmp3; by SrvBlU_BaseComplete_v1r0;run;
proc freq data=tmp3; 
by  SrvBlU_BaseComplete_v1r0;
table checkvisit_clc/missing outcum out=sv_visittm_clc list noprint;
label checkvisit_clc ="Clinical Survey Completion Time"; format checkvisit_clc checktimefmt.;
where BL_BioClin_BlUtime_v1r0^=. and BioSpm_Setting_v1r0=664882224;run;
/*NOTE: The data set WORK.SV_VISITTM_CLC has 3 observations and 6 variables.*/

data sv_visittm_clc; set sv_visittm_clc;
format checkvisit_clc checktimefmt.;
run;/*'Table X. Total number and percent of biospecimen survey status- clinical.'*/
***requested from Nicole on Jun. 27, 2022 for the biospecimen invitation;
data tmp2;set tmp; if BioSpm_Setting_v1r0=534621077 then output;run;/*1341 research*/
proc sort data=tmp2; by BL_BioChk_Time_v1r0 BioSpm_Visit_v1r0;run;
data biosbase_resh; set tmp2;
if _n_=1 and  BL_BioChk_Time_v1r0 ^=. then BioCol_Starttime = BL_BioChk_Time_v1r0;
format BioCol_starttime datetime21.;
retain BioCol_Starttime;
run;

proc sort data=biosbase_resh; by descending BL_BioChk_Time_v1r0 BioSpm_Visit_v1r0;run;
data biosbase_resh; set biosbase_resh;
if _n_=1 and  BL_BioChk_Time_v1r0 ^=. then BioCol_Stoptime = BL_BioChk_Time_v1r0;
format BioCol_Stoptime datetime21.;
retain BioCol_Stoptime;
run;

proc sort data=biosbase_resh; by RcrtES_Site_v1r0 BL_BioChk_Time_v1r0; run;
data biosbase_resh; set biosbase_resh;
by RcrtES_Site_v1r0;
if first.RcrtES_Site_v1r0=1 then BioCol_Starttime_site=BL_BioChk_Time_v1r0;
if last.RcrtES_Site_v1r0=1 then BioCol_Stoptime_site=BL_BioChk_Time_v1r0;
format BioCol_starttime_site datetime21. BioCol_stoptime_site datetime21. ;
retain BioCol_Starttime_site BioCol_stoptime_site;
 run;
proc sort data=biosbase_resh;by connect_id; run;

data biosbase_resh;
set biosbase_resh;
by connect_id;
wk=1+floor(intck("second",BioCol_Starttime,BL_BioChk_Time_v1r0)/(60*60*24*7));
wk_date=BioCol_Starttime+7*60*60*24*(wk-1);
attrib wk_date label="date" format=datetime21.;
format BioCol_Starttime datetime21.;

BioRec_CollectFinalDate_v1r0 =datepart(BioRec_CollectFinalDate_v1r0);
format BioRec_CollectFinalDate_v1r0 date9.;
if BioFin_BaseSpeci_v1r0 then tubecol_sum=1;

if last.connect_id=1 then output;run;

data time;
set biosbase_resh;
keep Connect_ID RcrtES_Site_v1r0 wk wk_date BioCol_Starttime BioCol_Starttime_site BL_BioChk_Time_v1r0 tubecol_sum; run;
proc sort data=time; by RcrtES_Site_v1r0 wk;run;

***to do the weekly plots of biospecimen collection by site;
proc freq data=biosbase_resh;
table BioCol_Starttime*wk*wk_date*RcrtES_Site_v1r0/list missing out=vis_site;run;
***NOTE: There were 1341 observations read from the data set WORK.BIOSBASE_TUBE1.
NOTE: The data set WORK.VIS_SITE has 128 observations and 6 variables.
*****;
data vis_site; set vis_site; visit=count;
label visit="Number of visits";attrib wk_date label="date" format=datetime21.;
run;
proc sort data=vis_site; by RcrtES_Site_v1r0;run;

***to plot the blood and urine plot individually;
data tmp2_clc;set tmp; 
format BL_BioClin_BlUtime_v1r0 datetime21.;
if nmiss(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_DBUrineRRLDt_v1r0,BL_BioClin_SiteUrineRRLDt_v1r0)>1 then 
BL_BioClin_Urinetime= max(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_DBUrineRRLDt_v1r0,BL_BioClin_SiteUrineRRLDt_v1r0);

else if nmiss(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_DBUrineRRLDt_v1r0,BL_BioClin_SiteUrineRRLDt_v1r0)<2 then 
BL_BioClin_Urinetime= min(BL_BioClin_ClinicalUrnTime_v1r0,BL_BioClin_DBUrineRRLDt_v1r0,BL_BioClin_SiteUrineRRLDt_v1r0);

if nmiss(BL_BioClin_SiteBloodRRLDt_v1r0,BL_BioClin_ClinBloodTime_v1r0,BL_BioClin_DBBloodRRLDt_v1r0 )>1 then 
BL_BioClin_BloodTime=max(BL_BioClin_SiteBloodRRLDt_v1r0,BL_BioClin_DBBloodRRLDt_v1r0,BL_BioClin_ClinBloodTime_v1r0);
else if nmiss(BL_BioClin_DBBloodRRLDt_v1r0,BL_BioClin_ClinBloodTime_v1r0,BL_BioClin_SiteBloodRRLDt_v1r0)<2 then
BL_BioClin_Bloodtime= min(BL_BioClin_ClinBloodTime_v1r0,BL_BioClin_DBBloodRRLDt_v1r0,BL_BioClin_SiteBloodRRLDt_v1r0);
if BioSpm_Setting_v1r0=664882224 then output;
format BL_BioClin_Urinetime datetime21.
 BL_BioClin_Bloodtime datetime21.;run;


proc sort data=tmp2_clc; by BL_BioClin_Bloodtime BioSpm_Visit_v1r0;run;
data biosbase_clc; set tmp2_clc;
if _n_=1 then Biobld_Starttime_clc = BL_BioClin_Bloodtime;
format Biobld_starttime_clc datetime21.;
retain Biobld_Starttime_clc;where BL_BioClin_Bloodtime ^=. ;
run;

proc sort data=biosbase_clc; by descending BL_BioClin_Bloodtime BioSpm_Visit_v1r0;run;
data biosbase_clc; set biosbase_clc;
if _n_=1 and  BL_BioClin_Bloodtime ^=. then Biobld_Stoptime_clc = BL_BioClin_Bloodtime;
format Biobld_Stoptime_clc datetime21.;
retain Biobld_Stoptime_clc;
run;

proc sort data=biosbase_clc; by RcrtES_Site_v1r0 BL_BioClin_Bloodtime; run;
data biosbase_clc; set biosbase_clc;
by RcrtES_Site_v1r0;
if first.RcrtES_Site_v1r0=1 then Biobld_Starttime_site=BL_BioClin_Bloodtime;
if last.RcrtES_Site_v1r0=1 then Biobld_Stoptime_site=BL_BioClin_Bloodtime;
format Biobld_starttime_site datetime21. Biobld_stoptime_site datetime21. ;
retain Biobld_Starttime_site Biobld_stoptime_site;
 run;
proc sort data=biosbase_clc;by connect_id; run;

data biosbase_clc;
set biosbase_clc;
by connect_id;
wk=1+floor(intck("second",Biobld_Starttime_clc,BL_BioClin_Bloodtime)/(60*60*24*7));
wk_date=Biobld_Starttime_clc+7*60*60*24*(wk-1);
attrib wk_date label="date" format=datetime21.;
format Biobld_Starttime_clc datetime21.;

BL_BioClin_Blooddate =datepart(BL_BioClin_Bloodtime);
format BL_BioClin_Blooddate date9.;
if BioFin_BaseSpeci_v1r0 then tubecol_sum=1;

if last.connect_id=1 then output;run;

data time_clc_bld;
set biosbase_clc;
keep Connect_ID RcrtES_Site_v1r0 wk wk_date Biobld_Starttime_clc Biobld_Starttime_site BL_BioClin_Bloodtime_v1r0 tubecol_sum; run;
proc sort data=time_clc_bld; by RcrtES_Site_v1r0 wk;run;

***to do the weekly plots of biospecimen collection by site;
proc freq data=biosbase_clc;
table Biobld_Starttime_clc*wk*wk_date*RcrtES_Site_v1r0/list missing out=vis_site_clc_bld;run;
***NOTE: There were 7 observations read from the data set WORK.BIOSBASE_TUBE1.
NOTE: The data set WORK.VIS_SITE has 3 observations and 6 variables.
*****;
data vis_site_clc_bld; set vis_site_clc_bld; visit=count;
label visit="Number of visits";attrib wk_date label="date" format=datetime21.;
run;
proc sort data=vis_site_clc_bld; by RcrtES_Site_v1r0;run;



proc sort data=tmp2_clc; by BL_BioClin_Urinetime BioSpm_Visit_v1r0;run;
data biosbase_clc; set tmp2_clc;
if _n_=1 then Biouri_Starttime_clc = BL_BioClin_Urinetime;
format BioUri_starttime_clc datetime21.;
retain BioUri_Starttime_clc;where BL_BioClin_Urinetime ^=. ;
run;

proc sort data=biosbase_clc; by descending BL_BioClin_Urinetime BioSpm_Visit_v1r0;run;
data biosbase_clc; set biosbase_clc;
if _n_=1 and  BL_BioClin_Urinetime ^=. then BioUri_Stoptime_clc = BL_BioClin_Urinetime;
format BioUri_Stoptime_clc datetime21.;
retain BioUri_Stoptime_clc;
run;

proc sort data=biosbase_clc; by RcrtES_Site_v1r0 BL_BioClin_Urinetime; run;
data biosbase_clc; set biosbase_clc;
by RcrtES_Site_v1r0;
if first.RcrtES_Site_v1r0=1 then BioUri_Starttime_site=BL_BioClin_Urinetime;
if last.RcrtES_Site_v1r0=1 then BioUri_Stoptime_site=BL_BioClin_Urinetime;
format BioUri_starttime_site datetime21. BioUri_stoptime_site datetime21. ;
retain BioUri_Starttime_site BioUrid_stoptime_site;
 run;
proc sort data=biosbase_clc;by connect_id; run;

data biosbase_clc_uri;
set biosbase_clc;
by connect_id;
wk=1+floor(intck("second",BioUri_Starttime_clc,BL_BioClin_Urinetime)/(60*60*24*7));
wk_date=BioUri_Starttime_clc+7*60*60*24*(wk-1);
attrib wk_date label="date" format=datetime21.;
format BioUri_Starttime_clc datetime21.;

BL_BioClin_Urinedate =datepart(BL_BioClin_Urinetime);
format BL_BioClin_Urinedate date9.;
if BioFin_BaseSpeci_v1r0 then tubecol_sum=1;

if last.connect_id=1 then output;run;

data time_clc_Uri;
set biosbase_clc_uri;
keep Connect_ID RcrtES_Site_v1r0 wk wk_date Biouri_Starttime_clc BioUri_Starttime_site BL_BioClin_Urinetime tubecol_sum; run;
proc sort data=time_clc_Uri; by RcrtES_Site_v1r0 wk;run;

***to do the weekly plots of biospecimen collection by site;
proc freq data=biosbase_clc_uri;
table Biouri_Starttime_clc*wk*wk_date*RcrtES_Site_v1r0/list missing out=vis_site_clc_uri;run;
***NOTE: There were 7 observations read from the data set WORK.BIOSBASE_CLC_URI.
NOTE: The data set WORK.VIS_SITE_CLC_URI has 3 observations and 6 variables.
*****;
data vis_site_clc_uri; set vis_site_clc_uri; visit=count;
label visit="Number of visits";attrib wk_date label="date" format=datetime21.;
run;
proc sort data=vis_site_clc_uri; by RcrtES_Site_v1r0;run;

data bio_chicago;set tmp;where connect_id=Connectbio_ID and chicago=1;run;
%Table1_CTSPedia(DSName=bio_chicago, GroupVar=BioRec_CollectScheduled, NumVars=,
           FreqVars =BioBld_Complete ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(CP), 
Print=Y,Label=L,Out=chicago_collsche); 

*******;
%LET date=%SYSFUNC( PUTN( %SYSFUNC( DATE() ),WEEKDATE.));
%LET time=%SYSFUNC( PUTN( %SYSFUNC( TIME() ),TIME8. ));
%PUT sysdate=&sysdate systime=&systime; 
ods html;
/*ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_06242022.pdf";*/
/*ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_v2_07182022.pdf";
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_v3_07182022.pdf";
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_v4_07182022.pdf";
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_09262022.pdf"; *//*updated Sep.26,2022*/


ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_Clincal_Research_01232023.pdf"; /*updated Oct.03,2022*/
*ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Stage_Clincal_Research_11082022_test2.pdf"; /*updated Oct.03,2022*/

options nodate;
ods gridded column=6;
%PUT date=&date time=&time;
/*data _null_;	
	my_date = today();
	format my_date date9.;
	put "Current Date (formatted as DDMMMYYYY): " my_date;
run;*/
 
FOOTNOTE1 J=L H=1 "Output created: &date &time for Biospecimen tested metrics downloaded Jan 23, 2023";

/*proc print data=biospec_zero noobs label;
title "Table 1. Percent (and number) of verified participants with baseline biospecimen collections by site";
var label GroupVal1 GroupVal2 total;run;
Table 1.*/
data table1;set biospec_zero;
site=label;if label="Site" then delete;
 run;
proc report data=table1  split='/' nowd ;
title "Table 1.Percent (and number) of verified participants with baseline biospecimen collections";
footnote2 "Any samples includes baseline blood, urine and/or mouthwash. Based on data entered into Connect Biospecimen Dashboard"; 
footnote3 "excluding one participant (Connect_ID 5312274299 in Chicago) had the complete research biospecimen collections on blood, urine, mouthwash";
columns  site GroupVal2 GroupVal1 Total;
define site/ "Site " width=36 left;
define GroupVal2 /"Any Samples Collected" center width=20; 
define  GroupVal1/"No Samples Collected" left width=20;
define Total/"Total " center width=10; 
run;

/*Table 2.*/
title "Table 2. Percent (and number) of verified participants with baseline blood collected";

/*%Table1Print_CTSPedia(DSname=Biospec_one, Space=Y);*/
data table2;set biospec_one;
site=label;if label="Site" then delete;
 run;
proc report data=Table2  split='/' nowd ;
columns  site GroupVal2 GroupVal1 Total;
define site/ "Site " width=36 left;
define GroupVal2 /"Blood Collected" center width=20; 
define  GroupVal1/"Blood Not Collected" left width=20;
define Total/"Total" center width=10; 
run;

/*Table 3.*/
title "Table 3. Percent (and number) of verified participants with baseline urine collected";
/*%Table1Print_CTSPedia(DSname=Biospec_two, Space=Y);*/
data table3;set biospec_two;
site=label;if label="Site" then delete;
 run;
proc report data=table3  split='/' nowd ;
columns  site GroupVal2 GroupVal1 Total;
define site/ "Site" width=36 left;
define GroupVal2 /"Urine Collected" center width=20; 
define  GroupVal1/"No Urine Collected" left width=20;
define Total/"Total " center width=10; 
run;
/*Table 4. */
title "Table 4. Percent (and number) of verified participants with baseline mouthwash collected";
/*%Table1Print_CTSPedia(DSname=Biospec_three, Space=Y);*/
data table4;set biospec_three;
site=label;if label="Site" then delete;
 run;
proc report data=table4  split='/' nowd ;
columns  Site GroupVal2 GroupVal1 Total;
define site/ "Site" width=36 left;
define GroupVal2 /"Mouthwash Collected" center width=20; 
define  GroupVal1/"No Mouthwash Collected" left width=20;
define Total/"Total" center width=10; 
run;

/*Table 5. */
proc freq data=tmp;
tables BioFin_BaseBloodCol_v1r0*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list cumcol missing noprint out=threebio;
/*where connect_id=connectbio_id;*/
run;
data threebio1;
set threebio end=last_obs;
retain cumcount cumperc; length perc_char $8.;length cumpct_char $10.;
cumcount=sum(cumcount,count);cumperc=sum(percent,cumperc);
perc_char=put(round(percent,0.01), 4.2)||'%';
cumpct_char=put(round(cumperc,0.01),4.2)||'%';
label BioFin_BaseBloodCol_v1r0="Blood Collected?"
	BioFin_baseUrineCol_v1r0="Urine Collected?"
	BioFin_BaseMouthCol_v1r0="Mouthwash Collected?"
	perc_char="Percent of Total Frequency"
	cumcount="Cumulative Frequency"
	cumpct_char="Cumulative Percent";
run;
proc print data=threebio1 noobs label;
title "Table 5. Baseline biospecimen collection status among verified participants Based on data entered into Connect Biospecimen Dashboard."; /*Sep. 12,2022 title updated/requested by Michelle*/
var BioFin_BaseBloodCol_v1r0 BioFin_baseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0 count perc_char cumcount cumpct_char;
footnote "based on the recruitment data, excluding one participant (Connect_ID 5312274299) had the complete research biospecimen collections on blood, urine, mouthwash in Chicago";
run;

proc sort data=tmp; by  RcrtES_Site_v1r0 BioSpm_setting_v1r0;run;
proc freq data=tmp;
by RcrtES_Site_v1r0;
tables BioSpm_setting_v1r0*BioFin_BaseBloodCol_v1r0*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list missing cumcol  noprint out=threebio_site;
/*where connect_id=connectbio_id;*/
run;
proc sort data=threebio_site; by RcrtES_Site_v1r0 BioSpm_setting_v1r0;run;
proc sql;
create table threebio1_site as
select RcrtES_Site_v1r0,BioSpm_setting_v1r0, BioFin_BaseBloodCol_v1r0, BioFin_baseUrineCol_v1r0, BioFin_BaseMouthCol_v1r0,
 count, sum(count) as totalcount
   from threebio_site /*baseline*/
      group by RcrtES_Site_v1r0
      order by RcrtES_Site_v1r0,BioSpm_Setting_v1r0;
quit;
run;
%macro site_setting(siteno,site,table);
data threebio_&site;set threebio1_site;
where RcrtES_Site_v1r0=&siteno;
run;
proc sort data=threebio_&site; by BioFin_BaseBloodCol_v1r0 BioFin_baseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0; run;
data threebio_&site;
set threebio_&site end=last_obs;
retain cumcount; length perc_char $8.;length cumpct_char $10.;
cumcount=sum(cumcount,count);
perc_char=put(round(100*count/totalcount,0.01), 4.2)||'%';
cumpct_char=put(round(100*cumcount/totalcount,0.01),4.2)||'%';
label RcrtES_Site_v1r0="site"
	BioSpm_setting_v1r0="Biospecimen Collection Setting"
	BioFin_BaseBloodCol_v1r0="Blood Collected?"
	BioFin_baseUrineCol_v1r0="Urine Collected?"
	BioFin_BaseMouthCol_v1r0="Mouthwash Collected?"
	perc_char="Percent of Total Frequency"
	cumcount="Cumulative Frequency"
	cumpct_char="Cumulative Percent";
run;
proc print data=threebio_&site noobs label;
title "&table. Baseline biospecimen collection status among verified participant at &site"; /*Sep. 12,2022 title updated/requested by Michelle*/
var RcrtES_Site_v1r0 BioSpm_setting_v1r0 BioFin_BaseBloodCol_v1r0 BioFin_baseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0 count perc_char cumcount cumpct_char;
run;
%mend;
%site_setting(531629870,HP,Table 6.);
%site_setting(548392715,HFHS,Table 7.);
%site_setting(303349821,MFH,Table 8.);
%site_setting(657167265,Sanford,Table 9.);
%site_setting(809703864,UoC,Table 10.);
/*%site_setting(125001209,KPCO,Table11 );
%site_setting(452412599,KPNW,Table12 );
%site_setting(327912200,KPGA,Table13 );*/

***	531629870 = "HealthPartners"
	548392715 = "Henry Ford Health System"
	125001209 = "Kaiser Permanente Colorado"
	327912200 = "Kaiser Permanente Georgia"
	300267574 = "Kaiser Permanente Hawaii"
	452412599 = "Kaiser Permanente Northwest"
	303349821 = "Marshfield Clinic Health System"
	657167265 = "Sanford Health"
	809703864 = "University of Chicago Medicine"
****;

****Nov. 8, 2022 metrics Edits:
•Use the updated version of Table 6 that includes the No Blood Collected column
•Exclude KP sites from Table 6
•Change title to Blood completeness among baseline research sample collections
Nov. 11, 2022 metrics Edits (page 7 pie chart)
Exclude KP sites from Table 6 Pie Chart
•Change title to Table X. Blood completeness among baseline research sample collections
•Add a table after this pie chart to compare KP blood per API vs KP blood per dashboard, mockup below
********;
title "Table 14. Percent (and number) of Blood Completeness among baseline research sample collections";
data table12;set biospec_seven1;
site=label;if label="Site" then delete;
 run;
proc report data=table12  split='/' nowd ;
columns  site GroupVal1 GroupVal2 GroupVal3 Total;
define site/ "Site" width=36 left;
define GroupVal1/"No Blood Tubes Collected" left width=20;
define  GroupVal2/"Partial Blood Tubes Collected" left width=20;
define GroupVal3 /"All Blood Tubes Collected" center width=20; 
define Total/"Total" center width=10; 
run;

title "Table 15. Blood completeness among baseline clinical blood collections";
data table11b;length GroupVal2 $6.; length GroupVal3 $6.;set biospec_eight;
site=label;if label="Site" then delete;
GroupVal2= "0 (0%)";
GroupVal3= "0 (0%)";

 run;
proc report data=table11b  split='/' nowd ;
columns  site GroupVal2 GroupVal1 GroupVal3 Total;
define site/ "Site" width=36 left;
define GroupVal2/"No Blood Tubes Collected" left width=20;
define  GroupVal1/"Partial Blood Tubes Collected" left width=20;
define GroupVal3 /"All Blood Tubes Collected" center width=20; 
define Total/"Total" center width=10; 
run;
***Table 12. a table after this pie chart to compare KP blood per API vs KP blood per dashboard;
***denominator is all verified participants that is used as the percent denominator for all cells;

title "Table 16. Blood collected status according to data sent by KP vs data entered into Connect dashboard at RRL";
*%Table1Print_CTSPedia(DSname=Bld_api_db, Space=Y);
data api_db_bld;length GroupVal2 $6.; length GroupVal3 $6.;set Bld_api_db;
if label=" " then delete;
if label="   Total" then GroupVal2=0;
else if label in ("   No","   Yes")then GroupVal2= "0 (0%)";
 run;
proc report data=api_db_bld  split='/' nowd ;
columns label GroupVal2 GroupVal1  Total;
define label/ " "  width=36 left;
define GroupVal2/"Clinical DB Blood RRL Received" left width=20;
define  GroupVal1/"Clinical DB Blood RRL Received" left width=20;
define Total/"Total" center width=10; 
run;
title "Table 17. Urine collected status according to data sent by KP vs data entered into Connect dashboard at RRL";
*%Table1Print_CTSPedia(DSname=urine_api_db, Space=Y);
data api_db_urine;length GroupVal2 $6.; length GroupVal3 $6.;set urine_api_db;
if label=" " then delete;
if label="   Total" then GroupVal2=0;
else if label in ("   No","   Yes")then GroupVal2= "0 (0%)";
 run;
proc report data=api_db_urine  split='/' nowd ;
columns label GroupVal2 GroupVal1  Total;
define label/ " "  width=36 left;
define GroupVal2/"Clinical DB Urine RRL Received" left width=20;
define  GroupVal1/"Clinical DB Urine RRL Received" left width=20;
define Total/"Total" center width=10; 
run;
***Table 13.Urine collected status according to data sent by KP vs data entered into Connect dashboard at RRL;
***the RRL is Regional Reference Lab. This is where clinical collections arrive for processing and shipping;


proc sort data=blood1; by label; run;
proc sort data=urine1; by label; run;
proc sort data=mouth1; by label; run;

data biospe_two;merge blood1 (in=a) urine1;
by label;run;

data biospe_all;merge biospe_two (in=a) mouth1;
by label;run;

data biospe_all;set biospe_all;
Label Blood_Val2="Blood collected"
  Urine_Val2="Urine collected"
	Mouth_Val2="Mouthwash collected";
run;
/*Table 17*/
proc print data=Biospe_all Label noobs; 
title "Table 19. Number of blood, urine, and mouthwash collected by collection setting";
var Label Blood_Val2 Urine_Val2 Mouth_Val2;
run;

***the blood collection with baseline check in only for the non-KP sites;
***Exclude KP sites from Table 8 (KP sites do not do have check-in process);
***the blood collection with baseline check in;


/*Table 18.*/ 
proc print data=freqcount_w noobs split='_' noobs label;
title "Table 20. baseline research blood collections";
var BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 BioFin_BaseBloodCol_v1r0_Yes BioFin_BaseBloodCol_v1r0_No total;
run;


/*Table 19. */
proc print data=bumincomple label noobs split='/' ;
title "Table 21. Baseline research sample collections";
/*var BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 Bio_BLBUM_collected_v1r0_Yes Bio_BLBUM_collected_v1r0_No total;
where Bio_BLBUM_collected_v1r0=104430631;*/
run; 
footnote1 "";
title "Table 22. Number (and percent) of tubes with any deviation by site"; 
data table17;set Biodev1;
site=label;if label="Site" then delete;
 run;
proc report data=table17  split='/' nowd ;
columns  site GroupVal2 GroupVal1 Total;
define site/ "Site" width=36 left;
define  GroupVal2/"Any Deviation" left width=20;
define GroupVal1 /"No Deviation" center width=20; 
define Total/"Total" center width=10; 
run;


/*Table 18. */
proc report data=dev_details_counts  split='/' nowd ;
title "Table 23. Number of deviations by biospecimen type and by tube type";
columns BioSpm_Setting_v1r0 BioTube_type_v1r0 _label_ count;
define BioSpm_Setting_v1r0/ width=12 left;
define BioTube_type_v1r0/"Biospecimen Types" width=10 left;
define _label_ /"Biospecimen collection Deviation?" left width=95;
define count /"Counts of Biospecimen Deviations" center width=10; 
run;/*n=32*/

/*%Table1Print_CTSPedia(DSname=Bionotcoll_re, Space=Y);*/
data table19;set Bionotcoll_re;
site=label;if label="Site" then delete;
 run;
proc report data=table19 split='/' nowd;
title "Table 24. Number of tube tubes not collected at research collection visits";
columns Site GroupVal1 GroupVal2 GroupVal3 GroupVal4 GroupVal5 GroupVal6 GroupVal7 Total;
define site/ "Site" width=36 left;
define GroupVal1 /"SS Tube1 " center width= 10;
define GroupVal2 /"SS Tube2" center width= 10;
define GroupVal3 /"ACD Tube1" center width= 10;
define GroupVal4 /"EDTA Tube1" center width= 10;
define GroupVal5 /"Heparin Tube1" center width=10;
define GroupVal6 /"Mouthwash Tube1" center width=10;
define GroupVal7 /"Urine Tube1" center width=10;
define Total /"Total Tubes Not Collected in Site"  center width=10;
run; 


data table20;
/*length GroupVal3 $6.; length GroupVal4 $6.; length GroupVal5 $6.; length GroupVal6 $6.; length GroupVal7 $6.;
 length GroupVal8 $6.; length GroupVal9 $6.; length GroupVal10 $6.; length GroupVal11 $6.; length GroupVal12 $6.;*/
set Bionotcoll_cc;
site=label;if label in ("Site", " ") then delete;
/*if label^="   Total" then do; 
GroupVal3="0 (0%)";GroupVal4="0 (0%)";GroupVal5="0 (0%)";GroupVal6="0 (0%)";GroupVal7="0 (0%)";
 GroupVal8="0 (0%)";GroupVal9="0 (0%)";GroupVal10="0 (0%)";GroupVal11="0 (0%)";GroupVal12="0 (0%)";end;
else if label="   Total" then do; GroupVal3="0";GroupVal4="0";GroupVal5="0";GroupVal6="0";GroupVal7="0"; GroupVal8="0";GroupVal9="0";
GroupVal10="0";GroupVal11="0";GroupVal12="0";end;*/
 run;
proc report data=table20 split='/' nowd;
title "Table 25. Number of tube tubes not collected at clinical collections";
columns Site GroupVal1 GroupVal2 GroupVal3 GroupVal4 GroupVal5 GroupVal6 GroupVal7 GroupVal8 GroupVal9 GroupVal10 GroupVal1 GroupVal2
Total;
define site/ "Site" width=36 left;
define GroupVal1 /"SS Tube1 " center width= 10;
define GroupVal2 /"SS Tube2" center width= 10;
define GroupVal3 /"SS Tube3 " center width= 10;
define GroupVal4 /"SS Tube4" center width= 10;
define GroupVal5 /"SS Tube5 " center width= 10;
define GroupVal6 /"ACD Tube1" center width= 10;
define GroupVal7 /"EDTA Tube1" center width= 10;
define GroupVal8 /"EDTA Tube2" center width= 10;
define GroupVal9 /"EDTA Tube3" center width= 10;
define GroupVal10 /"Heparin Tube1" center width=10;
define GroupVal11 /"Heparin Tube2" center width=10;
define GroupVal12 /"Urine Tube1" center width=10;
define Total /"Total Tubes Not Collected in Site"  center width=10;
run; 

proc report data=BioNotColl4_re split='/' nowd;
title "Table 26. Reason not collected by tube type and by site, research collections only";
columns label GroupVal2 GroupVal4 GroupVal1 GroupVal3 GroupVal5 GroupVal6 Total;
define label /"Tube Type" width=35 left;
define GroupVal2 /"Short draw" center width= 9;
define GroupVal4 /"Participants Attempted" center width= 9;
define GroupVal1 /"Other" center width= 9;
define GroupVal3 /"Participants Refusal" center width= 9;
define GroupVal5 /"Supply Unavailable" center width=9;
define GroupVal6 /"Missing reasons" center width=9;
define Total /"Total Tubes Not Collected by site" center width=12;
run; 

data table27;
length GroupVal2 $10.; length GroupVal3 $6.; length GroupVal4 $6.; length GroupVal5 $6.; length GroupVal6 $6.;
set Bionotcoll4_cc;
site=label;if label in ("Site", " ") then delete;
if label^="   Total" then do; 
GroupVal3="0 (0%)";GroupVal4="0 (0%)";GroupVal5="0 (0%)";GroupVal6="0 (0%)";GroupVal2="0 (0%)";end;
else if label="   Total" then do; GroupVal3="0";GroupVal4="0";GroupVal5="0";GroupVal6="0";GroupVal2="0";end;
 run;
proc report data=table27 split='/' nowd;
title "Table 27. Reason not collected by tube type and by site, clinical collections only";
columns label GroupVal2 GroupVal3 GroupVal4 GroupVal5 GroupVal6 GroupVal1 Total;
define label /"Tube Type" width=35 left;
define GroupVal2 /"Short draw" center width= 9;
define GroupVal3 /"Participants Attempted" center width= 9;
define GroupVal4 /"Other" center width= 9;
define GroupVal5 /"Participants Refusal" center width= 9;
define GroupVal6 /"Supply Unavailable" center width=9;
define GroupVal1 /"Missing reasons" center width=9;
define Total /"Total Tubes Not Collected by site" center width=12;
run; 

Title "Table 28.Number of tube tubes Discarded by tube type and site";
%Table1Print_CTSPedia(DSname=Biodiscard, Space=Y);
proc print data=svcomplte_resh noobs label;
title "Table 29. Total number and percent of research biospecimen survey status";
run;

proc print data=svcomplte_clc noobs label;
title "Table 30. Total number and percent of clinical biospecimen survey status";
run;

proc print data=sv_visittm_resh noobs label;
/*title "Table 17. Number and percent of research biospecimen survey completion time by survey status";*/
title "Table 31. Baseline research biospecimen survey completion time from time of visit check-in";
where SrvBLM_ResSrvCompl_v1r0=231311385;
run;

/*title1 "which variable is used to define the clinical start time, the survey start time?";*/
proc print data=sv_visittm_clc noobs label;
title "Table 32. Number and percent of clinical biospecimen survey completion time bysurvey status";
where SrvBlU_BaseComplete_v1r0=231311385;
run;

proc format;
 value outfmt
  0 ="no outlier"
  1 ="outlier"
  9 = "Missing (not checked out)";
data tmp_resh;set tmp;
  if abs(time_biochk/60) > 24 then biochk_outlier=1;
  else if 0< =abs(time_biochk/60) < = 24 then biochk_outlier=0;
  if time_biochk=. then biochk_outlier=9;
  attrib biochk_outlier label="biospecimen checking time outlier(>24hrs)?" format=outfmt.;
  if BioSpm_Setting_v1r0=534621077 then output;
 run;

/*Table 28.*/ 
proc means data=tmp_resh n nmiss min mean median max std maxdec=2 noprint;

var time_biochk;
class biochk_outlier;
format biochk_outlier outfmt.;
output out=sumstat n= nmiss= min= mean= median= max= std=/autoname ;
run;

data sumstat;set sumstat;
label time_biochk_N="Total"
 time_biochk_Nmiss="Missed"
 time_biochk_Min="Minimum"
 time_biochk_mean="Mean"
 time_biochk_median="Median"
 time_biochk_Max="Maximum"
 time_biochk_stdDev="Std Dev"
 biochk_outlier="Outlier Present?";
 run;
proc print data=sumstat noobs label; 
title "Table 33a. Research biospecimen collection visit length (in minutes)";
var biochk_outlier time_biochk_N time_biochk_Nmiss time_biochk_min time_biochk_mean time_biochk_median time_biochk_max time_biochk_stddev;
where _type_=1; run;
ods graphics on;
proc sgplot data=tmp_resh;
vbox time_biochk;
yaxis LABEL="Visit length (minutes)";
refline 1440 / lineattrs=(pattern=dot) label="24 hours";run;
/*Table 17. */
proc means data=tmp_resh n nmiss min mean median max std maxdec=2 noprint;
title "Table 33b. Research biospecimen collection visit length by site (in minutes)";
var time_biochk ;
class biochk_outlier RcrtES_Site_v1r0;
output out=sumstat_site n= nmiss= min= mean= median= max= std=/autoname ;
format biochk_outlier outfmt.;
run;
data sumstat_site;set sumstat_site;
label time_biochk_N="Total"
 time_biochk_Nmiss="Missed"
 time_biochk_Min="Minimum"
 time_biochk_mean="Mean"
 time_biochk_median="Median"
 time_biochk_Max="Maximum"
 time_biochk_stdDev="Std Dev"
 biochk_outlier="Outlier Present?";
 run;

proc print data=sumstat_site noobs label; 
title "Table 33b. Research biospecimen collection visit length by site (in minutes)";
var biochk_outlier RcrtES_Site_v1r0 time_biochk_N time_biochk_Nmiss time_biochk_min time_biochk_mean time_biochk_median time_biochk_max time_biochk_stddev;
where _type_=3; run;
proc sgplot data=tmp_resh;
vbox time_biochk/category=RcrtES_Site_v1r0;
yaxis LABEL="Visit length (minutes)";
refline 1440 / lineattrs=(pattern=dot) label="24 hours";run;

proc sgplot data=vis_site;
title "Number of Research Biospecimen Collection visits over time by site";
series x=wk_date y=visit / group=RcrtES_Site_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=RcrtES_Site_v1r0 groupms=RcrtES_Site_v1r0;
yaxis values=(0 to 40 by 2);
xaxis INTERVAL=week;
format wk_date datetime21. RcrtES_Site_v1r0 SiteFmt. ;
run;

title "Number of Clinical Biospecimen Collection visits over time by site";
title2 "which time variable would be applied to define the collection censoring time";
%PUT sysdate=&sysdate systime=&systime; 
%PUT sysdate=&sysdate systime=&systime; 

/*proc sgplot data=tmp_clin;
vbox time_biochk/category=RcrtES_Site_v1r0;
yaxis LABEL="Visit length (minutes)";
refline 1440 / lineattrs=(pattern=dot) label="24 hours";run;*/

proc sgplot data=vis_site_clc_bld;
title "Number of Clinical Blood Biospecimen Collection visits over time by site";
series x=wk_date y=visit / group=RcrtES_Site_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=RcrtES_Site_v1r0 groupms=RcrtES_Site_v1r0;
yaxis values=(0 to 20 by 1);
xaxis INTERVAL=week;
format wk_date datetime21. RcrtES_Site_v1r0 SiteFmt. ;
run;


proc sgplot data=vis_site_clc_uri;
title "Number of Clinical Urine Biospecimen Collection visits over time by site";
series x=wk_date y=visit / group=RcrtES_Site_v1r0 markers lineattrs=(pattern=solid)
                 break GROUPMC=RcrtES_Site_v1r0 groupms=RcrtES_Site_v1r0;
yaxis values=(0 to 20 by 1);
xaxis INTERVAL=week;
format wk_date datetime21. RcrtES_Site_v1r0 SiteFmt. ;
run;

proc report data=chicago_collsche split='/' nowd ;
title "Table 34. Blood Collection Completeness by Walk-In vs Scheduled for UChicago Site";
columns label GroupVal1 GroupVal2 Total;
define label /"Blood Collection Completions" width=35 left;
define GroupVal1 /"Blood Collections by Walk-in" center width= 20;
define GroupVal2 /"Blood Collections by Scheduled" center width= 20;
define Total /"Total Blood Collection" center width=10;
Where Total ^= " ";
run;
ods graphics off;
ods pdf close;
*Michelle Mockup comments (Nov. 2022)Blood Collection Completeness by Walk-In vs Scheduled for UChicago Site. 
Change label on last column to 'Total Blood Collections'. 
Confirm walk-in is defined as participant was verified and had blood collection on same day;

data no_match;
set tmp;
if 
