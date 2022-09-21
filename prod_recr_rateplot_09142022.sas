proc freq data=tmp;
title "Percent (and number) of verified participants Blood, Urine and Mouthwash collected with the baseline participants 08082022";
tables BioSpm_Setting_v1r0*BioFin_BaseSpeci_v1r0*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0*BioFin_BaseBloodCol_v1r0 BioFin_BaseBloodCol_v1r0/list missing out=one;
run;
ods listing;
ods html;
proc print data=tmp noobs;
var connect_ID BioFin_BaseSpeci_v1r0 RcrtES_Site_v1r0 BioFin_baseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0 BioFin_BaseBloodCol_v1r0 BioFin_BaseBloodCol_v1r0
 BioRec_CollectFinal_v1r0 BioSpm_ColIDScan_v1r0;
where BioFin_BaseSpeci_v1r0=353358909 and BioRec_CollectFinal_v1r0=.;run;

/*Table 5. */


proc freq dataa=tmp; table RcrtES_Site_v1r0/list missing; run;

proc freq data=tmp; table RcrtES_Site_v1r0*BL_BioChk_Complete_v1r0/list missing; run;

****Sep. 14, 2022, this SAS code is to calculate the recruitment response rate among the verified recruits among active recruitment
****working data: prod.recruitment.recruitment1_WL which is flattened from connect.participants table (downloaded on Sep. 14, 2022
****key variables: verified status, recruitment type, also excluding the duplicated recruits
****the recruitment time= time gap between the invitation sentout time and the verification time
****This was original done with R, as Dr. Gaudet Mia requested to add them into the recruitment metrics
****the outputs: tables of the recruitment per month each site and overall (starting from Jan. 2022)
****the response rate = N of the verified /active recruitments
****Cumulative Verified by time
****Cumulative Invitation (only active recruitment counted
****Cumulative Response Rate: the response rate = N of the verified /active recruitments

****Notes from Amelia:
***WEEKLY METRICS
***	New metrics:
***	a. Active recruits or passive recruits that are verified with no deidentified data
***	b. Add crosstab of duplicate counts and duplicate type to weekly metrics report stratified by passive vs. active and by site
***	c. Add time trend graph for count of duplicates above
***	d. Add markers for when wording about using the same account as before added to PWA login screen; 
***		(redacted account solution added email message; 
***		and new login pages (still in dev’t)
***	e. Add table for Mia of verified participants by site and per month (non-cumulative). Should include # active recruits, 
***			#active verified, #passive verified, #invitations, % active response rate (new w/ just actives), 
***			%total/overall response rate (how we are calculating currently with both active+passive in numerator), 
***			#opt outs + time trend graph
***	f. Crosstab of people in the ‘consented, no profile’ status stratified by account sign in mechanism to watch for people who 
***		are stuck in that status and not getting any reminders to complete their UP due to signing in with phone (and time trend 
***		as well to see if this is increasing?)
***	g. Metric on whether our user profile reminders work at all for those who do receive them. In other words, does anyone finish 
***	their UP after UP reminder 1, reminder 2, etc
***	Similar to above, metric on whether our survey reminders are working. How affective they are
***	Minor updates:
***	‘How recruits heard about the study’ table – currently the denominator is out all of recruits (regardless of sign in), 
***	should be out of recruits signed in (or should it be out of consented??)
***	Add column for ‘total cannot be verified’ for each site to ‘reasons cannot be verified’ table as right now the total is 
***	only for all recruits.
***	Take out category for ‘Google.com’ for sign-in mechanism as this is not being used anymore.
***	Opt outs:
***	Change sorting of pre-consent opt-out to descending by total %
***	Stratify this table by binomial age of working group vs. retired (lt 55, ge 55?)
***	Will need to upcode many of the ‘reasons-other specified’. TBD. Amelia to categorize all of the other reasons to get a 
***	count.
***	Add additional categories for reasons for opt-out: : Language barrier, already in another study, transportation/distance to clinic barrier, not a member
***	Deanna to draft KBAs
***	Data issues:
***	verification mode in weekly report all showing as 0 (Madhuri aware, likely due to UofC data issue where sent string instead of integer)
***	reason cannot be verified all showing as 0 (Madhuri aware, likely due to UofC data issue where sent string instead of integer)
***	For reasons for opt-out, UofC is showing a total of n=7 opt-outs but all the categories are showing as 0 for UofC (Madhuri aware, looking into issue)
**********************************;

libname data "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data";
option nofmterr;
ods listing; ods html close;
proc format;
 value optoutfmt
  			104430631 = "No"
			353358909 = "Yes";
 VALUE SiteFmt
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
			125001209 = "Kaiser Permanente Colorado"
			327912200 = "Kaiser Permanente Georgia"
			300267574 = "Kaiser Permanente Hawaii"
			452412599 = "Kaiser Permanente Northwest"
			303349821 = "Marshfield Clinic Health System"
			657167265 = "Sanford Health"
			809703864 = "University of Chicago Medicine"
			517700004 = "National Cancer Institute"
			13 = "National Cancer Institute"
			181769837 = "Other";
 VALUE RecruitTypeFmt 
			180583933 = "Not active"
            486306141 = "Active"
		    854703046 = "Passive" ;
 VALUE VerificationStatusFmt
			875007964 = "Not yet verified"
			197316935 = "Verified"
			219863910 = "Cannot be verified"
			922622075 = "Duplicate"
			160161595 = "Outreach timed out";

data recr_resprate;
set data.prod_recrdate_4plot_091422;
rename  d_821247024 = RcrtV_Verification_v1r0
d_914594314 = RcrtV_VerificationTm_V1R0
d_512820379 = RcrtSI_RecruitType_v1r0
d_158291096 = 	RcrtSI_OptOut_v1r0
d_471593703 = RcrtSI_TypeTime_v1r0
d_827220437 = RcrtES_Site_v1r0;
run;
proc sort data=recr_resprate; by RcrtSI_TypeTime_v1r0 RcrtV_VerificationTm_V1R0; run;
proc sql;
create table recr_resprate as
select 
Connect_ID as Connect_id,
Token as token,
d_821247024 as RcrtV_Verification_v1r0,
d_914594314 as RcrtV_VerificationTm_V1R0,
d_512820379 as RcrtSI_RecruitType_v1r0,
d_158291096 as 	RcrtSI_OptOut_v1r0,
d_471593703 as RcrtSI_TypeTime_v1r0,
d_827220437 as RcrtES_Site_v1r0,
min(d_471593703) as RecrAll_Starttime,
max(d_471593703) as RecrAll_checktime
from data.prod_recrdate_4plot_091422
order by token;
run;
quit;
run;

data recr_resprate;set recr_resprate;

recrstart_wk=1+floor(intck("second",RecrAll_Starttime,RcrtSI_TypeTime_v1r0)/(60*60*24*7));
if RcrtV_Verification_v1r0=197316935 then do;
recrveri_wk=1+floor(intck("second",RecrAll_Starttime,RcrtV_VerificationTm_V1R0)/(60*60*24*7));
Rcrt_Centorwk=recrveri_wk;
end;
else if RcrtV_Verification_v1r0 ^=197316935 or RcrtV_Verification_v1r0=.  then  
Rcrt_Centorwk=1+floor(intck("second",RecrAll_Starttime,RecrAll_Checktime)/(60*60*24*7));
attrib RcrtSI_OptOut_v1r0 label="Pre-consent Opt-out" format=optoutfmt.
	RcrtSI_TypeTime_v1r0 label="Time recruitment type assigned"
	RcrtSI_RecruitType_v1r0 label= "Recruitment type" format=RecruitTypeFmt.
	RcrtV_Verification_v1r0 label= "Verification status" format=VerificationStatusFmt.
	RcrtES_Site_v1r0 label= "Site" format=SiteFmt.	
	RcrtV_VerificationTm_V1R0 label= "Verification status time"
	RecrAll_Starttime label="recruitment Start time of all site" format=datetime21.
	RecrAll_Checktime label="recruitment recent recruitment time of all site" format=datetime21.
	recrstart_wk label="recruitment time by week" recrall_Starttime label="Recruitment Start time"
	recrveri_wk label="recruitment verification time by week from the recruitment start"
	Rcrt_Centorwk label="Centoring time till verification";

run;
***to calculate the cumulative number of verified, total active recruitments, and total optout by time;
proc freq data=recr_resprate; tables RcrtSI_OptOut_v1r0 RcrtSI_RecruitType_v1r0 RcrtV_Verification_v1r0 
RcrtSI_RecruitType_v1r0*RcrtV_Verification_v1r0/list missing;run;
***                                                                      Pre-consent Opt-out

                                                  RcrtSI_
                                                  OptOut_                             Cumulative    Cumulative
                                                     v1r0    Frequency     Percent     Frequency      Percent
                                                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                      No        68840       95.85         68840        95.85
                                                      Yes        2978        4.15         71818       100.00


                                                                        Recruitment type

                                                   RcrtSI_
                                                   Recruit                             Cumulative    Cumulative
                                                 Type_v1r0    Frequency     Percent     Frequency      Percent
                                                ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                Active           71571       99.66         71571        99.66
                                                Passive            247        0.34         71818       100.00


                                                                      Verification status

                                                        RcrtV_                             Cumulative    Cumulative
                                             Verification_v1r0    Frequency     Percent     Frequency      Percent
                                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                            Verified                  2367        3.30          2367         3.30
                                            Cannot be verified           3        0.00          2370         3.30
                                            Not yet verified         69448       96.70         71818       100.00

       RcrtSI_Recruit                RcrtV_                             Cumulative    Cumulative
            Type_v1r0     Verification_v1r0    Frequency     Percent     Frequency      Percent
     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
     Active              Verified                  2120        2.95          2120         2.95
     Active              Cannot be verified           3        0.00          2123         2.96
     Active              Not yet verified         69448       96.70         71571        99.66
     Passive             Verified                   247        0.34         71818       100.00
*******;
proc means data=recr_resprate n nmiss mean std min q1 median q3 max maxdec=2;
var recrstart_wk recrveri_wk Rcrt_Centorwk;
run;
***                                                                                               N                                                       Lower
  Variable       Label                                                                  N    Miss           Mean        Std Dev        Minimum       Quartile
  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
  recrstart_wk   recruitment time by week                                           71818       0          50.72           7.86           1.00          47.00
  recrveri_wk    recruitment verification time by week from the recruitment start    2367   69451          50.84           8.65           1.00          47.00
  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

                                                                                                                          Upper
                 Variable       Label                                                                    Median        Quartile         Maximum
                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                 recrstart_wk   recruitment time by week                                                  52.00           56.00           60.00
                 recrveri_wk    recruitment verification time by week from the recruitment start          53.00           57.00           60.00
                 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
*******;

proc freq data=recr_resprate;table RecrAll_Starttime*recrstart_wk/list missing out=recr_count noprint;run;
proc freq data=recr_resprate;table recrveri_wk/list cumcol outcum out=veri_count(rename=(cum_freq=cum_veri)) noprint;where RcrtV_Verification_v1r0= 197316935;run;
proc sort data=recr_resprate; by recrstart_wk Rcrt_Centorwk recrveri_wk;run;
data recr_count;set recr_count; 
cum_recruit+count;
drop percent;
run;
proc  sql;
create table recrver_cum as 
select
a. *, b. recrveri_wk, b. cum_veri
from 
recr_count a
full join 
veri_count b
on a. recrstart_wk = b. recrveri_wk
order a. recrstart_wk;
run;
quit;

proc sort data=recrver_cum; by recrstart_wk recrveri_wk; run;


data recrver_cum1; set recrver_cum;
if recrveri_wk =.  and recrstart_wk>0 then recrveri_wk=recrstart_wk;
if recrveri_wk>0 and recrstart_wk=. then recrstart_wk=recrveri_wk;
label cum_recruit ="cumulative recruitment people at recruimment wks" 
	  cum_veri="cumultive verified number of people at recruitment wks";
run;
proc sort data=recrver_cum1; by recrstart_wk recrveri_wk; run;
data recrver_cum1; set recrver_cum1;
cum_recruit1=lag(cum_recruit);cum_veri1=lag(cum_veri);RecrAll_Starttime1=lag(RecrAll_Starttime);
if cum_recruit=. then cum_recruit=cum_recruit1;
if cum_veri=. then cum_veri=cum_veri1;
if RecrAll_Starttime =. then recruitment_date=datepart(RecrAll_Starttime1+ 7*60*60*24*(recrstart_wk-1));
if recrAll_starttime ^=. then recruitment_date = datepart(RecrAll_Starttime + 7*60*60*24*(recrstart_wk-1));
format recruitment_date date9. RecrAll_Starttime1 datetime21.;
response_rate=100*cum_veri/cum_recruit;
recruitment_month=put(recruitment_date, mmyy7.);
run;

proc print data=recrver_cum1 noobs;
var RecrAll_Starttime recruitment_date  recrstart_wk recrveri_wk cum_veri cum_recruit response_rate; 
run;
****                                                   recruitment_    recrstart_    recrveri_                  cum_     response_
                                  RecrAll_Starttime        date            wk            wk       cum_veri    recruit       rate

                                 23JUL2021:20:00:15     23JUL2021           1             1            3           9      33.3333
                                 23JUL2021:20:00:15     30JUL2021           2             2            8          10      80.0000
                                                  .     17SEP2021           9             9            9          10      90.0000
                                 23JUL2021:20:00:15     24SEP2021          10            10            9          20      45.0000
                                 23JUL2021:20:00:15     15OCT2021          13            13           10          21      47.6190
                                 23JUL2021:20:00:15     22OCT2021          14            14           11          26      42.3077
                                                  .     29OCT2021          15            15           16          26      61.5385
                                 23JUL2021:20:00:15     05NOV2021          16            16           18          73      24.6575
                                 23JUL2021:20:00:15     12NOV2021          17            17           20          75      26.6667
                                 23JUL2021:20:00:15     19NOV2021          18            18           21         141      14.8936
                                 23JUL2021:20:00:15     26NOV2021          19            19           24         316       7.5949
                                 23JUL2021:20:00:15     03DEC2021          20            20           31         384       8.0729
                                 23JUL2021:20:00:15     10DEC2021          21            21           32         547       5.8501
                                 23JUL2021:20:00:15     17DEC2021          22            22           40         772       5.1813
                                 23JUL2021:20:00:15     24DEC2021          23            23           44         917       4.7983
                                 23JUL2021:20:00:15     31DEC2021          24            24           46        1073       4.2870
                                 23JUL2021:20:00:15     07JAN2022          25            25           52        1145       4.5415
                                 23JUL2021:20:00:15     14JAN2022          26            26           55        1406       3.9118
                                 23JUL2021:20:00:15     21JAN2022          27            27           62        1484       4.1779
                                 23JUL2021:20:00:15     28JAN2022          28            28           68        1776       3.8288
                                 23JUL2021:20:00:15     04FEB2022          29            29           73        1854       3.9374
                                 23JUL2021:20:00:15     11FEB2022          30            30           80        2309       3.4647
                                 23JUL2021:20:00:15     18FEB2022          31            31           92        2421       3.8001
                                 23JUL2021:20:00:15     25FEB2022          32            32          101        2574       3.9239
                                 23JUL2021:20:00:15     04MAR2022          33            33          110        3021       3.6412
                                 23JUL2021:20:00:15     11MAR2022          34            34          130        3582       3.6293
                                 23JUL2021:20:00:15     18MAR2022          35            35          147        3689       3.9848
                                 23JUL2021:20:00:15     25MAR2022          36            36          158        4007       3.9431
                                 23JUL2021:20:00:15     01APR2022          37            37          179        5143       3.4805
                                 23JUL2021:20:00:15     08APR2022          38            38          201        5609       3.5835
                                 23JUL2021:20:00:15     15APR2022          39            39          224        5747       3.8977
                                 23JUL2021:20:00:15     22APR2022          40            40          246        6905       3.5626
                                 23JUL2021:20:00:15     29APR2022          41            41          269        7846       3.4285
                                 23JUL2021:20:00:15     06MAY2022          42            42          319        9109       3.5020
                                 23JUL2021:20:00:15     13MAY2022          43            43          365       10041       3.6351
                                 23JUL2021:20:00:15     20MAY2022          44            44          402       11734       3.4259
                                 23JUL2021:20:00:15     27MAY2022          45            45          450       13500       3.3333
                                 23JUL2021:20:00:15     03JUN2022          46            46          500       16065       3.1124
                                 23JUL2021:20:00:15     10JUN2022          47            47          603       19572       3.0809
                                 23JUL2021:20:00:15     17JUN2022          48            48          685       22397       3.0584
                                 23JUL2021:20:00:15     24JUN2022          49            49          760       25187       3.0174
                                 23JUL2021:20:00:15     01JUL2022          50            50          832       27985       2.9730
                                 23JUL2021:20:00:15     08JUL2022          51            51          980       32995       2.9701
                                 23JUL2021:20:00:15     15JUL2022          52            52         1114       36712       3.0344
                                 23JUL2021:20:00:15     22JUL2022          53            53         1241       39394       3.1502
                                 23JUL2021:20:00:15     29JUL2022          54            54         1379       42469       3.2471
                                 23JUL2021:20:00:15     05AUG2022          55            55         1515       49783       3.0432
                                 23JUL2021:20:00:15     12AUG2022          56            56         1697       54470       3.1155
                                 23JUL2021:20:00:15     19AUG2022          57            57         1883       58693       3.2082
                                 23JUL2021:20:00:15     26AUG2022          58            58         2058       63006      3.26636
                                 23JUL2021:20:00:15     02SEP2022          59            59         2252       68032      3.31021
                                 23JUL2021:20:00:15     09SEP2022          60            60         2367       71818      3.29583

********;

***to convert the response rate by month;
proc sort data=recrver_cum1; by recruitment_month recrstart_wk; run;
data recrver_cum1_month;set recrver_cum1;
by recruitment_month;
if last.recruitment_month=1 then output;
run;

*proc summary data=recrver_cum1 nway;
*class recruitment_date / order=freq; /* sort by descending sum */
*format recruitment_date monyy7.; /* apply year format to date for grouping purposes */
*var recrveri_wk cum_veri cum_recruit response_rate;
*output out=recrver_cum1_month (drop=_:) sum=;
*run;
proc sort data=recrver_cum1_month; by recrveri_wk; run;
proc print data=recrver_cum1_month noobs;
var RecrAll_Starttime recruitment_date recruitment_month recrstart_wk recrveri_wk cum_veri cum_recruit response_rate; 
run;
****                                               recruitment_    Recruitment_    recrstart_    recrveri_                  cum_     response_
                          RecrAll_Starttime        date           month            wk            wk       cum_veri    recruit       rate

                         23JUL2021:20:00:15     30JUL2021        JUL2021            2             2            8          10      80.0000
                         23JUL2021:20:00:15     24SEP2021        SEP2021           10            10            9          20      45.0000
                                          .     29OCT2021        OCT2021           15            15           16          26      61.5385
                         23JUL2021:20:00:15     26NOV2021        NOV2021           19            19           24         316       7.5949
                         23JUL2021:20:00:15     31DEC2021        DEC2021           24            24           46        1073       4.2870
                         23JUL2021:20:00:15     28JAN2022        JAN2022           28            28           68        1776       3.8288
                         23JUL2021:20:00:15     25FEB2022        FEB2022           32            32          101        2574       3.9239
                         23JUL2021:20:00:15     25MAR2022        MAR2022           36            36          158        4007       3.9431
                         23JUL2021:20:00:15     29APR2022        APR2022           41            41          269        7846       3.4285
                         23JUL2021:20:00:15     27MAY2022        MAY2022           45            45          450       13500       3.3333
                         23JUL2021:20:00:15     24JUN2022        JUN2022           49            49          760       25187       3.0174
                         23JUL2021:20:00:15     29JUL2022        JUL2022           54            54         1379       42469       3.2471
                         23JUL2021:20:00:15     26AUG2022        AUG2022           58            58         2058       63006       3.2664
                         23JUL2021:20:00:15     09SEP2022        SEP2022           60            60         2367       71818       3.2958
******;
 goptions reset=all border;
***Figure 1. the reponse rate vs total active recruitment;
/* Define the axis characteristics */                                                                                                   
   axis1 label=('Calender time')
      offset=(0,0); 

   axis2 label=(angle=90 'Individuls, N')
         order=(0 to 80000 by 10000) offset=(0,0);                                                                                                    
                                                                                                                                        
/* Define the symbol characteristics. */                                                                                                
/* Join the points to define the areas. */                                                                                              
   symbol1 interpol=join cv=blue value=dot;                                                                                                      

                                                                                                                            
/* Define the legend options */                                                                                                         
proc gplot data=recrver_cum1;                                                                                                                  
   plot cum_recruit*recruitment_date
		response_rate*recruitment_date/ overlay areas=1                                                                                
                              haxis=axis1 vaxis=axis2;
where recrstart_wk > 23;
run;                                                                                                                                    
quit;


**option two: works well;
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\LongitudinalPlots_Connect_recruitment_09152022.pdf";
proc print data=recrver_cum1 noobs;run;

proc sgplot data=recrver_cum1;
vbarparm category=recruitment_date response=cum_recruit / barwidth=1 fill nooutline;
yaxis values=(0 to 80000  by 5000) label="Individuals, N";
xaxis valuesrotate=vertical valueattrs=(size=6) discreteorder=data label="Calendar Time";
   series x=recruitment_date y=cum_recruit / markers legendlabel="Cumulative Invitation";
   series x=recruitment_date y=response_rate/ markers Y2Axis legendlabel="Response Rate"
		lineattrs=(color=red pattern=dash) 
                          markerattrs=(color=red symbol=circlefilled); 
   /*xaxis values=(0 to 12 by 2);*/
   yaxis  label="Individuals, N" offsetmax=0.01
      values=(0 to 80000 by 10000);
   /* the same offsets must be used in both YAXIS and Y2AXIS stmts */
   y2axis  label="Response Rate, %" offsetmax=0.01
      values=(2.0 3.0 4.0 5.0 6.0 7.0 8.0 )
      valuesdisplay=('2.0' '3.0' '4.0' '5.0' '6.0' '7.0' '8.0' ); 
title "Fig1. Cumulative Number of Individual Invited and Response Rate";
where recrstart_wk > 23;
run;
	
proc sgplot data=recrver_cum1;
vbarparm category=recruitment_date response=cum_veri / barwidth=1 fill nooutline;
yaxis values=(0 to 2500 by 250) label="Individuals, N";
xaxis valuesrotate=vertical valueattrs=(size=6) discreteorder=data label="Calendar Time";
   series x=recruitment_date y=cum_veri / markers legendlabel="Cumulative Verified";
   series x=recruitment_date y=response_rate/ markers Y2Axis legendlabel="Response Rate"
		lineattrs=(color=red pattern=dash) 
                          markerattrs=(color=red symbol=circlefilled); 
   /*xaxis values=(0 to 12 by 2);*/
   yaxis  label="Individuals, N" offsetmax=0.01
      values=(0 to 2500 by 250);
   /* the same offsets must be used in both YAXIS and Y2AXIS stmts */
   y2axis  label="Response Rate, %" offsetmax=0.01
      values=(2.0 3.0 4.0 5.0 6.0 7.0 8.0)
      valuesdisplay=( '2.0' '3.0' '4.0' '5.0' '6.0' '7.0' '8.0'); 
title "Fig1. Cumulative Number of Individual Verified and Response Rate";
where recrstart_wk > 23;
run;

%macro reponserate_site(site);	
data site; set recr_resprate; where RcrtES_Site_v1r0=&site; run; 
proc freq data=site;table RecrAll_Starttime*recrstart_wk/list missing out=recr_count noprint;
run;
proc freq data=site;table recrveri_wk/list cumcol outcum out=veri_count(rename=(cum_freq=cum_veri)) noprint;where RcrtV_Verification_v1r0= 197316935;run;
proc sort data=site; by recrstart_wk Rcrt_Centorwk recrveri_wk;run;
data recr_count;set recr_count; 
cum_recruit+count;
drop percent;
rename count=recruit_count;
run;
proc  sql;
create table recrver_cum as 
select
a. *, b. recrveri_wk, b. count, b. cum_veri
from 
recr_count a
full join 
veri_count b
on a. recrstart_wk = b. recrveri_wk
order a. recrstart_wk;
run;
quit;

proc sort data=recrver_cum; by recrstart_wk recrveri_wk; run;


data recrver_cum1; set recrver_cum;
if recrveri_wk =.  and recrstart_wk>0 then recrveri_wk=recrstart_wk;
if recrveri_wk>0 and recrstart_wk=. then recrstart_wk=recrveri_wk;
label cum_recruit ="cumulative recruitment people at recruimment wks" 
	  cum_veri="cumultive verified number of people at recruitment wks";
site = &site; format site SiteFmt.;
run;
proc sort data=recrver_cum1; by site recrstart_wk; run;
data recrver_cum2; set recrver_cum1;
if cum_recruit ^=. then cum_recruit1 = cum_recruit;
if cum_veri ^=. then cum_veri1 = cum_veri;

if RecrAll_Starttime ^=. then do;
 RecrAll_Starttime1=RecrAll_Starttime;
recruitment_date = datepart(RecrAll_Starttime + 7*60*60*24*(recrstart_wk-1));end;

retain cum_recruit1 cum_veri1 RecrAll_Starttime1;

if cum_recruit = . then cum_recruit = cum_recruit1;
if cum_veri = . then cum_veri = cum_veri1;
if RecrAll_Starttime =. then do;
	RecrAll_Starttime=RecrAll_Starttime1 ;
   recruitment_date=datepart(RecrAll_Starttime1+ 7*60*60*24*(recrstart_wk-1));end;

format recruitment_date date9. RecrAll_Starttime1 datetime21.;
response_rate=100*cum_veri/cum_recruit;


rename count=veri_count;
label count="numbers of verified by week"
	recruit_count="numbers of invitated by week";

run;

data site_&site;set recrver_cum2;
keep site RecrAll_Starttime recruitment_date recrstart_wk recrveri_wk recruit_count veri_count cum_veri cum_recruit response_rate;
run;

proc append base=recrver_site data=site_&site force;run;
%mend;
%reponserate_site(531629870);/*"HealthPartners"*/
%reponserate_site(548392715);/*"Henry Ford Health System"*/
%reponserate_site(125001209);/*"Kaiser Permanente Colorado"*/
%reponserate_site(327912200);/*"Kaiser Permanente Georgia"*/
%reponserate_site(300267574);/*"Kaiser Permanente Hawaii"*/
%reponserate_site(452412599);/*"Kaiser Permanente Northwest"*/
%reponserate_site(303349821);/*"Marshfield Clinic Health System"*/
%reponserate_site(657167265);/*"Sanford Health"*/
%reponserate_site(809703864);/*"University of Chicago Medicine"*/

proc means data=recrver_site min max maxdec=2 noprint;
class site;
var cum_veri cum_recruit response_rate;
output out=max_site max(cum_veri)= max(cum_recruit)= /autoname;
where recrstart_wk > 23;run;

data recrver_site;set site_531629870 site_548392715; run;
ods graphics on;
%macro plot_rate(site, recruit_max,grid_recruit_max, veri_max,grid_veri_max,format);
proc print data=site_&site noobs;
var site RecrAll_Starttime recruitment_date recrstart_wk recrveri_wk recruit_count veri_count cum_veri cum_recruit response_rate;
run; 
proc sgplot data=site_&site;
vbarparm category=recruitment_date response=cum_recruit / barwidth=1 fill nooutline;
yaxis values=(0 to &recruit_max by &grid_recruit_max) label="Individuals, N";
xaxis valuesrotate=vertical valueattrs=(size=6) discreteorder=data label="Calendar Time";
   series x=recruitment_date y=cum_recruit / markers legendlabel="Cumulative Invitation";
   series x=recruitment_date y=response_rate/ markers Y2Axis legendlabel="Response Rate"
		lineattrs=(color=red pattern=dash) 
                          markerattrs=(color=red symbol=circlefilled); 
   /*xaxis values=(0 to 12 by 2);*/
   yaxis  label="Individuals, N" offsetmax=0.01
      values=(0 to &recruit_max by &grid_recruit_max);
   /* the same offsets must be used in both YAXIS and Y2AXIS stmts */
   y2axis  label="Response Rate, %" offsetmax=0.01
      values=(1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 10.0 20.0 40.0 60.0 80.0 100.0 )
      valuesdisplay=('1.0' '2.0' '3.0' '4.0' '5.0' '6.0' '7.0' '8.0' '10.0' '20.0' '40.0' '60.0' '80.0' '100.0'); 
title "Figure. Cumulative Number of Individual Invited and Response Rate &format";
where recrstart_wk > 23;
run;
	
proc sgplot data=site_&site;
vbarparm category=recruitment_date response=cum_veri / barwidth=1 fill nooutline;
yaxis values=(0 to &veri_max by &grid_veri_max) label="Individuals, N";
xaxis valuesrotate=vertical valueattrs=(size=6) discreteorder=data label="Calendar Time";
   series x=recruitment_date y=cum_veri / markers legendlabel="Cumulative Verified";
   series x=recruitment_date y=response_rate/ markers Y2Axis legendlabel="Response Rate"
		lineattrs=(color=red pattern=dash) 
                          markerattrs=(color=red symbol=circlefilled); 
   /*xaxis values=(0 to 12 by 2);*/
   yaxis  label="Individuals, N" offsetmax=0.01
      values=(0 to &veri_max by &grid_veri_max);
   /* the same offsets must be used in both YAXIS and Y2AXIS stmts */
   y2axis  label="Response Rate, %" offsetmax=0.01
      values=(1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 10.0 20.0 40.0 60.0 80.0 100.0)
      valuesdisplay=( '1.0' '2.0' '3.0' '4.0' '5.0' '6.0' '7.0' '8.0' '10.0' '20.0' '40.0' '60.0' '80.0' '100.0'); 
title "Fig1. Cumulative Number of Individual Verified and Response Rate &format";
where recrstart_wk > 23;
run;
%mend;
%plot_rate(531629870, 8000,800,500,50,HealthPartners); /*response rate: 5.42 7.13*/
%plot_rate(548392715, 1100,110,100,10,Henry Ford Health System); /*response rate: 8.83 100.00*/
%plot_rate(125001209, 14500,1450,500,50,Kaiser Permanente Colorado); /*response rate: 2.80 71.43*/
%plot_rate(300267574, 6000,600,140,14,Kaiser Permanente Hawaii); /*response rate: 1.94 85.71*/
%plot_rate(327912200, 9200,920,180,18,Kaiser Permanente Georgia); /*response rate:  1.19 57.14*/
%plot_rate(452412599, 14500,1450,520,52,Kaiser Permanente Northwest); /*response rate: 2.45 62.50*/
%plot_rate(809703864, 300,30,100,10,University of Chicago Medicine); /*response rate: 32.29 82.35*/
%plot_rate(657167265, 13300,1330,180,18,Sanford Health); /*response rate: 1.02 2.03*/
%plot_rate(303349821, 5700,570,220,22,Marshfield Clinic Health System); /*response rate: 2.06 12.24*/

*****
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
			125001209 = "Kaiser Permanente Colorado"
			327912200 = "Kaiser Permanente Georgia"
			300267574 = "Kaiser Permanente Hawaii"
			452412599 = "Kaiser Permanente Northwest"
			303349821 = "Marshfield Clinic Health System"
			657167265 = "Sanford Health"
			809703864 = "University of Chicago Medicine"
			517700004 = "National Cancer Institute"
			13 = "National Cancer Institute"
			181769837 = "Other"

              site                               Obs         Minimum         Maximum
               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
               Kaiser Permanente Colorado          31            2.00          470.00
                                                                12.00        14454.00
                                                                 2.80           71.43

               Kaiser Permanente Hawaii            25            4.00          131.00
                                                                 7.00         5825.00
                                                                 1.94           85.71

               Marshfield Clinic Health System     32            6.00          218.00
                                                                49.00         5696.00
                                                                 2.06           12.24

               Kaiser Permanente Georgia           25            1.00          176.00
                                                                 7.00         9190.00
                                                                 1.19           57.14
               Kaiser Permanente Northwest         26            1.00          517.00
                                                                 8.00        14430.00
                                                                 2.45           62.50

               HealthPartners                      37           26.00          492.00
                                                               462.00         7636.00
                                                                 5.42            7.13

               Henry Ford Health System            23            2.00           90.00
                                                                 2.00         1019.00
                                                                 8.83          100.00

               Sanford Health                      31           15.00          175.00
                                                               762.00        13283.00
                                                                 1.02            2.03

               University of Chicago Medicine      16            5.00           98.00
                                                                 1.00          285.00
                                                                32.29           82.35
               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

********;

****the expected and actual recruitment;
data expected;
input site expected;
datalines;
548392715	1600
531629870	2247
125001209	1900
327912200	1300
300267574	790
452412599	1900
303349821	760
657167265	1015
809703864	4690
run;

proc sql;
create table recruit_now as
select 
a. *, b. expected
from 
max_site a
inner join
expected b
on a. site = b. site
order by a.site;
quit;
run;
data recruit_now;
set recruit_now;
response_rate=round(100*cum_veri_max/cum_recruit_max,0.01);
drop _type_ _freq_;
run;

proc sort data=recruit_now; by site; run;
ods html;
ods graphics on;

proc sgplot data=recruit_now nowall noborder;
vbarparm category=site response=expected/datalabel nofill;
vbarparm category=site response=cum_veri_max  /datalabel DATALABELPOS=Bottom barwidth=1.0 fill 
 transparency=0.0 ;
/*series x=site y=response_rate/ markers datalabel=response_rate discreteoffset=0.22 Y2Axis legendlabel="Response Rate"
                          markerattrs=(color=red symbol=circlefilled);*/ 
scatter x=site y=response_rate /datalabel=response_rate DATALABELPOS=Bottom Y2Axis legendlabel="Response Rate"
				markerattrs=(color=red symbol=circlefilled);
yaxis values=(0 to 4800 by 200) offsetmin=0 offsetmax=0.1 label="Individual, N";
xaxis label="Site" discreteorder=data;
y2axis  label="Response Rate, %" offsetmax=0.1
      values=(2.0 4.0 6.0 8.0 10.0 20.0 30.0 35.0)
      valuesdisplay=('2.0' '4.0' '6.0' '8.0' '10.0' '20.0' '30.0' '35.0'); 
run;
ods pdf close;

proc export data=recrver_site outfile="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\responserate_prod_bysite_09152022.csv"
dbms=csv replace;
run;	

proc sort data=recrver_site; by site recruitment_date;
run;
data recrver_site; set recrver_site;
recruitment_month=put(recruitment_date,monyy7.);
run;
proc sort data=recrver_site; by site recruitment_month recrveri_wk;run;

data recrver_site_month;set recrver_site;
by site recruitment_month;
if last.recruitment_month=1 then output;
run;


proc sgplot data=recruit_now nowall noborder;
vbar site /response=cum_veri_max datalabel ;
vbar site /response=expected datalabel barwidth=0.5 transparency=0.4;
/*series x=site y=response_rate/ markers Y2Axis legendlabel="Response Rate"
                            markerattrs=(color=red symbol=circlefilled);*/
yaxis values=(0 to 4800 by 200) offsetmin=0 offsetmax=0.1 label="Individual, N";
xaxis label="Site" discreteorder=data;
/*y2axis  label="Response Rate, %" offsetmax=0.1
values=(2.0 4.0 6.0 8.0 10.0 20.0 30.0 35.0)
valuesdisplay=('2.0' '4.0' '6.0' '8.0' '10.0' '20.0' '30.0' '35.0');*/
run;



proc format;
value typefmt
1="N actual verified"
2="N expected verifid";
data recruit_long;
set recruit_now;
by site;
array cum {2} cum_veri_max expected;
do i =1 to 2;
Ncum_verification=cum{i};
output;
end;
format i typefmt.;
run;

