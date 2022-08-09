****to update the biospecimen and boxes data in Prod as Michelle requested on Jun 17, 2022, especially the boxes data with more 
****new entries from Thursday afternoon after I did the primary check before 3pm Thursday, Jun. 16,2022.
*************;
libname data "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data";
option nofmterr;
ods listing;ods html close;

%macro indata(path,file,outdata);
proc import datafile="&path\&file" out=&outdata dbms=csv replace;
    getnames=yes; GUESSINGROWS=1000000;
run; 
proc contents data=&outdata varnum noprint out=id; run;
%mend;
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,Prod_flatBoxes_06242022.csv,var_boxes);/*n=20, variable=22*/
%let path=\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data;

***a new batch on Jul. 1, 2022;
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,Prod_flatBoxes_07012022_v2.csv,var_boxes);/*n=20, variable=22*/
%indata(&path,stg_flatBoxes_07062022.csv,var_boxes);
%indata(&path,Stg_Boxes_Flatten_WL_07072022.csv,var_boxes);
%indata(&path,prod_flatBoxes_07112022.csv,var_boxes);
%indata(&path,prod_flatBoxes_071812022.csv,var_boxes);
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_07182022.csv,var_boxes);/*n=20, variable=22*/
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_WL_07252022.csv,var_boxes);/*n=20, variable=22*/
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_WL_08012022.csv,var_boxes);/*n=20, variable=22*/
%indata(\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\data,prod_flatBoxes_WL_08082022.csv,var_boxes);/*n=20, variable=22*/


proc format; 
value biobagfmt
	104430631="No"
	353358909="Yes";

value ShipSubmitfmt /*145971562*/
	104430631 = "NO"
	353358909 = "YES";

value OrphanBagfmt /*255283733*/
	104430631 = "NO"
	353358909 = "YES";

value ContainsOrphanfmt /*842312685*/
	104430631 = "NO"
	353358909 = "YES";

value TempProbefmt /*105891443*/
	104430631 = "NO"
	353358909 = "YES";

value ShipCourierfmt /*666553960*/
	712278213 = "FedEx"
	149772928 = "World Courier";

value ShipRecfmt /*333524031*/
	104430631 = "NO"
	353358909 = "YES";

value localIDfmt /*560975149*/
	698283667="Lake Hallie"
	777644826="UC-DCAM"
	692275326="Marshfield"
	834825425="HP Research Clinic"
	589224449="SF Cancer Center LL"
	763273112="KPCO RRL"
	531313956="KPHI RRL"
	715632875="KPNW RRL"
	767775934="KPGA RRL"
	752948709="Henry Ford Main Campus"
	570271641="Henry Ford West Bloomfield Hospital"
	838480167="Henry Ford Medical Center- Fairlane";

value Logsitefmt /*789843387*/
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
	181769837 = "Other";

value $shipcondifmt
	"121149986" = "Crushed"
	"200183516" = "Vials - Incorrect Material Type"
	"289322354" = "Material Thawed"
	"387564837" = "Damaged Vials"
	"399948893" = "Vials - Missing Labels"
	"405513630" = "Cold Packs - none"
	"442684673" = "Participant Refusal"
	"595987358" = "Cold Packs - warm"
	"613022284" = "No Refrigerant"
	"631290535" = "Vials - Empty"
	"678483571" = "Damaged Container (outer and/or inner)"
	"679749262" = "Package in good condition"
	"842171722" = "No Pre-notification"
	"847410060" = "Improper Packaging"
	"853876696" = "Manifest - not provided"
	"909529446" = "Cold Packs - insufficient"
	"922995819" = "Manifest/Paperwork/Vial information do not match"
	"933646000" = "Other- Package Condition"
	"958000780" = "Shipment Delay";

/*data flat_boxes; set var_boxes;
	
rename d_105891443	=	BioPack_TempProbe_v1r0
	
d_145971562	=	BioShip_ShipSubmit_v1r0
d_238268405 = BioPack_ShipCondtion_v1r0
d_255283733 =  BioPack_OrphanBag_v1r0
d_333524031 = BioBPTL_ShipRec_v1r0
d_469819603 = BioPack_ScanFname_v1r0
d_555611076 = BioPack_ModifiedTime_v1r0
d_560975149 = BioShip_LocalID_v1r0
d_656548982 = BioShip_ShipTime_v1r0
d_666553960 = BioPack_Courier_v1r0
d_672863981 = BioPack_BoxStrtTime_v1r0
d_789843387 = BioShip_LogSite_v1r0
d_842312685 = BioPack_ContainsOrphan_v1r0
d_870456401 = BioBPTL_ShipComments_v1r0
d_885486943 = BioShip_SignLname_v1r0
d_926457119 = BioBPTL_DateRec_v1r0
d_948887825 = BioShip_SignEmail_v1r0
d_959708259 = BioPack_TrackScan1_v1r0;

BioPack_ShipCondtion_v1r0=compress(d_238268405,"'[]""'");run;*/
data prod_boxes_flat; length d_238268405 $100. ;
set var_boxes;
BioPack_BoxID_v1r0=dequote(d_132929440);
if  count(compress(d_238268405,"'[]""'"), ",") =0 then BioPack_Conditions_v1r0=compress(d_238268405,"'[]""'");
attrib d_105891443 label = "Temperature probe in box?" format = TempProbefmt.
d_132929440 label = "Box ID"
d_145971562 label = "Submit shipment flag" format= ShipSubmitfmt.
d_333524031 label = "Shipment Received - Site Shipment" format = ShipRecfmt.
d_469819603 label = "Scanned by First Name"
d_555611076 label = "Autogenerated date/time when box last modified (bag added or removed)"
d_560975149 label = "Location ID, site specific" format = localIDfmt.
d_656548982 label = "Autogenerated date/time stamp for submit shipment time"
d_666553960 label = "Shipment courier" format = ShipCourierfmt.
d_672863981 label = "Autogenerated date/time when first bag added to box"
d_789843387 label = "Login Site" format = Logsitefmt.
d_842312685 label = "Contains Orphan Flag" format = ContainsOrphanfmt.
d_870456401 label = "Comments - Site Shipment"
d_885486943 label = "Shipper Last name signature (NOT USED)"
d_926457119 label = "Date Received - Site Shipment"
d_948887825 label = "Shipper first name signature"
d_959708259 label = "Box tracking number scan (one for each box)"
d_255283733 label = "Orphan Bag/Container/Thing Flag" format=OrphanBagfmt.
BioPack_Conditions_v1r0 label ="Select Package Condition - Site Shipment" format=$shipcondifmt.;

rename d_105891443	= BioPack_TempProbe_v1r0
d_145971562	= BioShip_ShipSubmit_v1r0
d_255283733 =  BioPack_OrphanBag_v1r0
d_333524031	= BioBPTL_ShipRec_v1r0
d_469819603 = BioPack_ScanFname_v1r0
d_555611076	= BioPack_ModifiedTime_v1r0
d_560975149	= BioShip_LocalID_v1r0
d_656548982	= BioShip_ShipTime_v1r0
d_666553960	= BioPack_Courier_v1r0
d_672863981	= BioPack_BoxStrtTime_v1r0
d_789843387	= BioShip_LogSite_v1r0
d_842312685	= BioPack_ContainsOrphan_v1r0
d_870456401	= BioBPTL_ShipComments_v1r0
d_885486943	= BioShip_SignLname_v1r0
d_926457119	= BioBPTL_DateRec_v1r0
d_948887825	= BioShip_SignFname_v1r0
d_959708259	= BioPack_TrackScan1_v1r0
/*d_238268405 =  BioPack_Conditions_v1r0*/;
run;

data data.prod_boxes_flat_06242022;set prod_boxes_flat; 
drop d_238268405;
run;


%macro boxes(boxin,boxout);
data &boxout; length d_238268405_1 $60. d_238268405_2 $60. BioPack_ShipCondtion_v1r0 $200. ;
set &boxin;
/*BioPack_BoxID_v1r0=dequote(d_132929440);*/
if compress(d_238268405,"[]")=" " then d_238268405_1=" ";
if 12 <length(d_238268405)  then do;
d_238268405_1=putc(scan(substr(d_238268405,2,length(d_238268405)-2),1,","),"$shipcondifmt.");
d_238268405_2=putc(scan(substr(d_238268405,2,length(d_238268405)-2),2,","),"$shipcondifmt.");
end;

if 8 <length(d_238268405)<13 then 
d_238268405_1=putc(scan(substr(d_238268405,2,length(d_238268405)-2),1,","),"$shipcondifmt.");
BioPack_ShipCondtion_v1r0 = catx(", ", of d_238268405_1  , d_238268405_2);

attrib d_105891443 label = "Temperature probe in box?" format = TempProbefmt.
d_132929440 label = "Box ID"
d_145971562 label = "Submit shipment flag" format= ShipSubmitfmt.
d_333524031 label = "Shipment Received - Site Shipment" format = ShipRecfmt.
d_469819603 label = "Scanned by First Name"
d_555611076 label = "Autogenerated date/time when box last modified (bag added or removed)"
d_560975149 label = "Location ID, site specific" format = localIDfmt.
d_656548982 label = "Autogenerated date/time stamp for submit shipment time"
d_666553960 label = "Shipment courier" format = ShipCourierfmt.
d_672863981 label = "Autogenerated date/time when first bag added to box"
d_789843387 label = "Login Site" format = Logsitefmt.
d_842312685 label = "Contains Orphan Flag" format = ContainsOrphanfmt.
d_870456401 label = "Comments - Site Shipment"
d_885486943 label = "Shipper Last name signature (NOT USED)"
d_926457119 label = "Date Received - Site Shipment"
d_948887825 label = "Shipper first name signature"
d_959708259 label = "Box tracking number scan (one for each box)"
d_255283733 label = "Orphan Bag/Container/Thing Flag" format=OrphanBagfmt.
BioPack_ShipCondtion_v1r0 label ="Select Package Condition - Site Shipment";

rename 
d_132929440	=	BioPack_BoxID_v1r0
d_105891443	= BioPack_TempProbe_v1r0
d_145971562	= BioShip_ShipSubmit_v1r0
d_255283733 =  BioPack_OrphanBag_v1r0
d_333524031	= BioBPTL_ShipRec_v1r0
d_469819603 = BioPack_ScanFname_v1r0
d_555611076	= BioPack_ModifiedTime_v1r0
d_560975149	= BioShip_LocalID_v1r0
d_656548982	= BioShip_ShipTime_v1r0
d_666553960	= BioPack_Courier_v1r0
d_672863981	= BioPack_BoxStrtTime_v1r0
d_789843387	= BioShip_LogSite_v1r0
d_842312685	= BioPack_ContainsOrphan_v1r0
d_870456401	= BioBPTL_ShipComments_v1r0
d_885486943	= BioShip_SignLname_v1r0
d_926457119	= BioBPTL_DateRec_v1r0
d_948887825	= BioShip_SignFname_v1r0
d_959708259	= BioPack_TrackScan1_v1r0
/*d_238268405 =  BioPack_Conditions_v1r0*/;
run;
%mend;
%boxes(var_boxes,prod_boxes_flat);

%let outpath=\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs;

ods listing; ods html close;
%macro outdata(data,date,outpath,note);
data data.&data._&date.;set &data; drop d_238268405 d_238268405_1 d_238268405_2; run;
proc export data=data.&data._&date. outfile="&outpath.\Formatted_&data._&date..csv" dbms=csv replace; run;

ods pdf file="&outpath.\Formatted_&data._&date._contents.pdf";
proc contents data=data.&data._&date. varnum; run;
option ls=150;
proc freq data=data.&data._&date.; 
table BioPack_BoxID_v1r0*BioShip_LocalID_v1r0*bagtype BioPack_BoxID_v1r0*BioPack_ShipCondtion_v1r0 /list missing; run;
ods pdf close;
%mend;
%outdata(stg_boxes_flat,07072022,&outpath,);
%outdata(prod_boxes_flat,07112022,&outpath,);
%outdata(prod_boxes_flat,07182022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);
%outdata(prod_boxes_flat,07252022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);
*n=486 07/25/2022*;
%outdata(prod_boxes_flat,08012022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);
*n=725, 08/01/2022;
%outdata(prod_boxes_flat,08082022,\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs,);

*Recruitment Variables;
PROC FORMAT;
	VALUE RecruitTypeFmt 
			180583933 = "Not active"
            486306141 = "Active"
		    854703046 = "Passive" ;

	VALUE SiteFmt
			531629870 = "HealthPartners"
			548392715 = "Henry Ford Health System"
			125001209 = "Kaiser Permanente Colorado"
			327912200 = "Kaiser Permanente Georgia"
			300267574 = "Kaiser Permanente Hawaii"
			452412599 = "Kaiser Permanente Northwest"
			303349821 = "Marshfield Clinic Health System"
			657167265 = "Sanford Health"
			809703864 = "Unviersity of Chicago Medicine"
			517700004 = "National Cancer Institute"
			13 = "National Cancer Institute"
			181769837 = "Other";


	VALUE VerificationStatusFmt
			875007964 = "Not yet verified"
			197316935 = "Verified"
			219863910 = "Cannot be verified"
			922622075 = "Duplicate"
			160161595 = "Outreach timed out";

	VALUE BaseBloodFmt
			104430631 = "No"
			353358909 = "Yes";


	VALUE BaseSrvRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseBloodRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseUrineRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseSalivaRefFmt
			104430631 = "No"
			353358909 = "Yes";
	VALUE RecruitTypeFmt 
			180583933 = "Not active"
            486306141 = "Active"
		    854703046 = "Passive" ;

	VALUE $SiteFmt
			"531629870" = "HealthPartners"
			"548392715" = "Henry Ford Health System"
			"125001209" = "Kaiser Permanente Colorado"
			"327912200" = "Kaiser Permanente Georgia"
			"300267574" = "Kaiser Permanente Hawaii"
			"452412599" = "Kaiser Permanente Northwest"
			"303349821" = "Marshfield Clinic Health System"
			"657167265" = "Sanford Health"
			"809703864" = "Unviersity of Chicago Medicine"
			"517700004" = "National Cancer Institute"
			"13" = "National Cancer Institute"
			"181769837" = "Other";

	VALUE VerificationStatusFmt
			875007964 = "Not yet verified"
			197316935 = "Verified"
			219863910 = "Cannot be verified"
			922622075 = "Duplicate"
			160161595 = "Outreach timed out";

	VALUE YesNoFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE ResSrvBLMcompleteFmt
			972455046 = "Not Started"
			615768760 = "Started"
			231311385 = "Submitted";

	VALUE $WhoRequestedRefWdFmt
			"648459216" = "The participant (via the CSC directly or via a Connect site staff)"
			"658808644" = "The Connect Principal Investigator (or designate)"
			"745366882" = "The Chair of the Connect IRB-of-record (NIH IRB)"
			"786757575" = "Site PI listed on the site-specific consent form"
			"847056701" = "Chair of the Site IRB"
			"807835037" = "Other |__|";
		

	VALUE BaseSrvRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseBloodRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseUrineRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaseSalivaRefFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE $YesNoFmt
			"104430631" = "No"
			"353358909" = "Yes";




*Biospecimen Variables;

	VALUE CollectionSettingFmt 
			534621077 = "Research"
            664882224 = "Clinical"
		    103209024 = "Home";

	VALUE SelectVisitFmt   
			153098257 = "Baseline";

	VALUE SelectHawaiianIslandFmt  
			945449846 = "Oahu"
			704199032 = "Non-Oahu";

	VALUE AccessionIDEnteredFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CollectionIDEnteredFmt 
			104430631 = "No"
			353358909 = "Yes";
	
	VALUE TubeCollectedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE AddlLabelUsedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE RegLabReceiptFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE TubeNotCollFmt 
			234139565 = "Short draw"
            681745422 = "Participant refusal" 
			745205161 = "Participant attempted"
			889386523 = "Supply Unavailable"
			181769837 = "Other" 
			999999999 = "missing";

	VALUE DeviationBrokenFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeNoClotFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeClotFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeSpeedHFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeSpeedLFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeTimeLFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationCentrifugeTimeSFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationGelFailFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationHemolyzedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationTempLFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationTempHFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationInsufficientVolFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationLeakFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationLipemiaFmt
			104430631 = "No"
			353358909 = "Yes"; 

	VALUE DeviationLowVolFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationMislabeledFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationUrineHatUsedFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationOtherFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE DiscardFlagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE GoToShippingFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaselineMouthwashColFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BaselineUrineColFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CheckinComplFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CollectionLocationFmt 
			777644826 = "UC-DCAM"
            692275326 = "Marshfield"
     		698283667 = "Lake Hallie"
     		834825425 = "HP Research Clinic"
     		736183094 = "HFHS Research Clinic (Main Campus)"
            589224449 = "SF Cancer Center LL" 
			886364332 = "HFH Cancer Pavilion Research Clinic";

	VALUE DeviationFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BlUSurveyFmt
			972455046 = "Not Started"
			615768760 = "Started"
			231311385 = "Submitted";

	VALUE MWSurveyFmt
			972455046 = "Not Started"
			615768760 = "Started"
			231311385 = "Submitted";

	VALUE ParticipantLeftFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE CheckoutComplFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE LoginSiteFmt 
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
            181769837 = "Other" ;

	VALUE LocationIDFmt 
			325115468 = "UC-DCAM" 
     		692275326 = "Marshfield" 
     		834825425 = "HP Research Clinic"
     		756784147 = "SF Cancer Center LL"
     		763273112 = "KPCO RRL"
            531313956 = "KPHI RRL" 
     		715632875 = "KPNW RRL" 
            767775934 = "KPGA RRL"
            752948709 = "Henry Ford Main Campus" 
            570271641 = "Henry Ford West Bloomfield Hospital" 
            838480167 = "Henry Ford Medical Center- Fairlane";

	VALUE TubeNotInBagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE OrphanTubeMissingFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE OrphanTubeShippedFlagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE TemperatureProbeFmt 
			104430631 = "No"
			353358909 = "Yes";
	
	VALUE ShipmentCourierFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BoxTrackEnterFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE ShipmentFlagFmt 
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioSpmVisitFmt   
			266600170 = "Baseline"
			496823485 = "Follow-up 1"
			650465111 = "Follow-up 2"
			303552867 = "Follow-up 3";

	VALUE BioSpmLocFmt
			777644826 = "UC-DCAM"
			692275326 = "Marshfield"
			698283667 = "Lake Hallie"
			834825425 = "HP Research Clinic"
			736183094 = "HFHS Research Clinic (Main Campus)"
			589224449 = "SF Cancer Center LL"
			886364332 = "HFH Cancer Pavilion Research Clinic";

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

	VALUE BioSpmColIDEnteredFmt
			104430631 = "No"
			353358909 = "Yes";
			
	VALUE BioSpmSettingFmt
			534621077 = "Research"
			664882224 = "Clinical"
			103209024 = "Home";	

	VALUE BioRecShipFlagFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioColTubeCollFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioColRsnNotColFmt
			234139565 = "Short draw"
			681745422 = "Participant refusal"
			745205161 = "Participant attempted"
			889386523 = "Supply Unavailable"
			181769837 = "Other";

	VALUE BioColDeviationFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE BioColDiscardFmt
			104430631 = "No"
			353358909 = "Yes";

	VALUE DeviationSpecFmt
			104430631 = "No"
			353358909 = "Yes";

RUN;


ods listing; ods html close;
option ls=140;

proc contents data=recr_veri_bio varnum; run;
***# Variable                         Type Len Format    Informat  Label

 1 Connect_ID                       Num    8 BEST10.   BEST10.
 2 studyId                          Char  18 $CHAR18.  $CHAR18.
 3 d_878865966                      Num    8 BEST9.    BEST9.
 4 d_827220437                      Num    8 BEST9.    BEST9.
 5 d_512820379                      Num    8 BEST9.    BEST9.
 6 d_684635302                      Num    8 BEST9.    BEST9.
 7 d_822499427                      Char  26 $CHAR26.  $CHAR26.
 8 d_222161762                      Char  26 $CHAR26.  $CHAR26.
 9 d_265193023                      Num    8 BEST9.    BEST9.
10 d_167958071                      Num    8 BEST9.    BEST9.
11 d_173836415                      Char 372 $CHAR372. $CHAR372.
12 d_173836415_d_266600170_d_561681 Char  26 $CHAR26.  $CHAR26.  d_173836415_d_266600170_d_561681068
13 d_173836415_d_266600170_d_448660 Char  26 $CHAR26.  $CHAR26.  d_173836415_d_266600170_d_448660695
14 d_173836415_d_266600170_d_592099 Num    8 BEST9.    BEST9.    d_173836415_d_266600170_d_592099155
15 d_173836415_d_266600170_d_718172 Num    8 BEST9.    BEST9.    d_173836415_d_266600170_d_718172863
16 d_173836415_d_266600170_d_847159 Char  26 $CHAR26.  $CHAR26.  d_173836415_d_266600170_d_847159717
17 d_173836415_d_266600170_d_915179 Num    8 BEST9.    BEST9.    d_173836415_d_266600170_d_915179629
18 d_331584571                      Char 283 $CHAR283. $CHAR283.
19 d_331584571_d_266600170_d_135591 Num    8 BEST9.    BEST9.    d_331584571_d_266600170_d_135591601
20 d_331584571_d_266600170_d_840048 Char  26 $CHAR26.  $CHAR26.  d_331584571_d_266600170_d_840048338
21 d_331584571_d_266600170_d_343048 Char  26 $CHAR26.  $CHAR26.  d_331584571_d_266600170_d_343048998
22 d_821247024                      Num    8

********;
proc sort data=recr_veri_bio; by studyId Connect_ID; run;
proc freq data=recr_veri_bio;table d_265193023/list missing; run;


data recr_veri_bio;set data.prod_recrverified_bio_08082022;
/*d_821247024= 197316935;
array varchar {7} $ d_822499427
d_222161762
d_173836415_d_266600170_d_561681
d_173836415_d_266600170_d_448660
d_173836415_d_266600170_d_847159
d_331584571_d_266600170_d_840048
d_331584571_d_266600170_d_343048
;
array varnum {7} SrvBLM_TmStart_v1r0 SrvBLM_TmComplete_v1r0 BL_BioFin_BBTime_v1r0 BL_BioFin_BMTime_v1r0
BL_BioFin_BUTime_v1r0 BL_BioChk_Time_v1r0 BL_BioFin_CheckOutTime_v1r0;
do i=1 to 7;
if varchar{i} = " " then varnum{i}=.;
else varnum{i}=input(dequote(varchar{i}),anydtdtm.);
end;
format SrvBLM_TmStart_v1r0  datetime21. SrvBLM_TmComplete_v1r0 datetime21. BL_BioFin_BBTime_v1r0 datetime21. 
BL_BioFin_BMTime_v1r0 datetime21.
BL_BioFin_BUTime_v1r0 datetime21. BL_BioChk_Time_v1r0 datetime21. BL_BioFin_CheckOutTime_v1r0 datetime21.;

drop i;*/
run;

PROC SQL;
CREATE TABLE Concept_IDs as
SELECT 
d_512820379	as	RcrtSI_RecruitType_v1r0,
d_821247024	as 	RcrtV_Verification_v1r0, 
d_822499427	as	SrvBLM_TmStart_v1r0, /*Date/time Status of Start of blood/urine/mouthwash research survey*/
d_222161762	as	SrvBLM_TmComplete_v1r0,	/*Date/Time blood/urine/mouthwash research survey completed*/
studyId	as	studyId,
Connect_ID	as	Connect_ID, 
d_827220437 as	RcrtES_Site_v1r0,
d_265193023	as	SrvBLM_ResSrvCompl_v1r0, /*Blood/urine/mouthwash combined research survey*/
d_878865966	as	BioFin_BaseBloodCol_v1r0, /*Baseline Blood Collected*/
d_167958071	as	BioFin_BaseUrineCol_v1r0, /*Baseline Urine collected*/
d_684635302	as	BioFin_BaseMouthCol_v1r0, /*	Baseline MW Collected*/
d_331584571_d_266600170_d_135591	as	BL_BioChk_Complete_v1r0, /*Baseline Check in complete*/
d_331584571_d_266600170_d_840048	as	BL_BioChk_Time_v1r0, /*Autogenerated date/time baseline check in complete*/  
d_331584571_d_266600170_d_343048	as	BL_BioFin_CheckOutTime_v1r0, /*Autogenerated date/time baseline check out complete*/
d_173836415_d_266600170_d_448660	as	BL_BioFin_BMTime_v1r0, /*Autogenerated date/time baseline MW collected*/ 
d_173836415_d_266600170_d_561681	as	BL_BioFin_BBTime_v1r0, /*Autogenerated date/time baseline blood collected*/
d_173836415_d_266600170_d_847159	as	BL_BioFin_BUTime_v1r0, /*Autogenerated date/time baseline urine collected updated in Warren's code*/
d_173836415_d_266600170_d_592099	as	BL_BioSpm_BloodSetting_v1r0, /*Blood Collection Setting*/
d_173836415_d_266600170_d_718172	as	BL_BioSpm_UrineSetting_v1r0, /*Urine Collection Setting*/
d_173836415_d_266600170_d_915179	as	BL_BioSpm_MWSetting_v1r0/*, Mouthwash Collection Setting*/
FROM recr_veri_bio;
RUN;
QUIT;

DATA Work.Concept_ids; 
		SET Work.Concept_ids;  /*out.concept_ids_stg_format06072022*/
	 LABEL  RcrtSI_RecruitType_v1r0 = "Recruitment type"
			RcrtV_Verification_v1r0 = "Verification status"
			RcrtES_Site_v1r0 = "Site"	
		   
   			BioFin_BaseBloodCol_v1r0 = "Baseline blood sample collected"
			BL_BioFin_BBTime_v1r0 = "Date/time Blood Collected"
			BioFin_BaseMouthCol_v1r0 = "Baseline Mouthwash Collected"
			BL_BioFin_BMTime_v1r0 = "Date/time Mouthwash Collected"
			BioFin_BaseUrineCol_v1r0 = "Baseline Urine Collected"
			BL_BioFin_BUTime_v1r0 = "Baseline Date/time Urine Collected"
			BL_BioChk_Complete_v1r0 = "Baseline Check-In Complete"
			BL_BioChk_Time_v1r0 = "Date/Time Baseline Check-In Complete"
			BL_BioFin_CheckOutTime_v1r0 = "Time Baseline check out complete"
			BL_BioSpm_BloodSetting_v1r0 = "Blood Collection Setting"
			BL_BioSpm_UrineSetting_v1r0 = "Urine Collection Setting"
			BL_BioSpm_MWSetting_v1r0 = "Mouthwash Collection Setting"

			SrvBLM_ResSrvCompl_v1r0 = "Blood/urine/mouthwash combined research survey-Complete"
			SrvBLM_TmStart_v1r0 = "Placeholder (Autogenerated) - Date/time Status of Start of blood/urine/mouthwash research survey"	
 			SrvBLM_TmComplete_v1r0 = "Placeholder (Autogenerated)- Date/Time blood/urine/mouthwash research survey completed";
		FORMAT 
		RcrtSI_RecruitType_v1r0 RecruitTypeFmt.  RcrtV_Verification_v1r0 VerificationStatusFmt.  RcrtES_Site_v1r0 SiteFmt.
		BioFin_BaseBloodCol_v1r0 YesNoFmt. BioFin_BaseMouthCol_v1r0 YesNoFmt. BioFin_BaseUrineCol_v1r0 YesNoFmt. 
		BL_BioChk_Complete_v1r0 YesNoFmt.  BL_BioSpm_BloodSetting_v1r0 CollectionSettingFmt. 
		BL_BioSpm_UrineSetting_v1r0 CollectionSettingFmt. BL_BioSpm_MWSetting_v1r0 CollectionSettingFmt. 
		SrvBLM_ResSrvCompl_v1r0 ResSrvBLMcompleteFmt.;
RUN;
proc sort data=work.concept_ids; by BL_BioChk_Time_v1r0;run;



proc sql;	
CREATE TABLE Concept_IDsBios as	
select 	
Connect_ID 	as Connect_ID,
d_827220437	as RcrtES_Site_v1r0,
d_331584571	as BioSpm_Visit_v1r0,
d_338570265	as BioCol_ColNote1_v1r0,
d_387108065	as BioSpm_ColIDEntered_v1r0,
d_410912345	as BioRec_CollectFinal_v1r0,
d_556788178	as BioRec_CollectFinalTime_v1r0,
d_650516960	as BioSpm_Setting_v1r0,
d_678166505	as BioCol_ColTime_v1r0,
d_820476880	as BioSpm_ColIDScan_v1r0,
d_951355211	as BioSpm_Location_v1r0,
d_926457119	as BioBPTL_DateRec_v1r0,
d_143615646_d_926457119	as MWTube1_BioBPTL_DateRec_v1r0,
d_143615646_d_593843561	as MWTube1_BioCol_TubeCollected,
d_143615646_d_678857215	as MWTube1_BioCol_Deviation,
d_143615646_d_762124027	as MWTube1_BioCol_Discard,
d_143615646_d_825582494	as MWTube1_BioCol_TubeID,
/*d_143615646_d_883732523	as MWTube1_BioCol_NotCol,
d_143615646_d_338286049	as MWTube1_BioCol_NotCollNotes,*/
d_143615646_d_248868659_d_283900	as MWTube1_Deviation_MislabelR,
d_143615646_d_248868659_d_313097	as MWTube1_Deviation_OutContam,
d_143615646_d_248868659_d_453343	as MWTube1_Deviation_Other,
d_143615646_d_248868659_d_472864	as MWTube1_Deviation_Broken,
d_143615646_d_248868659_d_684617	as MWTube1_Deviation_MislabelD,
d_143615646_d_248868659_d_728366	as MWTube1_Deviation_LowVol,
d_143615646_d_248868659_d_742806	as MWTube1_Deviation_MWUnder30s,
d_143615646_d_248868659_d_757246	as MWTube1_Deviation_Leak,
d_143615646_d_248868659_d_982885	as MWTube1_Deviation_NotFound,
d_223999569_d_593843561	as BiohazardMW_BioCol_TubeCollected,
d_223999569_d_825582494	as BiohazardMW_BioCol_TubeID,
d_299553921_d_926457119	as SSTube1_BioBPTL_DateRec_v1r0,
d_299553921_d_593843561	as SSTube1_BioCol_TubeColl,
d_299553921_d_678857215	as SSTube1_BioCol_Deviation,
d_299553921_d_762124027	as SSTube1_BioCol_Discard,
d_299553921_d_825582494	as SSTube1_BioCol_TubeID,
d_299553921_d_883732523	as SSTube1_BioCol_NotCol,
d_299553921_d_338286049	as SSTube1_BioCol_NotCollNotes,
d_299553921_d_536710547	as SSTube1_BioCol_DeviationNotes,
d_299553921_d_248868659_d_102695	as SSTube1_Deviation_ClotS,
d_299553921_d_248868659_d_242307	as SSTube1_Deviation_Hemolyzed,
d_299553921_d_248868659_d_283900	as SSTube1_Deviation_MislabelR,
d_299553921_d_248868659_d_313097	as SSTube1_Deviation_OutContam,
d_299553921_d_248868659_d_453343	as SSTube1_Deviation_Other,
d_299553921_d_248868659_d_472864	as SSTube1_Deviation_Broken,
d_299553921_d_248868659_d_550088	as SSTube1_Deviation_TempL,
d_299553921_d_248868659_d_561005	as SSTube1_Deviation_SpeedL,
d_299553921_d_248868659_d_635875	as SSTube1_Deviation_Gel,
d_299553921_d_248868659_d_654002	as SSTube1_Deviation_TimeL,
d_299553921_d_248868659_d_684617	as SSTube1_Deviation_MislabelD,
d_299553921_d_248868659_d_690540	as SSTube1_Deviation_TempH,
d_299553921_d_248868659_d_728366	as SSTube1_Deviation_LowVol,
d_299553921_d_248868659_d_757246	as SSTube1_Deviation_Leak,
d_299553921_d_248868659_d_777486	as SSTube1_Deviation_TubeSz,
d_299553921_d_248868659_d_810960	as SSTube1_Deviation_Discard,
d_299553921_d_248868659_d_861162	as SSTube1_Deviation_SpeedH,
d_299553921_d_248868659_d_912088	as SSTube1_Deviation_ClotL,
d_299553921_d_248868659_d_937362	as SSTube1_Deviation_TimeS,
d_299553921_d_248868659_d_982885	as SSTube1_Deviation_NotFound,
d_454453939_d_926457119	as EDTATube1_BioBPTL_DateRec_v1r0,
d_454453939_d_593843561	as EDTATube1_BioCol_TubeCollected,
d_454453939_d_678857215	as EDTATube1_BioCol_Deviation,
d_454453939_d_762124027	as EDTATube1_BioCol_Discard,
d_454453939_d_825582494	as EDTATube1_BioCol_TubeID,
d_454453939_d_883732523	as EDTATube1_BioCol_NotCol,
d_454453939_d_338286049	as EDTATube1_BioCol_NotCollNotes,
d_454453939_d_248868659_d_242307	as EDTATube1_Deviation_Hemolyzed,
d_454453939_d_248868659_d_283900	as EDTATube1_Deviation_MislabelR,
d_454453939_d_248868659_d_313097	as EDTATube1_Deviation_OutContam,
d_454453939_d_248868659_d_453343	as EDTATube1_Deviation_Other,
d_454453939_d_248868659_d_472864	as EDTATube1_Deviation_Broken,
d_454453939_d_248868659_d_550088	as EDTATube1_Deviation_TempL,
d_454453939_d_248868659_d_684617	as EDTATube1_Deviation_MislabelD,
d_454453939_d_248868659_d_690540	as EDTATube1_Deviation_TempH,
d_454453939_d_248868659_d_728366	as EDTATube1_Deviation_LowVol,
d_454453939_d_248868659_d_757246	as EDTATube1_Deviation_Leak,
d_454453939_d_248868659_d_777486	as EDTATube1_Deviation_TubeSz,
d_454453939_d_248868659_d_810960	as EDTATube1_Deviation_Discard,
d_454453939_d_248868659_d_982885	as EDTATube1_Deviation_NotFound,
d_454453939_d_536710547	as EDTATube1_BioCol_DeviationNotes,
d_652357376_d_926457119	 as ACDTube1_BioBPTL_DateRec_v1r0,
d_652357376_d_338286049	as ACDTube1_BioCol_NotCollNotes,
d_652357376_d_883732523	as ACDTube1_BioCol_NotCol,
d_652357376_d_593843561	as ACDTube1_BioCol_TubeCollected,
d_652357376_d_678857215	as ACDTube1_BioCol_Deviation,
d_652357376_d_762124027	as ACDTube1_BioCol_Discard,
d_652357376_d_825582494	as ACDTube1_BioCol_TubeID,
d_652357376_d_536710547	as ACDTube_BioCol_DeviationNotes,
d_652357376_d_248868659_d_242307	as ACDTube1_Deviation_Hemolyzed,
d_652357376_d_248868659_d_283900	as ACDTube1_Deviation_MislabelR,
d_652357376_d_248868659_d_313097	as ACDTube1_Deviation_OutContam,
d_652357376_d_248868659_d_453343	as ACDTube1_Deviation_Other,
d_652357376_d_248868659_d_472864	as ACDTube1_Deviation_Broken,
d_652357376_d_248868659_d_550088	as ACDTube1_Deviation_TempL,
d_652357376_d_248868659_d_684617	as ACDTube1_Deviation_MislabelD,
d_652357376_d_248868659_d_690540	as ACDTube1_Deviation_TempH,
d_652357376_d_248868659_d_728366	as ACDTube1_Deviation_LowVol,
d_652357376_d_248868659_d_757246	as ACDTube1_Deviation_Leak,
d_652357376_d_248868659_d_777486	as ACDTube1_Deviation_TubeSz,
d_652357376_d_248868659_d_810960	as ACDTube1_Deviation_Discard,
d_652357376_d_248868659_d_982885	as ACDTube1_Deviation_NotFound,
d_703954371_d_593843561	as SSTube2_BioCol_TubeCollected,
d_703954371_d_678857215	as SSTube2_BioCol_Deviation,
d_703954371_d_762124027	as SSTube2_BioCol_Discard,
d_703954371_d_825582494	as SSTube2_BioCol_TubeID,
d_703954371_d_926457119	as SSTube2_BioBPTL_DateRec_v1r0,
d_703954371_d_883732523	as SSTube2_BioCol_NotCol,
d_703954371_d_338286049	as SSTube2_BioCol_NotCollNotes,
d_703954371_d_536710547	as SSTube2_BioCol_DeviationNotes,
d_703954371_d_248868659_d_102695	as SSTube2_Deviation_ClotS,
d_703954371_d_248868659_d_242307	as SSTube2_Deviation_Hemolyzed,
d_703954371_d_248868659_d_283900	as SSTube2_Deviation_MislabelR,
d_703954371_d_248868659_d_313097	as SSTube2_Deviation_OutContam,
d_703954371_d_248868659_d_453343	as SSTube2_Deviation_Other,
d_703954371_d_248868659_d_472864	as SSTube2_Deviation_Broken,
d_703954371_d_248868659_d_550088	as SSTube2_Deviation_TempL,
d_703954371_d_248868659_d_561005	as SSTube2_Deviation_SpeedL,
d_703954371_d_248868659_d_635875	as SSTube2_Deviation_Gel,
d_703954371_d_248868659_d_654002	as SSTube2_Deviation_TimeL,
d_703954371_d_248868659_d_684617	as SSTube2_Deviation_MislabelD,
d_703954371_d_248868659_d_690540	as SSTube2_Deviation_TempH,
d_703954371_d_248868659_d_728366	as SSTube2_Deviation_LowVol,
d_703954371_d_248868659_d_757246	as SSTube2_Deviation_Leak,
d_703954371_d_248868659_d_777486	as SSTube2_Deviation_TubeSz,
d_703954371_d_248868659_d_810960	as SSTube2_Deviation_Discard,
d_703954371_d_248868659_d_861162	as SSTube2_Deviation_SpeedH,
d_703954371_d_248868659_d_912088	as SSTube2_Deviation_ClotL,
d_703954371_d_248868659_d_937362	as SSTube2_Deviation_TimeS,
d_703954371_d_248868659_d_982885	as SSTube2_Deviation_NotFound,
d_787237543_d_593843561	as BiohazBlU_BioCol_TubeColl,
d_787237543_d_825582494	as BiohazBlU_BioCol_TubeID,
d_838567176_d_593843561	as HepTube1_BioCol_TubeCollected,
d_838567176_d_678857215	as HepTube1_BioCol_Deviation,
d_838567176_d_762124027	as HepTube1_BioCol_Discard,
d_838567176_d_825582494	as HepTube1_BioCol_TubeID,
d_838567176_d_926457119	as HepTube1_BioBPTL_DateRec_v1r0,
d_838567176_d_883732523	as HepTube1_BioCol_NotCol,
d_838567176_d_338286049	as HepTube1_BioCol_NotCollNotes,
d_838567176_d_536710547	as HepTube1_BioCol_DeviationNotes,
d_838567176_d_248868659_d_242307	as HepTube1_Deviation_Hemolyzed,
d_838567176_d_248868659_d_283900	as HepTube1_Deviation_MislabelR,
d_838567176_d_248868659_d_313097	as HepTube1_Deviation_OutContam,
d_838567176_d_248868659_d_453343	as HepTube1_Deviation_Other,
d_838567176_d_248868659_d_472864	as HepTube1_Deviation_Broken,
d_838567176_d_248868659_d_550088	as HepTube1_Deviation_TempL,
d_838567176_d_248868659_d_684617	as HepTube1_Deviation_MislabelD,
d_838567176_d_248868659_d_690540	as HepTube1_Deviation_TempH,
d_838567176_d_248868659_d_728366	as HepTube1_Deviation_LowVol,
d_838567176_d_248868659_d_757246	as HepTube1_Deviation_Leak,
d_838567176_d_248868659_d_777486	as HepTube1_Deviation_TubeSz,
d_838567176_d_248868659_d_810960	as HepTube1_Deviation_Discard,
d_838567176_d_248868659_d_982885	as HepTube1_Deviation_NotFound,
d_973670172_d_926457119	as UrineTube1_BioBPTL_DateRec_v1r0,
d_973670172_d_593843561	as UrineTube1_BioCol_TubeCollected,
d_973670172_d_678857215	as UrineTube1_BioCol_Deviation,
d_973670172_d_762124027	as UrineTube1_BioCol_Discard,
d_973670172_d_825582494	as UrineTube1_BioCol_TubeID,
d_973670172_d_883732523	as UrineTube1_BioCol_NotCol,
d_973670172_d_338286049	as UrineTube1_BioCol_NotCollNotes,
d_973670172_d_536710547	as UrineTube1_BioCol_DeviationNotes,
d_973670172_d_248868659_d_283900	as UrineTube1_Deviation_MislabelR,
d_973670172_d_248868659_d_313097	as UrineTube1_Deviation_OutContam,
d_973670172_d_248868659_d_453343	as UrineTube1_Deviation_Other,
d_973670172_d_248868659_d_472864	as UrineTube1_Deviation_Broken,
d_973670172_d_248868659_d_550088	as UrineTube1_Deviation_TempL,
d_973670172_d_248868659_d_684617	as UrineTube1_Deviation_MislabelD,
d_973670172_d_248868659_d_690540	as UrineTube1_Deviation_TempH,
d_973670172_d_248868659_d_728366	as UrineTube1_Deviation_LowVol,
d_973670172_d_248868659_d_757246	as UrineTube1_Deviation_Leak,
d_973670172_d_248868659_d_956345	as UrineTube1_Deviation_UrVol,
d_973670172_d_248868659_d_982885	as UrineTube1_Deviation_NotFound,
id	 as id,
token	as	token,
siteAcronym	as site
FROM data.prod_biospecimen_08082022;
run;quit;
****biosepcimen metric report***;


DATA Work.Concept_idsBios;
SET Concept_IDsBios;
connectbio_id =connect_id;
LABEL
BioBPTL_DateRec_v1r0 ="Date Received - Site Shipment"
ACDTube1_BioBPTL_DateRec_v1r0="ACD Tube 1- Date Received - Site Shipment"
ACDTube1_BioCol_Deviation = "ACD Tube 1- Deviation"
ACDTube1_BioCol_Discard = "ACD Tube 1- Discard Flag"
ACDTube1_BioCol_DeviationNotes = "ACD Tube 1- Deviation Details" 
ACDTube1_BioCol_NotCol = "ACD Tube 1- Reason Tube Not Collected"
ACDTube1_BioCol_NotCollNotes = "ACD Tube 1- Not Collected Details"
ACDTube1_BioCol_TubeCollected = "ACD Tube 1- Tube Collected"
ACDTube1_BioCol_TubeID = "ACD Tube 1- Tube ID"
ACDTube1_Deviation_Broken = "ACD Tube 1- Deviation Broken"
ACDTube1_Deviation_Discard = "ACD Tube 1- Deviation Discard"
ACDTube1_Deviation_Hemolyzed = "ACD Tube 1- Deviation Hemolyzed"
ACDTube1_Deviation_Leak = "ACD Tube 1- Deviation Leaked/Spilled"
ACDTube1_Deviation_LowVol = "ACD Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
ACDTube1_Deviation_MislabelD = "ACD Tube 1- Deviation Mislabeled Discard"
/*ACDTube1_Deviation_Mislabeled = "ACD Tube 1- Deviation Mislabeled"*/
ACDTube1_Deviation_MislabelR = "ACD Tube 1- Deviation Mislabeled Resolved"
ACDTube1_Deviation_NotFound = "ACD Tube 1- Deviation Not Found"
ACDTube1_Deviation_Other = "ACD Tube 1- Deviation Other"
ACDTube1_Deviation_OutContam = "ACD Tube 1- Deviation Outside Contaminated"
ACDTube1_Deviation_TempH = "ACD Tube 1- Deviation Temperature Too High"
ACDTube1_Deviation_TempL = "ACD Tube 1- Deviation Temperature Too Low"
ACDTube1_Deviation_TubeSz = "ACD Tube 1- Deviation Tube Size"
BioCol_ColNote1_v1r0 = "Collection notes"
BioCol_ColTime_v1r0 = "Collection Date/Time"
BiohazardMW_BioCol_TubeCollected = "Biohazard Bag MW- Tube Collected"
BiohazardMW_BioCol_TubeID = "Biohazard Bag MW- Tube ID"
BiohazBlU_BioCol_TubeColl = "Biohazard Bag BlU- Tube Collected"
BiohazBlU_BioCol_TubeID = "Biohazard Bag BlU- Tube ID"
BioRec_CollectFinalTime_v1r0 = "Collection Entry Finalized"
BioRec_CollectFinalTime_v1r0= "Date/Time Collection Entry Finalized"
BioSpm_ColIDEntered_v1r0 = "Collection ID Manually Entered"
BioSpm_ColIDScan_v1r0 = "Collection ID"
BioSpm_Location_v1r0 = "Collection Location"
BioSpm_Setting_v1r0 = "Collection Setting"
BioSpm_Visit_v1r0 = "Select Visit"
EDTATube1_BioBPTL_DateRec_v1r0 = "EDTA Tube 1- Date Received - Site Shipment"
EDTATube1_BioCol_Deviation = "EDTA Tube 1- Deviation"
EDTATube1_BioCol_Discard = "EDTA Tube 1- Discard Flag"
EDTATube1_BioCol_DeviationNotes = "EDTA Tube 1- Deviation Details"
EDTATube1_BioCol_NotCol = "EDTA Tube 1- Reason Tube Not Collected"
EDTATube1_BioCol_NotCollNotes = "EDTA Tube 1- Not Collected Details"
EDTATube1_BioCol_TubeCollected = "EDTA Tube 1- Tube Collected"
EDTATube1_BioCol_TubeID = "EDTA Tube 1- Tube ID"
EDTATube1_Deviation_Broken = "EDTA Tube 1- Deviation Broken"
EDTATube1_Deviation_Discard = "EDTA Tube 1- Deviation Discard"
EDTATube1_Deviation_Hemolyzed = "EDTA Tube 1- Deviation Hemolyzed"
EDTATube1_Deviation_Leak = "EDTA Tube 1- Deviation Leaked/Spilled"
EDTATube1_Deviation_LowVol = "EDTA Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
EDTATube1_Deviation_MislabelD = "EDTA Tube 1- Deviation Mislabeled Discard"
/*EDTATube1_Deviation_Mislabeled = "EDTA Tube 1- Deviation Mislabeled"*/
EDTATube1_Deviation_MislabelR = "EDTA Tube 1- Deviation Mislabeled Resolved"
EDTATube1_Deviation_NotFound = "EDTA Tube 1- Deviation Not Found"
EDTATube1_Deviation_Other = "EDTA Tube 1- Deviation Other"
EDTATube1_Deviation_OutContam = "EDTA Tube 1- Deviation Outside Contaminated"
EDTATube1_Deviation_TempH = "EDTA Tube 1- Deviation Temperature Too High"
EDTATube1_Deviation_TempL = "EDTA Tube 1- Deviation Temperature Too Low"
EDTATube1_Deviation_TubeSz = "EDTA Tube 1- Deviation Tube Size"
HepTube1_BioBPTL_DateRec_v1r0 = "Heparin Tube 1- Date Received - Site Shipment"
HepTube1_BioCol_Deviation = "Heparin Tube 1- Deviation"
HepTube1_BioCol_DeviationNotes = "Heparin Tube 1- Deviation Details"
HepTube1_BioCol_NotCol = "Heparin Tube 1- Reason Tube Not Collected"
HepTube1_BioCol_NotCollNotes = "Heparin Tube 1- Not Collected Details"
HepTube1_BioCol_Discard = "Heparin Tube 1- Discard Flag"
HepTube1_BioCol_TubeCollected = "Heparin Tube 1- Tube Collected"
HepTube1_BioCol_TubeID = "Heparin Tube 1- Tube ID"
HepTube1_Deviation_Broken = "Heparin Tube 1- Deviation Broken"
HepTube1_Deviation_Discard = "Heparin Tube 1- Deviation Discard"
HepTube1_Deviation_Hemolyzed = "Heparin Tube 1- Deviation Hemolyzed"
HepTube1_Deviation_Leak = "Heparin Tube 1- Deviation Leaked/Spilled"
HepTube1_Deviation_LowVol = "Heparin Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
HepTube1_Deviation_MislabelD = "Heparin Tube 1- Deviation Mislabeled Discard"
/*HepTube1_Deviation_Mislabeled = "Heparin Tube 1- Deviation Mislabeled"*/
HepTube1_Deviation_MislabelR = "Heparin Tube 1- Deviation Mislabeled Resolved"
HepTube1_Deviation_NotFound = "Heparin Tube 1- Deviation Not Found"
HepTube1_Deviation_Other = "Heparin Tube 1- Deviation Other"
HepTube1_Deviation_OutContam = "Heparin Tube 1- Deviation Outside Contaminated"
HepTube1_Deviation_TempH = "Heparin Tube 1- Deviation Temperature Too High"
HepTube1_Deviation_TempL = "Heparin Tube 1- Deviation Temperature Too Low"
HepTube1_Deviation_TubeSz = "Heparin Tube 1- Deviation Tube Size"
MWTube1_BioBPTL_DateRec_v1r0 = "MW Tube 1- Date Received - Site Shipment"
MWTube1_BioCol_Deviation = "MW Tube 1- Deviation"
MWTube1_BioCol_DeviationNotes = "MW Tube 1- Deviation Details"
MWTube1_BioCol_NotCol = "MW Tube 1- Reason Tube Not Collected"
MWTube1_BioCol_NotCollNotes = "Mouthwash Tube 1- Not Collected Details"
MWTube1_BioCol_Discard = "MW Tube 1- Discard Flag"
MWTube1_BioCol_TubeCollected = "MW Tube 1- Tube Collected"
MWTube1_BioCol_TubeID = "MW Tube 1- Tube ID"
MWTube1_Deviation_Broken = "Mouthwash Tube 1- Deviation Broken"
MWTube1_Deviation_Leak = "Mouthwash Tube 1- Deviation Leaked/Spilled"
MWTube1_Deviation_LowVol = "Mouthwash Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
MWTube1_Deviation_MislabelD = "Mouthwash Tube 1- Deviation Mislabeled Discard"
/*MWTube1_Deviation_Mislabeled = "Mouthwash Tube 1- Deviation Mislabeled"*/
MWTube1_Deviation_MislabelR = "Mouthwash Tube 1- Deviation Mislabeled Resolved"
MWTube1_Deviation_MWUnder30s = "Mouthwash Tube 1- Deviation MW < 30s"
MWTube1_Deviation_NotFound = "Mouthwash Tube 1- Deviation Not Found"
MWTube1_Deviation_Other = "Mouthwash Tube 1- Deviation Other"
MWTube1_Deviation_OutContam = "Mouthwash Tube 1- Deviation Outside Contaminated"
RcrtES_Site_v1r0 = "Site"
SSTube1_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 1- Date Received - Site Shipment"
SSTube1_BioCol_Deviation = "Serum Separator Tube 1- Deviation"
SSTube1_BioCol_Discard = "Serum Separator Tube 1- Discard Flag"
SSTube1_BioCol_DeviationNotes = "Serum Separator Tube 1- Deviation Details"
SSTube1_BioCol_NotCol = "Serum Separator Tube 1- Reason Tube Not Collected"
SSTube1_BioCol_NotCollNotes = "Serum Separator Tube 1- Not Collected Details"
SSTube1_BioCol_TubeColl = "Serum Separator Tube 1- Tube Collected"
SSTube1_BioCol_TubeID = "Serum Separator Tube 1- Tube ID"
SSTube1_Deviation_Broken = "Serum Separator Tube 1- Deviation Broken"
SSTube1_Deviation_ClotL = "Serum Separator Tube 1- Deviation Clot > 2h"
SSTube1_Deviation_ClotS = "Serum Separator Tube 1- Deviation Clot < 30min"
SSTube1_Deviation_Discard = "Serum Separator Tube 1- Deviation Discard"
SSTube1_Deviation_Gel = "Serum Separator Tube 1- Deviation Broken Gel"
SSTube1_Deviation_Hemolyzed = "Serum Separator Tube 1- Deviation Hemolyzed"
SSTube1_Deviation_Leak = "Serum Separator Tube 1- Deviation Leaked/Spilled"
SSTube1_Deviation_LowVol = "Serum Separator Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube1_Deviation_MislabelD = "Serum Separator Tube 1- Deviation Mislabeled Discard"
/*SSTube1_Deviation_Mislabeled = "Serum Separator Tube 1- Deviation Mislabeled"*/
SSTube1_Deviation_MislabelR = "Serum Separator Tube 1- Deviation Mislabeled Resolved"
SSTube1_Deviation_NotFound = "Serum Separator Tube 1- Deviation Not Found"
SSTube1_Deviation_Other = "Serum Separator Tube 1- Deviation Other"
SSTube1_Deviation_OutContam = "Serum Separator Tube 1- Deviation Outside Contaminated"
SSTube1_Deviation_SpeedH = "Serum Separator Tube 1- Deviation Cent High"
SSTube1_Deviation_SpeedL = "Serum Separator Tube 1- Deviation Cent Low"
SSTube1_Deviation_TempH = "Serum Separator Tube 1- Deviation Temperature Too High"
SSTube1_Deviation_TempL = "Serum Separator Tube 1- Deviation Temperature Too Low"
SSTube1_Deviation_TimeL = "Serum Separator Tube 1- Deviation Centrifuge Too Long"
SSTube1_Deviation_TimeS = "Serum Separator Tube 1- Deviation Centrifuge Too Short"
SSTube1_Deviation_TubeSz = "Serum Separator Tube 1- Deviation Tube Size"
SSTube2_BioBPTL_DateRec_v1r0 = "Serum Separator Tube 2- Date Received - Site Shipment"
SSTube2_BioCol_Deviation = "Serum Separator Tube 2- Deviation"
SSTube2_BioCol_Discard = "Serum Separator Tube 2- Discard Flag"
SSTube2_BioCol_DeviationNotes = "Serum Separator Tube 2- Deviation Details"
SSTube2_BioCol_NotCol = "Serum Separator Tube 2- Reason Tube Not Collected"
SSTube2_BioCol_NotCollNotes = "Serum Separator Tube 2- Not Collected Details"
SSTube2_BioCol_TubeCollected = "Serum Separator Tube 2- Tube Collected"
SSTube2_BioCol_TubeID = "Serum Separator Tube 2- Tube ID"
SSTube2_Deviation_Broken = "Serum Separator Tube 2- Deviation Broken"
SSTube2_Deviation_ClotL = "Serum Separator Tube 2- Deviation Clot > 2h"
SSTube2_Deviation_ClotS = "Serum Separator Tube 2- Deviation Clot < 30min"
SSTube2_Deviation_Discard = "Serum Separator Tube 2- Deviation Discard"
SSTube2_Deviation_Gel = "Serum Separator Tube 2- Deviation Broken Gel"
SSTube2_Deviation_Hemolyzed = "Serum Separator Tube 2- Deviation Hemolyzed"
SSTube2_Deviation_Leak = "Serum Separator Tube 2- Deviation Leaked/Spilled"
SSTube2_Deviation_LowVol = "Serum Separator Tube 2- Deviation Low Volume-(tube/container partially filled but still usable)"
SSTube2_Deviation_MislabelD = "Serum Separator Tube 2- Deviation Mislabeled Discard"
/*SSTube2_Deviation_Mislabeled = "Serum Separator Tube 2- Deviation Mislabeled"*/
SSTube2_Deviation_MislabelR = "Serum Separator Tube 2- Deviation Mislabeled Resolved"
SSTube2_Deviation_NotFound = "Serum Separator Tube 2- Deviation Not Found"
SSTube2_Deviation_Other = "Serum Separator Tube 2- Deviation Other"
SSTube2_Deviation_OutContam = "Serum Separator Tube 2- Deviation Outside Contaminated"
SSTube2_Deviation_SpeedH = "Serum Separator Tube 2- Deviation Centrifuge Too High"
SSTube2_Deviation_SpeedL = "Serum Separator Tube 2- Deviation Centrifuge Too Low"
SSTube2_Deviation_TempH = "Serum Separator Tube 2- Deviation Temperature Too High"
SSTube2_Deviation_TempL = "Serum Separator Tube 2- Deviation Temperature Too Low"
SSTube2_Deviation_TimeL = "Serum Separator Tube 2- Deviation Centrifuge Too Long"
SSTube2_Deviation_TimeS = "Serum Separator Tube 2- Deviation Centrifuge Too Short"
SSTube2_Deviation_TubeSz = "Serum Separator Tube 2- Deviation Tube Size"
UrineTube1_BioBPTL_DateRec_v1r0 = "Urine Tube 1- Date Received - Site Shipment"
UrineTube1_BioCol_Deviation = "Urine Tube 1- Deviation"
UrineTube1_BioCol_Discard = "Urine Tube 1- Discard Flag"
UrineTube1_BioCol_DeviationNotes = "Urine Tube 1- Deviation Details"
UrineTube1_BioCol_NotCol = "Urine Tube 1- Reason Tube Not Collected"
UrineTube1_BioCol_NotCollNotes = "Urine Tube 1- Not Collected Details"
UrineTube1_BioCol_TubeCollected = "Urine Tube 1- Tube Collected"
UrineTube1_BioCol_TubeID = "Urine Tube 1- Tube ID"
UrineTube1_Deviation_Broken = "Urine Tube 1- Deviation Broken"
UrineTube1_Deviation_Leak = "Urine Tube 1- Deviation Leaked/Spilled"
UrineTube1_Deviation_LowVol = "Urine Tube 1- Deviation Low Volume-(tube/container partially filled but still usable)"
UrineTube1_Deviation_MislabelD = "Urine Tube 1- Deviation Mislabeled Discard"
/*UrineTube1_Deviation_Mislabeled = "Urine Tube 1- Deviation Mislabeled"*/
UrineTube1_Deviation_MislabelR = "Urine Tube 1- Deviation Mislabeled Resolved"
UrineTube1_Deviation_NotFound = "Urine Tube 1- Deviation Not Found"
UrineTube1_Deviation_Other = "Urine Tube 1- Deviation Other"
UrineTube1_Deviation_OutContam = "Urine Tube 1- Deviation Outside Contaminated"
UrineTube1_Deviation_TempH = "Urine Tube 1- Deviation Temperature Too High"
UrineTube1_Deviation_TempL = "Urine Tube 1- Deviation Temperature Too Low"
UrineTube1_Deviation_UrVol = "Urine Tube 1- Deviation Insufficient Volume";

		FORMAT  BioSpm_Visit_v1r0 BioSpmVisitFmt. BioSpm_Location_v1r0 CollectionLocationFmt. RcrtES_Site_v1r0 SiteFmt.
			    BioSpm_ColIDEntered_v1r0 BioSpmColIDEnteredFmt. BioSpm_Setting_v1r0 BioSpmSettingFmt. 
				BioRec_CollectFinal_v1r0 BioRecShipFlagFmt. SSTube1_BioCol_TubeColl BioColTubeCollFmt. 
				SSTube1_BioCol_NotCol BioColRsnNotColFmt. SSTube1_BioCol_Deviation BioColDeviationFmt. 
				SSTube1_BioCol_Discard BioColDiscardFmt. ACDTube1_BioCol_TubeCollected BioColTubeCollFmt. 
				ACDTube1_BioCol_NotCol BioColRsnNotColFmt. ACDTube1_BioCol_Deviation BioColDeviationFmt. 
				ACDTube1_BioCol_Discard BioColDiscardFmt. 
				HepTube1_BioCol_TubeCollected BioColTubeCollFmt. HepTube1_BioCol_NotCol BioColRsnNotColFmt. 
				HepTube1_BioCol_Deviation BioColDeviationFmt. HepTube1_BioCol_Discard BioColDiscardFmt.
				BiohazBlU_BioCol_TubeColl BioColTubeCollFmt. EDTATube1_BioCol_TubeCollected BioColTubeCollFmt.
				EDTATube1_BioCol_NotCol BioColRsnNotColFmt. EDTATube1_BioCol_Deviation BioColDeviationFmt.
				EDTATube1_BioCol_Discard BioColDiscardFmt. BiohazardMW_BioCol_TubeCollected BioColTubeCollFmt.
				MWTube1_BioCol_TubeCollected BioColTubeCollFmt. MWTube1_BioCol_NotCol BioColRsnNotColFmt.
				MWTube1_BioCol_Deviation BioColDeviationFmt. MWTube1_BioCol_Discard BioColDiscardFmt.
				UrineTube1_BioCol_TubeCollected BioColTubeCollFmt. UrineTube1_BioCol_NotCol BioColRsnNotColFmt.
 				UrineTube1_BioCol_Deviation BioColDeviationFmt. UrineTube1_BioCol_Discard BioColDiscardFmt.
 				SSTube2_BioCol_TubeCollected BioColTubeCollFmt. SSTube2_BioCol_NotCol BioColRsnNotColFmt.
				SSTube2_BioCol_Deviation BioColDeviationFmt. SSTube2_BioCol_Discard BioColDiscardFmt.
 				SSTube1_Deviation_Broken DeviationSpecFmt. SSTube1_Deviation_ClotS DeviationSpecFmt.
			    SSTube1_Deviation_ClotL DeviationSpecFmt. SSTube1_Deviation_TimeL DeviationSpecFmt.
			    SSTube1_Deviation_TimeS DeviationSpecFmt. SSTube1_Deviation_Gel DeviationSpecFmt.
			    SSTube1_Deviation_Hemolyzed DeviationSpecFmt. SSTube1_Deviation_TempL DeviationSpecFmt.
			    SSTube1_Deviation_TempH DeviationSpecFmt. SSTube1_Deviation_Leak DeviationSpecFmt.
			    SSTube1_Deviation_LowVol DeviationSpecFmt. /*SSTube1_Deviation_Mislabeled DeviationSpecFmt.*/
			 	SSTube1_Deviation_Other DeviationSpecFmt. ACDTube1_Deviation_Broken DeviationSpecFmt.
			 	ACDTube1_Deviation_NotFound DeviationSpecFmt. ACDTube1_Deviation_TubeSz DeviationSpecFmt.
			    ACDTube1_Deviation_Discard DeviationSpecFmt. ACDTube1_Deviation_MislabelD DeviationSpecFmt.
			    ACDTube1_Deviation_MislabelR DeviationSpecFmt. ACDTube1_Deviation_OutContam DeviationSpecFmt.
			    ACDTube1_Deviation_Hemolyzed DeviationSpecFmt. ACDTube1_Deviation_TempL DeviationSpecFmt.
			    ACDTube1_Deviation_TempH DeviationSpecFmt. ACDTube1_Deviation_Leak DeviationSpecFmt.
			    ACDTube1_Deviation_LowVol DeviationSpecFmt. /*ACDTube1_Deviation_Mislabeled DeviationSpecFmt.*/
			    ACDTube1_Deviation_Other DeviationSpecFmt. HepTube1_Deviation_Broken DeviationSpecFmt.
			    HepTube1_Deviation_NotFound DeviationSpecFmt. HepTube1_Deviation_TubeSz DeviationSpecFmt.
			    HepTube1_Deviation_Discard DeviationSpecFmt. HepTube1_Deviation_MislabelD DeviationSpecFmt.
			    HepTube1_Deviation_MislabelR DeviationSpecFmt. HepTube1_Deviation_OutContam DeviationSpecFmt.
			    HepTube1_Deviation_Hemolyzed DeviationSpecFmt. HepTube1_Deviation_TempL DeviationSpecFmt.
			    HepTube1_Deviation_TempH DeviationSpecFmt. HepTube1_Deviation_Leak DeviationSpecFmt.
			 	HepTube1_Deviation_LowVol DeviationSpecFmt. /*HepTube1_Deviation_Mislabeled DeviationSpecFmt.*/
			 	HepTube1_Deviation_Other DeviationSpecFmt. EDTATube1_Deviation_Broken DeviationSpecFmt. 
				EDTATube1_Deviation_NotFound DeviationSpecFmt. EDTATube1_Deviation_TubeSz DeviationSpecFmt.
			    EDTATube1_Deviation_Discard DeviationSpecFmt. EDTATube1_Deviation_MislabelD DeviationSpecFmt.
			 	EDTATube1_Deviation_MislabelR DeviationSpecFmt. EDTATube1_Deviation_OutContam DeviationSpecFmt.
			 	EDTATube1_Deviation_Hemolyzed DeviationSpecFmt. EDTATube1_Deviation_TempL DeviationSpecFmt.
			 	EDTATube1_Deviation_TempH DeviationSpecFmt. EDTATube1_Deviation_Leak DeviationSpecFmt.
			 	EDTATube1_Deviation_LowVol DeviationSpecFmt. /*EDTATube1_Deviation_Mislabeled DeviationSpecFmt.*/
			 	EDTATube1_Deviation_Other DeviationSpecFmt. MWTube1_Deviation_Broken DeviationSpecFmt.
			 	MWTube1_Deviation_NotFound DeviationSpecFmt. MWTube1_Deviation_MislabelD DeviationSpecFmt.
			 	MWTube1_Deviation_MislabelR DeviationSpecFmt. MWTube1_Deviation_OutContam DeviationSpecFmt.
			 	MWTube1_Deviation_Leak DeviationSpecFmt. MWTube1_Deviation_LowVol DeviationSpecFmt.
				/*MWTube1_Deviation_Mislabeled DeviationSpecFmt.*/ MWTube1_Deviation_Other DeviationSpecFmt.
			 	MWTube1_Deviation_MWUnder30s DeviationSpecFmt. UrineTube1_Deviation_Broken DeviationSpecFmt.
			 	UrineTube1_Deviation_NotFound DeviationSpecFmt. UrineTube1_Deviation_MislabelD DeviationSpecFmt.
				UrineTube1_Deviation_MislabelR DeviationSpecFmt. UrineTube1_Deviation_OutContam DeviationSpecFmt.
			 	UrineTube1_Deviation_TempL DeviationSpecFmt. UrineTube1_Deviation_TempH DeviationSpecFmt.
			 	UrineTube1_Deviation_Leak DeviationSpecFmt. UrineTube1_Deviation_LowVol DeviationSpecFmt.
			 	/*UrineTube1_Deviation_Mislabeled DeviationSpecFmt.*/ UrineTube1_Deviation_Other DeviationSpecFmt.
			 	UrineTube1_Deviation_UrVol DeviationSpecFmt. SSTube2_Deviation_Broken DeviationSpecFmt.
			 	SSTube2_Deviation_ClotS DeviationSpecFmt. SSTube2_Deviation_ClotL DeviationSpecFmt.
			 	SSTube2_Deviation_SpeedH DeviationSpecFmt. SSTube2_Deviation_SpeedL DeviationSpecFmt.
			 	SSTube2_Deviation_TimeL DeviationSpecFmt. SSTube2_Deviation_TimeS DeviationSpecFmt.
			 	SSTube2_Deviation_Gel DeviationSpecFmt. SSTube2_Deviation_Hemolyzed DeviationSpecFmt.
			 	SSTube2_Deviation_TempL DeviationSpecFmt. SSTube2_Deviation_TempH DeviationSpecFmt.
			 	SSTube2_Deviation_Leak DeviationSpecFmt. SSTube2_Deviation_LowVol DeviationSpecFmt.
			 	/*SSTube2_Deviation_Mislabeled DeviationSpecFmt.*/ SSTube2_Deviation_Other DeviationSpecFmt.
				SSTube1_Deviation_Discard DeviationSpecFmt. SSTube2_Deviation_Discard DeviationSpecFmt.
				SSTube1_Deviation_SpeedH DeviationSpecFmt. SSTube1_Deviation_SpeedL DeviationSpecFmt.
				SSTube1_Deviation_MislabelD DeviationSpecFmt. SSTube2_Deviation_MislabelD DeviationSpecFmt.
				SSTube1_Deviation_MislabelR DeviationSpecFmt. SSTube2_Deviation_MislabelR DeviationSpecFmt.
				SSTube1_Deviation_NotFound DeviationSpecFmt. SSTube2_Deviation_NotFound DeviationSpecFmt.
				SSTube1_Deviation_TubeSz DeviationSpecFmt. SSTube2_Deviation_TubeSz DeviationSpecFmt.
				SSTube1_Deviation_OutContam DeviationSpecFmt. SSTube2_Deviation_OutContam DeviationSpecFmt.;
	RUN;
***
NOTE: Variable ACDTube1_BioCol_DeviationNotes is uninitialized.
NOTE: Variable MWTube1_BioCol_DeviationNotes is uninitialized.
NOTE: Variable MWTube1_BioCol_NotCol is uninitialized.
NOTE: Variable MWTube1_BioCol_NotCollNotes is uninitialized.
******;

proc freq data=Concept_IDsBios; table connect_id*BioSpm_Visit_v1r0*BioSpm_Setting_v1r0*RcrtES_Site_v1r0/list missing out=connectID_vist noprint; run;


****all from the baseline (obs=1920)************;
proc export data=Concept_IDsBios outfile="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\Formatted_prod_biospe_flat_08082022.csv"
dbms=csv replace;
run;	
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\Formatted_prod_biospe_flat_080820222.pdf";

proc contents data=Concept_IDsBios varnum; 
title "prod biospecimen flat data 08082022";run;
ods pdf close;

proc sql;
create table merged_recrbio_prod as 
select
a. *, b. * 
from 
concept_ids a /*1134*/
full join
Concept_IDsBios b /*n=73*/
on a. Connect_ID = b. Connectbio_ID
order by b. Connect_ID;
quit;
run;/*n=1385*/
***to save the merged biospecimen and recruitment in bio from prod;
data data.prod_recrbio_merged_08082022;set merged_recrbio_prod; run;

data merged_recrbio_prod; set data.prod_recrbio_merged_08082022;run;
proc sort data=merged_recrbio_prod; by descending connectbio_ID; run;
proc export data=merged_recrbio_prod outfile="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\Prod_merged_recruit_biospeci_formats_08082022.csv"
dbms=csv replace;
run;	
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\Prod_merged_recruit_biospeci_formats_08082022.pdf";

proc contents data=merged_recrbio_prod varnum; 
title "merged biospecimen with recruitment data in prod Connect 08082022";run;
ods pdf close;

data recru_biospec_prod;
set merged_recrbio_prod; 
if connect_id >0 then do;
if BioSpm_Visit_v1r0=266600170 and RcrtV_Verification_v1r0 =197316935 then output;end;
run;/*n=133 baseline*/


options ls=140;
proc freq data=Concept_IDsBios; table BioSpm_Location_v1r0*RcrtES_Site_v1r0/list missing ;run;
***                                                                                                               Cumulative    Cumulative
                            BioSpm_Location_v1r0                   RcrtES_Site_v1r0    Frequency     Percent     Frequency      Percent
             ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
             SF Cancer Center LL                    Sanford Health                            9        8.33             9         8.33
             Marshfield                             Marshfield Clinic Health System          16       14.81            25        23.15
             Lake Hallie                            Marshfield Clinic Health System           5        4.63            30        27.78
             HFHS Research Clinic (Main Campus)     Henry Ford Health System                  2        1.85            32        29.63
             UC-DCAM                                University of Chicago Medicine           16       14.81            48        44.44
             HP Research Clinic                     HealthPartners                           47       43.52            95        87.96
             HFH Cancer Pavilion Research Clinic    Henry Ford Health System                 13       12.04           108       100.00
******;
proc sql;
create table biosbase_tube as
   select Connect_id,RcrtES_Site_v1r0,BioSpm_ColIDScan_v1r0,BioSpm_ColIDEntered_v1r0,BioSpm_Setting_v1r0,BioSpm_Visit_v1r0,
BioCol_ColTime_v1r0,SrvBLM_ResSrvCompl_v1r0, SrvBLM_TmStart_v1r0, SrvBLM_TmComplete_v1r0,BL_BioChk_Time_v1r0,
BL_BioFin_CheckOutTime_v1r0,BioRec_CollectFinalTime_v1r0,BioSpm_Location_v1r0,

	max(SSTube1_BioCol_TubeColl) as SSTube1_TubeColl_yes,
	max(SSTube2_BioCol_TubeCollected) as SSTube2_TubeColl_yes ,
	max(EDTATube1_BioCol_TubeCollected) as EDTATube1_TubeColl_yes ,
	max(HepTube1_BioCol_TubeCollected) as HepTube1_TubeColl_yes ,
	max(ACDTube1_BioCol_TubeCollected) as  ACDTube1_TubeColl_yes,
	max(UrineTube1_BioCol_TubeCollected) as UrineTube1_TubeCollected_yes,
	max(MWTube1_BioCol_TubeCollected) as MWTube1_TubeCollected_yes ,
	max(BiohazBlU_BioCol_TubeColl) as BiohazBlU_TubeColl_yes 
   from recru_biospec_prod /*baseline*/
      group by Connect_id
      order by Connect_id;
quit;
run;/*n=108*/

proc sort data= biosbase_tube ; by BioSpm_Visit_v1r0 BioCol_ColTime_v1r0;
run;	

data biosbase_tube1; set biosbase_tube;
by BioSpm_Visit_v1r0;
if first.BioSpm_Visit_v1r0 then BioCol_Starttime=BioCol_ColTime_v1r0 ;
format BioCol_starttime datetime21.;
retain BioCol_Starttime;
 run;
data biosbase_tube1;
set biosbase_tube1;
wk=1+floor(intck("second",BioCol_Starttime,BioCol_ColTime_v1r0)/(60*60*24*7));
run;

***for all the possible deviations in the biospecimen
****update the shipping time
Name From: BioRec_ShipFlag_v1r0 To: BioRec_CollectFinal_v1r0

CID 556788178
Question Text From: Autogenerated date/time when go to shipping
Question Text To: Autogenerated date/time when collection entry finalized
Label From: Date/Time go to shipping To: Date/Time Collection Entry Finalized
Name From: BioRec_ShipTime_v1r0 To: BioRec_CollectFinalTime_v1r0
****************
Jun.23, as Dominique asked:
the time gap between biospecimen collection time (BioCol_ColTime_v1r0) with survey complete time (SrvBLM_TmComplete_v1r0) by 
day to check participants with biospecimen collection in each site in this table, right?
 
For the average of the visit length as you described “a metric of the visit length (check-out time minus check-in time) in 
minutes, along with a version of this that excludes outliers in case they forget to check someone out until the next day 
it will throw off the average”.
 
I need exclude the outliers as you defined: Outliers: anyone who wasn’t promptly checked out after biospecimen collection till 
the next day,
The averaged visit length would be the difference (min) among the non-outlier group: 
BL_BioFin_CheckOutTime_v1r0 - BL_BioChk_Time_v1r0/ (total N- n of outliers);
********************;

proc format;
	VALUE BioColTubeCompleFmt
			104430631 = "No"
			353358909 = "Complete"
			200000000 = "Partial";
	VALUE BioSpecimenFmt
			104430631 = "No Blood, or Urine or MouthWash Collection"
			353358909 = "Any Collections of Blood, or Urine or MouthWash"; 
proc sort data=biosbase_tube; by connect_id; run;
data biotube_col;
set biosbase_tube;
by connect_id;
if mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes)= 353358909 then BioBld_Complete=353358909;
else if mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes)=104430631 then BioBld_Complete=104430631;
else if 353358909 > mean(SSTube1_TubeColl_yes,SSTube2_TubeColl_yes,EDTATube1_TubeColl_yes,HepTube1_TubeColl_yes,ACDTube1_TubeColl_yes)> 104430631 then BioBld_Complete=200000000;

if last.connect_id=1 then output;
format BioBld_Complete BioColTubeCompleFmt.
SSTube1_TubeColl_yes BioColTubeCollFmt. SSTube2_TubeColl_yes BioColTubeCollFmt. EDTATube1_TubeColl_yes BioColTubeCollFmt. HepTube1_TubeColl_yes BioColTubeCollFmt.
ACDTube1_TubeColl_yes BioColTubeCollFmt. UrineTube1_TubeCollected_yes BioColTubeCollFmt. MWTube1_TubeCollected_yes BioColTubeCollFmt. BiohazBlU_TubeColl_yes BioColTubeCollFmt.;

keep connect_id RcrtES_Site_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 BioCol_ColTime_v1r0 BioRec_CollectFinalTime_v1r0 SSTube1_TubeColl_yes SSTube2_TubeColl_yes EDTATube1_TubeColl_yes 
HepTube1_TubeColl_yes ACDTube1_TubeColl_yes UrineTube1_TubeCollected_yes MWTube1_TubeCollected_yes  BiohazBlU_TubeColl_yes biobld_complete BioSpm_Location_v1r0
SrvBLM_ResSrvCompl_v1r0 SrvBLM_TmStart_v1r0 SrvBLM_TmComplete_v1r0 BL_BioChk_Time_v1r0 BL_BioFin_CheckOutTime_v1r0;
run;
proc format;
value checkdayfmt
0="within 24 hrs"
1="more than 24 hrs less than 48 hrs"
2="more than 2 days"
3="more than 3 days";

data biotube_col1;set biotube_col;
tm_biocolSuv=intck("hour", BioCol_ColTime_v1r0,SrvBLM_TmComplete_v1r0);
time_biochk=intck("minute", BL_BioChk_Time_v1r0,BL_BioFin_CheckOutTime_v1r0);

if time_biochk/60 > 24 then biochk_outlier=1;
else if 0< =time_biochk/60 < = 24 then biochk_outlier=0;

if 0<= abs(tm_biocolSuv) < =24 then checkvisit=0;
else if 48 =>abs(tm_biocolSuv)>24 then checkvisit=1;
else if  72 =>abs(tm_biocolSuv)>48 then checkvisit=2;
else if  abs(tm_biocolSuv)>72 then checkvisit=3;

label tm_biocolSuv="time (hour) between biospecimen collection time with survey completion time" 
time_biochk="visit time by minutes (check-out time minus check-in time)";
attrib checkvisit format=checkdayfmt. label= "time by days from biospecimen collection to Survey completion time";
run;

ods html;
proc sort data=biotube_col; by BioCol_ColTime_v1r0; run;

proc print data=biotube_col1 noobs label;
var connect_id RcrtES_Site_v1r0 BioCol_ColTime_v1r0 BioRec_CollectFinalTime_v1r0 SrvBLM_TmComplete_v1r0 checkvisit; 
run;
proc sort data=merged_recrbio_prod nodupkey out=recrbio dupout=dup;by connect_id token;run;/*nodup*/

proc sql;
create table recru_biotube_prod as 
select
a. *, b. BioBld_Complete, b. UrineTube1_TubeCollected_yes, b. MWTube1_TubeCollected_yes, b. time_biochk, 
b. tm_biocolSuv, checkvisit 
/*b. BioSpm_Visit_v1r0, b. BioSpm_Setting_v1r0, b. BioSpm_Location_v1r0,*/
from 
merged_recrbio_prod a /*838*/
full join
biotube_col1 b /*n=20*/
on a. Connect_ID = b. Connect_ID
order by b. Connect_ID;
quit;
run;/*838, 20 with biospecimen*/

proc freq data=recru_biotube_prod; table BL_BioChk_Complete_v1r0 RcrtES_Site_v1r0 BioSpm_Setting_v1r0 SrvBLM_ResSrvCompl_v1r0/list missing; run;

proc freq data=biotube_col1;
table MWTube1_TubeCollected_yes  BiohazBlU_TubeColl_yes biobld_complete/list missing; 
format BioBld_Complete BioColTubeCompleFmt.;
run;
***                                       MWTube1_
                                            Tube
                                      Collected_                             Cumulative    Cumulative
                                             yes    Frequency     Percent     Frequency      Percent
                                      ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                             Yes           20      100.00             9       100.00


                                         Biohaz
                                           BlU_
                                           Tube                             Cumulative    Cumulative
                                       Coll_yes    Frequency     Percent     Frequency      Percent
                                       ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                            Yes           20      100.00             9       100.00


                                               BioBld_                             Cumulative    Cumulative
                                              Complete    Frequency     Percent     Frequency      Percent
                                          ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                              Partial            1        5.00             1         5.00
                                              Complete          19       95.00            20       100.00
*******;

data bio_settingfmt; 
attrib BioSpm_Setting_v1r0 label = "Collection Setting" format = BioSpmSettingFmt.;
input BioSpm_Setting_v1r0 @@;
cards;
534621077 664882224 103209024
run;
data bio_settingfmt;
length Label $20.;
set bio_settingfmt;
if BioSpm_Setting_v1r0=534621077 then Label="   Research";
if BioSpm_Setting_v1r0=664882224 then Label="   Clinical";
if BioSpm_Setting_v1r0=103209024 then Label="   Home"; run;


data tmp; ;set recru_biotube_prod;
if biobld_complete = . then biobld_complete =104430631;
if UrineTube1_TubeCollected_yes=. then UrineTube1_TubeCollected_yes=104430631;
if MWTube1_TubeCollected_yes=. then MWTube1_TubeCollected_yes=104430631;
if BioFin_BaseBloodCol_v1r0=. then BioFin_BaseBloodCol_v1r0=104430631;
if BioFin_BaseUrineCol_v1r0=. then BioFin_BaseUrineCol_v1r0=104430631;
if BioFin_BaseMouthCol_v1r0=. then BioFin_BaseMouthCol_v1r0=104430631;
if  BioFin_BaseBloodCol_v1r0=BioFin_baseUrineCol_v1r0=BioFin_BaseMouthCol_v1r0=104430631 then BioFin_BaseSpeci_v1r0=104430631;
else BioFin_BaseSpeci_v1r0=353358909;

format biobld_complete BioColTubeCompleFmt. UrineTube1_TubeCollected_yes BioColTubeCollFmt. MWTube1_TubeCollected_yes BioColTubeCollFmt.
BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt. BioFin_BaseUrineCol_v1r0 BioColTubeCollFmt. BioFin_BaseMouthCol_v1r0 BioColTubeCollFmt.
BioFin_BaseSpeci_v1r0 BioSpecimenFmt.;
if BioSpm_Setting_v1r0=664882224 then delete;
if BioSpm_Visit_v1r0=. then BioSpm_Visit_v1r0=266600170;
if connect_id=9122429867 then delete;/*no this connect id in the prod*/
run;/*to remove this connect id from recrutment data*/ /*n=607*/

proc freq data=tmp; table RcrtES_Site_v1r0 BioSpm_Setting_v1r0 BioFin_BaseSpeci_v1r0/list missing; run; 
proc freq data=tmp;
title "Percent (and number) of verified participants Blood, Urine and Mouthwash collected with the baseline participants 07112022";
tables BioFin_baseUrineCol_v1r0*BioFin_baseUrineCol_v1r0 BioFin_BaseMouthCol_v1r0 BioFin_BaseBloodCol_v1r0/list missing out=one;
run;

proc transpose data = one out=t_one prefix=BioFin_BaseBloodCol_v1r0;
id BioFin_BaseBloodCol_v1r0;
run;

filename tab1ctsp '\\Mac\Home\Documents\My SAS Files\9.4\SASmacro\Table1_CTSPedia_local.sas';
%include tab1ctsp ;

filename tab1prt '\\Mac\Home\Documents\My SAS Files\9.4\SASmacro\Table1Print_CTSPedia.sas';
%include tab1prt;

data tmp2;set recru_biotube_prod;
if BioFin_BaseBloodCol_v1r0=. then BioFin_BaseBloodCol_v1r0=104430631;
if BioFin_BaseUrineCol_v1r0=. then BioFin_BaseUrineCol_v1r0=104430631;
if BioFin_BaseMouthCol_v1r0=. then BioFin_BaseMouthCol_v1r0=104430631;
if UrineTube1_TubeCollected_yes=. then UrineTube1_TubeCollected_yes=104430631;
if MWTube1_TubeCollected_yes=. then MWTube1_TubeCollected_yes=104430631;
if Biobld_complete=. then Biobld_complete=104430631;
format BioBld_Complete  BioColTubeCompleFmt. BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt. 
BioFin_BaseUrineCol_v1r0 BioColTubeCollFmt. BioFin_BaseMouthCol_v1r0 BioColTubeCollFmt.
 MWTube1_TubeCollected_yes BioColTubeCollFmt. MWTube1_TubeCollected_yes BioColTubeCollFmt.;
where connect_id>0;
run;
/*Survery baseline biospecimen*/
data tmp3;set tmp2;
if BioSpm_Setting_v1r0= 534621077 then do;
if BioFin_BaseBloodCol_v1r0= 353358909 or BioFin_BaseUrineCol_v1r0=353358909 or  BioFin_BaseMouthCol_v1r0=353358909 then output;
end;
run;/*n=207*/

data bldcompl;set tmp;
if connect_id=connectbio_id and BioFin_BaseBloodCol_v1r0=353358909 then output;
run;/*Table 10. n=20*/
%Table1_CTSPedia(DSName=bldcompl, GroupVar=Biobld_complete,
                  NumVars=,
FreqVars = BioFin_BaseBloodCol_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=Biocmp_blood);

%macro freq_t(var, note, date,condition, format,t);
proc freq data=tmp;
title "Percent (and number) of verified participants with the baseline &note collected from participants of all sites &date";
tables &var /list missing out=&t. noprint;
format &var &format;
where connect_id &condition;
run;

proc transpose data=&t out=t_&t. prefix=&var._;
format &var &format;
id &var.;
idlabal &var.;
run;

data tmp_c; set tmp; 
where connect_id &condition;run;

%Table1_CTSPedia(DSName=tmp_c, GroupVar=&var,
                NumVars=,
FreqVars = RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(RP), Print=Y,Label=L,Out=Biospec_&t.);

%mend;
%freq_t(BioFin_BaseSpeci_v1r0, any biospecimen, 07112022, >0,BioSpecimenFmt.,zero);/*the table is freqcell=N(CP)*/
%freq_t(BioFin_BaseBloodCol_v1r0 , blood, 07112022, >0, BioColTubeCollFmt.,one);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_baseUrineCol_v1r0, Urine, 07112022, >0,BioColTubeCollFmt., two);/*the table is freqcell=N(RP)*/
%freq_t(BioFin_BaseMouthCol_v1r0, Mouthwash, 07112022, >0,BioColTubeCollFmt.,three);/*the table is freqcell=N(RP)*/

/*%freq_t(BioFin_BaseBloodCol_v1r0 , blood of all biospecimen collection, 04042022, =connectbio_id,BioColTubeCollFmt.,four);
%freq_t(BioFin_baseUrineCol_v1r0, Urine of all biospecimen collection, 04042022, =connectbio_id,BioColTubeCollFmt.,five);
%freq_t(BioFin_BaseMouthCol_v1r0, Mouthwash of all biospecimen collection, 04042022, =connectbio_id,BioColTubeCollFmt.,six);*/

%freq_t(BioBld_Complete, complete blood collection of all biospecimen collection, 07112022, =connectbio_id and BioFin_BaseBloodCol_v1r0=353358909,BioColTubeCollFmt.,seven);

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

data t_zero;
set t_zero;
total="838 (100)";
label total "total verified participants";
run;


%macro coll_check(type);
data biospec; set tmp2; where connect_id=connectbio_id ; run;

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
proc contents data=urine varnum; run;


/***deviation***/

proc sort data=recru_biospec_prod;by RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0;
run;

proc freq data=recru_biospec_prod; tables SSTube1_BioCol_Discard	SSTube2_BioCol_Discard	ACDTube1_BioCol_Discard	EDTATube1_BioCol_Discard HepTube1_BioCol_Discard	
MWTube1_BioCol_Discard	UrineTube1_BioCol_Discard
SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation
HepTube1_BioCol_Deviation MWTube1_BioCol_Deviation UrineTube1_BioCol_Deviation
 ACDTube1_BioCol_NotCol 
/list missing;run;

proc format;
value biotubefmt
1= "SSTube1_BioCol_TubeID"
2= "SSTube2_BioCol_TubeID"
3= "ACDTube1_BioCol_TubeID"
4= "EDTATube1_BioCol_TubeID"
5= "HepTube1_BioCol_TubeID"
6=  "MWTube1_BioCol_TubeID"
7= "UrineTube1_BioCol_TubeID";
/*deviation Note is from EDTATube1_BioCol_DeviationNotes
**NotCol only from ACDTube1*/
data deviation_long; length BioTube_type_v1r0 $10.; 
set recru_biospec_prod;

by RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0;
array tubeid {7} SSTube1_BioCol_TubeID SSTube2_BioCol_TubeID ACDTube1_BioCol_TubeID EDTATube1_BioCol_TubeID HepTube1_BioCol_TubeID 
MWTube1_BioCol_TubeID UrineTube1_BioCol_TubeID;

array deviatio {7} SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation
HepTube1_BioCol_Deviation MWTube1_BioCol_Deviation UrineTube1_BioCol_Deviation;
***only EDTA with DeveiationNotes;
array deviNotes {7} $ SSTube1_BioCol_DeviationNotes SSTube2_BioCol_DeviationNotes
ACDTube1_BioCol_DeviationNotes EDTATube1_BioCol_DeviationNotes 
HepTube1_BioCol_DeviationNotes1	MWTube1_BioCol_DeviationNotes UrineTube1_BioCol_DeviationNotes;

array discard {7} SSTube1_BioCol_Discard	SSTube2_BioCol_Discard	ACDTube1_BioCol_Discard	EDTATube1_BioCol_Discard HepTube1_BioCol_Discard	
MWTube1_BioCol_Discard	UrineTube1_BioCol_Discard;
***only ACD with notcollected and Notes;
array notcoll {7} SSTube1_BioCol_NotCol	SSTube2_BioCol_NotCol ACDTube1_BioCol_NotCol EDTATube1_BioCol_NotCol 
HepTube1_BioCol_NotCol MWTube1_BioCol_NotCol UrineTube1_BioCol_NotCol;
array notcoll_Note {7} $ SSTube1_BioCol_NotCollNotes SSTube2_BioCol_NotCollNotes ACDTube1_BioCol_NotCollNotes EDTATube1_Biocol_NotCollNotes HepTube1_BioCol_NotCollNotes 
MWTube1_BioCol_NotCollNotes	UrineTube1_BioCol_NotCollNotes;
do i =1 to 7;
BioCol_TubeID_v1r0=tubeid{i};
BioCol_TubeDeviation_v1r0=deviatio{i};
BioCol_Tube_Discard=discard{i};

BioCol_Tube_DeviationNote=deviNotes{i};
BioCol_Tube_Notcoll=notcoll{i};
BioCol_Tube_notcoll_Notes=notcoll_note{i};

if i >0 and i < 6 then BioTube_type_v1r0 ="Blood";
if i=6 then BioTube_type_v1r0 ="MouthWash";
if i=7 then BioTube_type_v1r0 ="Urine";
BioTube_ID_v1r0=i;
output;
end;
keep RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 connect_id BioSpm_ColIDScan_v1r0 bioTube_type_v1r0 BioTube_ID_v1r0 BioCol_TubeID_v1r0 BioCol_TubeDeviation_v1r0 
BioCol_Tube_DeviationNote BioCol_Tube_Discard BioCol_Tube_Notcoll BioCol_Tube_notcoll_Notes ;
format BioCol_TubeDeviation_v1r0 DeviationSpecFmt. BioCol_Tube_Discard BioColDiscardFmt. 
BioCol_Tube_Notcoll BioColRsnNotColFmt. BioTube_ID_v1r0 biotubefmt.;
run;
ods listing;
ods html close;


proc freq data=deviation_long;
table BioTube_type_v1r0*(BioCol_TubeDeviation_v1r0 BioCol_Tube_Discard BioCol_Tube_Notcoll)/list missing ;
format BioTube_ID_v1r0 biotubefmt.;run;
***
                              BioTube_type_            BioCol_Tube                             Cumulative    Cumulative
                              v1r0                  Deviation_v1r0    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              Blood               No                        98       70.00            98        70.00
                              Blood               Yes                        2        1.43           100        71.43
                              MouthWash           No                        20       14.29           120        85.71
                              Urine               No                        19       13.57           139        99.29
                              Urine               Yes                        1        0.71           140       100.00


                              BioTube_type_           BioCol_Tube_                             Cumulative    Cumulative
                              v1r0                         Discard    Frequency     Percent     Frequency      Percent
                              ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                              Blood               No                       100       71.43           100        71.43
                              MouthWash           No                        20       14.29           120        85.71
                              Urine               No                        20       14.29           140       100.00


                            BioTube_type_                                                         Cumulative    Cumulative
                            v1r0                  BioCol_Tube_Notcoll    Frequency     Percent     Frequency      Percent
                            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                            Blood                                   .          99       70.71            99        70.71
                            Blood               Short draw                      1        0.71           100        71.43
                            MouthWash                               .          20       14.29           120        85.71
                            Urine                                   .          19       13.57           139        99.29
                            Urine               Participant attempted           1        0.71           140       100.00
*******;

proc freq data=deviation_long;
table BioTube_ID_v1r0*(BioCol_TubeDeviation_v1r0 BioCol_Tube_Discard BioCol_Tube_Notcoll)/list missing ;
format BioTube_ID_v1r0 biotubefmt.;run;
/*for the deviation tubes*/
data dev; set deviation_long; where BioCol_TubeID_v1r0^=" " and BioCol_TubeDeviation_v1r0=353358909; run;/*n=5*/
%Table1_CTSPedia(DSName=dev, GroupVar= BioTube_type_v1r0 ,NumVars=,
                FreqVars =/*BioCol_TubeDeviation_v1r0*/ RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, 
FreqCell=N(CP), Print=Y,Label=L,Out=Biodev);
%Table1_CTSPedia(DSName=deviation_long, GroupVar= BioTube_ID_v1r0 ,NumVars=,
                FreqVars =BioCol_TubeDeviation_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, 
FreqCell=N(CP), Print=Y,Label=L,Out=Biodev1);

data dev1; set deviation_long; where BioCol_TubeID_v1r0^=" " and BioCol_Tube_Discard=353358909; run;/*n=0*/
%Table1_CTSPedia(DSName=dev1, GroupVar=BioTube_type_v1r0, NumVars=,
           FreqVars =BioCol_Tube_Discard RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(CP), 
Print=Y,Label=L,Out=Biodiscard);
data nocoll;set deviation_long; where BioCol_TubeID_v1r0=" "; run;/*n=1*/
%Table1_CTSPedia(DSName=nocoll, GroupVar=BioCol_Tube_Notcoll, NumVars=,
           FreqVars =BioTube_ID_v1r0 RcrtES_Site_v1r0 ,Mean=Y,Median=N,Total=C,Missing=Y,P=N, FreqCell=N(CP), 
Print=Y,Label=L,Out=BioNotColl);


proc freq data=nocoll;table BioCol_Tube_Notcoll*(BioTube_ID_v1r0 RcrtES_Site_v1r0)/list missing; run;
 ***                                                                                                      Cumulative    Cumulative
                          BioCol_Tube_Notcoll             BioTube_ID_v1r0    Frequency     Percent     Frequency      Percent
                        ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                        Short draw               ACDTube1_BioCol_TubeID             1       50.00             1        50.00
                        Participant attempted    UrineTube1_BioCol_TubeID           1       50.00             2       100.00


                                                                                                         Cumulative    Cumulative
                      BioCol_Tube_Notcoll                   RcrtES_Site_v1r0    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                    Short draw               HealthPartners                            1       50.00             1        50.00
                    Participant attempted    University of Chicago Medicine            1       50.00             2       100.00
*******;
data tmp4;set recru_biospec_prod;run;
proc sort data=tmp4;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0
BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation MWTube1_BioCol_Deviation;run;
proc transpose data=tmp4 out=Tubes_deviation prefix=Tubetype;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0
BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation MWTube1_BioCol_Deviation;
var SSTube1_BioCol_TubeID SSTube2_BioCol_TubeID ACDTube1_BioCol_TubeID EDTATube1_BioCol_TubeID HepTube1_BioCol_TubeID MWTube1_BioCol_TubeID UrineTube1_BioCol_TubeID;
run;
data Tubes_deviation1;
set Tubes_deviation;
rename _Name_ = Type_BioCol_TubeID;
drop _label_; 
run;/*n=140*/


proc sort data=tmp4;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;run;
proc transpose data=tmp4 out=Tubes_NotCollected prefix=NotCollection;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;
var ACDTube1_BioCol_NotCol /* SSTube2_BioCol_NotColl EDTATube1_BioCol_NotCol HepTube1_BioCol_NotCol UrineTube1_BioCol_NotCol 
MWTube1_BioCol_NotCol*/;
run;
data Tubes_NotCollected;set Tubes_NotCollected;
rename _Name_= BioTube_NotCol_Type;
run;

proc transpose data=tmp4 out=Notes_NotCollected prefix=NotColl_notes;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;
var ACDTube1_BioCol_NotCollNotes /*SSTube1_BioCol_NotCollNotes SSTube2_BioCol_NotCollNotes EDTATube1_Biocol_NotCollNotes HepTube1_BioCol_NotCollNotes 
MWTube1_BioCol_NotCollNotes	UrineTube1_BioCol_NotCollNotes*/;
run;

proc sort data=Tubes_NotCollected; by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation MWTube1_BioCol_Deviation;run;

proc sort data=Notes_NotCollected;
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation;run;

data Tubes_NotColl_NotColNotes;merge Tubes_NotCollected (in =a) Notes_NotCollected (in=b);
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation; if a=b; 
format NotCollection1 BioColRsnNotColFmt.;run;

data tubeID_NotColl_NotColNotes; merge Tubes_deviation1 (in=a) Tubes_NotColl_NotColNotes (in=b);
by Connect_id BioSpm_ColIDScan_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 BioSpm_Setting_v1r0 BioSpm_Visit_v1r0 SSTube1_BioCol_Deviation SSTube2_BioCol_Deviation ACDTube1_BioCol_Deviation EDTATube1_BioCol_Deviation 
HepTube1_BioCol_Deviation	UrineTube1_BioCol_Deviation	MWTube1_BioCol_Deviation; if a=b; 
run;

data NotColl_shortdraw; set tubeID_NotColl_NotColNotes;
if tubetype1=" " then NotCollNote=1;
else NotCollNote=0;
label tubetype1="Not Collected=Short draw";
run;
proc freq data=NotColl_shortdraw ; table BioSpm_Setting_v1r0*Type_BioCol_TubeID*RcrtES_Site_v1r0*BioSpm_Location_v1r0 /list missing out=short_ID; 
where NotCollNote=0;
run;

proc sort data=short_id; by  BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0;run;
proc transpose data=short_id out=shortdraw suffix=Coll;
by BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0;
id Type_BioCol_TubeID;
var count; /*SSTube1_BioCol_NotCollNotes SSTube2_BioCol_NotCollNotes EDTATube1_Biocol_NotCollNotes HepTube1_BioCol_NotCollNotes 
MWTube1_BioCol_NotCollNotes	UrineTube1_BioCol_NotCollNotes*/
run;
proc contents data=shortdraw; run;
***                    #    Variable                        Type    Len    Format      Informat    Label

                    4    ACDTube1_BioCol_TubeIDColl      Num       8
                    5    EDTATube1_BioCol_TubeIDColl     Num       8
                    6    HepTube1_BioCol_TubeIDColl      Num       8
                    7    MWTube1_BioCol_TubeIDColl       Num       8
                    1    RcrtES_Site_v1r0                Num       8    SITEFMT.    BEST9.      Site
                    8    SSTube1_BioCol_TubeIDColl       Num       8
                    9    SSTube2_BioCol_TubeIDColl       Num       8
                   10    UrineTube1_BioCol_TubeIDColl    Num       8
                    3    _LABEL_                         Char     40                            LABEL OF FORMER VARIABLE
                    2    _NAME_                          Char      8                            NAME OF FORMER VARIABLE
******;
proc sort data=shortdraw; by  BioSpm_Setting_v1r0 BioSpm_Location_v1r0 RcrtES_Site_v1r0;run;
data shortdraw1;
set shortdraw;
by  BioSpm_Setting_v1r0 BioSpm_Location_v1r0;
total=SSTube1_BioCol_TubeIDColl;
array col {7} SSTube1_BioCol_TubeIDColl SSTube2_BioCol_TubeIDColl ACDTube1_BioCol_TubeIDColl EDTATube1_BioCol_TubeIDColl
HepTube1_BioCol_TubeIDColl MWTube1_BioCol_TubeIDColl UrineTube1_BioCol_TubeIDColl;

array notcol {7} SST1 SST2 ACD EDTA Heparin Mouthwash Urine;
do i=1 to 7;
notcol{i}=total-col{i};
end;
label SST1="SSTube1_BioCol_NotCol"  SST2="SSTube2_BioCol_NotCol"
Heparin="HepTube1_BioCol_NotCol" EDTA="EDTATube1_BioCol_NotCol"
ACD="ACDTube1_BioCol_NotCol" Urine="UrineTube1_BioCol_NotCol" Mouthwash="MWTube1_BioCol_NotCol"
total="Total Not Collected ";run;
proc print data=shortdraw1 noobs label;
var BioSpm_Setting_v1r0 RcrtES_Site_v1r0 BioSpm_Location_v1r0 SST1 SST2 ACD EDTA Heparin Mouthwash Urine total;run;



****May 25, 2022, here are the comments from Michelle on the updated metrics below****
Table 2: Please shorten column headers so the columns can be viewed side by side on the page
Tables 4, 6, 8: We need the row percent rather than the column percent
Check all of the titles to fix the spelling of ?ablr·and make Participants plural with an s
Pie chart called Table 11:, the title is wrong. Please look at the other document with Nicole and my comments for the correct title
We don? need the other table 11, table 12 or table 13A (settings for sample collections separately for blood, urine, mouthwash- please delete
Table 13b: Fix the spelling of urine in the title
Table 14: It? not clear to me how to interpret this. Does the 8 on the first row mean 8 people checked in for a baseline visit and did not give any blood?  The way you have Table 15 is clearer. Can you make table 14 look like table 15 but the header in the first column would just be ?ny blood collected·which would = no
Table 14: Needs ?aseline·before ?heck-ins·in title and needs ?ll sites·in title
Table 15: Needs all sites in title
Table 16: Need to add the total number of tubes of each type collected and the percentage needs to be out of the total number of tubes collected of the type, not the percents you have now
Table 17: same comments as Table 16
*****************;

/*ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_06242022.pdf";*/
ods pdf file="\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_metrics_baseline_participants_Prod_07112022_v2.pdf";

ods gridded column=6;
/*proc print data=zero noobs;var BioFin_BaseSpeci_v1r0 N_percent total;
title "Table 1. Percent (N) of verified participants with any baseline biospecimen collections of all sites 06172022";
run;
proc print data=one noobs; 
title "Table 3. Percent (and number) of verified participants of all sites with the baseline Blood collected 06172022";
run;
proc print data=two noobs; 
title "Table 5. Percent (and number) of verified participants of all sites with the baseline Urine collected 06172022";
run;
proc print data=three noobs; 
title "Table 7. Percent (and number) of verified participants of all sites with the baseline MouthWash collected 06172022";
run;*/


proc print data=biospec_zero noobs label;
title "Table 1. Percent (N) of verified participants with any baseline biospecimen collections by site 06242022";
var label GroupVal1 GroupVal2 total;run;

title "Table 2. Percent (and number) of verified participants with the baseline Blood collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_one, Space=Y);

title "Table 3. Percent (and number) of verified participants with the baseline Urine collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_two, Space=Y);


title "Table 4. Percent (and number) of verified participants with the baseline MouthWash collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_three, Space=Y);


proc freq data=tmp;
title "Table 5. Percent (and number) of verified participants with baseline Blood, Urine and Mouthwash collections all sites 06242022";
tables BioFin_BaseBloodCol_v1r0*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list cumcol missing out=threebio;
/*where connect_id=connectbio_id;*/
run;

/*proc freq data=tmp;
tables  BioFin_BaseBloodCol_v1r0*BioBld_Complete /list missing out=bldcomplete;
where BioFin_BaseBloodCol_v1r0=353358909;
run;*/
title "Table 6. Percent (N) of verified participants with all the blood tubes collected all sites 0624202";
%Table1Print_CTSPedia(DSname=Biocmp_blood, Space=Y);

title "Table 7. Percent (N) of verified participants with all the blood tubes collected by site 06242022";
%Table1Print_CTSPedia(DSname=Biospec_seven, Space=Y);

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
data eight;
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


PROC TEMPLATE;
   DEFINE STATGRAPH pie;
      BEGINGRAPH;
         LAYOUT REGION;
            PIECHART CATEGORY = BioCollections_v1r0 /
  		    
            DATALABELLOCATION = outSIDE
            DATALABELCONTENT = ALL
			CATEGORYDIRECTION = CLOCKWISE
			DATASKIN = SHEEN
            START = 180 NAME = 'pie';
            DISCRETELEGEND 'pie' /
            TITLE = 'Biospecimen Types';
         ENDLAYOUT;
      ENDGRAPH;
   END;
RUN;

PROC SGRENDER DATA = eight
            TEMPLATE = pie;
FORMAT BioCollections_v1r0 typeyesnofmt.;
where connect_id=connectbio_id;
title "Percent (and number) of verified participants with baseline Blood, Urine and Mouthwash collections 06242022";
RUN;

/*proc freq data=eight; table BioCollections_v1r0/list;run;*/

/*proc freq data=tmp;
title "Percent (and number) of verified participants Blood, Urine and Mouthwash complete collection among baseline biospeciment collections 04042022";
tables  BioBld_Complete*BioFin_baseUrineCol_v1r0*BioFin_BaseMouthCol_v1r0/list missing;
where connect_id=connectbio_id;
run;*UrineTube1_TubeCollected_yes*MWTube1_TubeCollected_yes*/
/*title "Table 11. Frequency of Blood collected by setting of all sites 04072022"; proc print data=Blood1 label; var Label Blood_Val2; 
run;
title "Table 12. Frequency of Urine collected by setting of all sites 04072022"; proc print data=Urine1 label;var Label Urine_Val2; run;
title "Table 13.A Frequency of MouthWash collected by setting all sites 04072022"; proc print data=mouth1 Label; var Label Mouth_Val2;run;
*/

proc sort data=blood1; by label; run;
proc sort data=urine1; by label; run;
proc sort data=mouth1; by label; run;

data biospe_two;merge blood1 (in=a) urine1;
by label;run;

data biospe_all;merge biospe_two (in=a) mouth1;
by label;run;

data biospe_all;set biospe_all;
Label blood_Val1="Blood collected yes/(N=9)"
  Urine_Val1="Urine collected yes/(N=9)"
	Mouth_Val1="MouthWash collected yes/(N=9)";
run;
proc print data=Biospe_all Label; 
title "Table 8 Frequency of Blood, Urine, MouthWash collected by setting all sites 06242022";
var Label Blood_Val1 Urine_Val1 Mouth_Val1;
run;

***the blood collection with baseline check in;
 data bloodcollect;set tmp2;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
run;

proc freq data=tmp2;
table BioSpm_Visit_v1r0*BioFin_BaseBloodCol_v1r0 /out=FreqCount cumcol TOTPCT OUTPCT list noprint;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format BioFin_BaseBloodCol_v1r0 BioColTubeCollFmt.;
run;

proc sort data=freqcount; by BioSpm_Visit_v1r0 BioFin_BaseBloodCol_v1r0;run;
data freqcount_w;length N_percent $16.; set freqcount;
by BioSpm_Visit_v1r0;
total=count*100/percent; 
N_percent=put(count, 4.2)||" ("||put(percent,4.2)||")";
if first.BioSpm_Visit_v1r0=1 and BioFin_BaseBloodCol_v1r0 =104430631 then do;
BioFin_BaseBloodCol_v1r0_Yes=lag(N_percent); BioFin_BaseBloodCol_v1r0_No=N_percent;
if last.BioSpm_Visit_v1r0=1 then output;end;
if first.BioSpm_Visit_v1r0=1 and BioFin_BaseBloodCol_v1r0 ^=104430631 then do;
BioFin_BaseBloodCol_v1r0_Yes=N_percent; BioFin_BaseBloodCol_v1r0_No="0(0)";
if last.BioSpm_Visit_v1r0=1 then output;end;

run;

proc print data=freqcount_w noobs split='_' noobs;
title "Table 9. Number (%) of Baseline check-ins with blood not collected at all sites at 06242022";
var BioSpm_Visit_v1r0 BioFin_BaseBloodCol_v1r0_Yes BioFin_BaseBloodCol_v1r0_No total;
run;

data checkin;set eight;
if BioCollections_v1r0=0 then Bio_BLBUM_collected_v1r0=104430631;
else Bio_BLBUM_collected_v1r0=353358909;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
attrib Bio_BLBUM_collected_v1r0 format=BioColTubeCollFmt. 
label="any blood, urine or MW samples of any type collected at baseline check-in"; 
run;

proc freq data=checkin;
table BioSpm_Visit_v1r0*Bio_BLBUM_collected_v1r0 /cumcol list noprint out=bloodincomple;
where BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170;
format Bio_BLBUM_collected_v1r0 BioColTubeCollFmt.;
run;

data bloodincomple;set bloodincomple; 
BL_BioChk_total_v1r0=100*count/percent;
freq2=0;
label BL_BioChk_total_v1r0="total number of the baseline checkin"
count="# any blood, urine or MW samples of any type collected at baseline check-in";
run;
proc print data=bloodincomple label noobs split='/' ;
title "Table 10. Number of Baseline check-ins with no samples collected/Number of check-ins at all sites at 06242022";
var Bio_BLBUM_collected_v1r0 count BL_BioChk_total_v1r0 percent;
format Bio_BLBUM_collected_v1r0 BioColTubeCollFmt.;
/*where Bio_BLBUM_collected_v1r0=104430631;*/
run;

/*Deviation*/
proc freq data=deviation_long data=formatted;
table BioTube_type_v1r0*BioCol_TubeDeviation_v1r0
/noprint out=tmp_freq1 cumcol TOTPCT OUTPCT  list missing ;where BioCol_TubeID_v1r0^=" ";run; 

data tmp_freq1; set tmp_freq1; total_N= 100*count/pct_row; N_percent=put(count, 4.0)||" ("||put(pct_row,4.2)||")";
run;
proc sort data=tmp_freq1;by BioCol_TubeDeviation_v1r0; run;
proc transpose data=tmp_freq1 out = tube_devia prefix=BioTube_type_v1r0_;
by BioCol_TubeDeviation_v1r0;
var N_percent;
id BioTube_type_v1r0;
idlabel BioTube_type_v1r0;
run;
data tube_devia1;set tube_devia; if BioCol_TubeDeviation_v1r0 =353358909 and substr(BioTube_type_v1r0_urine,1,1) ^= "(" 
then BioTube_type_v1r0_urine ="  0";
if BioCol_TubeDeviation_v1r0 =353358909 and substr(BioTube_type_v1r0_MouthWash,1,1) ^= "(" 
then BioTube_type_v1r0_MouthWash ="  0";run;
proc print data=tube_devia1 label noobs;
title "Table 11. Number (%) of Tubes with any Deviations of all Sites at 06242022";
var BioCol_TubeDeviation_v1r0 BioTube_type_v1r0_blood BioTube_type_v1r0_urine BioTube_type_v1r0_mouthwash;
where  BioCol_TubeDeviation_v1r0=353358909;
run;

title "Table 12. Number of Tubes with any deviation by site at 06242022"; %Table1Print_CTSPedia(DSname=Biodev, Space=Y);
/*%Table1Print_CTSPedia(DSname=Biodev1, Space=Y); not in version 2 (V2) which will be sent to Michelle";

title "Table 16. No any Discarded Tubes by site at 06172022"; /*%Table1Print_CTSPedia(DSname=Biodiscard, Space=Y);*/
/*title "Table 17. Counts of any Reason Not Collected by Tube Types of all Site"; %Table1Print_CTSPedia(DSname=BioNotColl, Space=Y);
ods listing;
proc print data=BioNotColl heading=h split='=' noobs label width=min;
title "Table 17. Counts of any Reason Not Collected by Tube Types of all Site";
var label GroupVal1 GroupVal2  GroupVal3 GroupVal4 Total;
run; 
ods pdf file= "\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs\biospecimen_table17.pdf" ;
*/
proc freq data=BioNotColl; table label/list missing; run;
data BioNotColl_1; 
length GroupVal2 $8. GroupVal3 $8. GroupVal4 $8. ;set BioNotColl;
if trim(left(label))in ("ACDTube1_BioCol_TubeID","HealthPartners") then do;
GroupVal2="0"; GroupVal3="0";  GroupVal4="0";
end;
run; 

proc report data=BioNotColl_1 split='/' nowd;
title "Table 13. Counts of any Reason Not Collected by Tube Types of all Site at 06242022";
columns label GroupVal1 GroupVal2  GroupVal3 GroupVal4 Total;
define label / width=25 left;
define GroupVal1 /"Tube Not Collected = Short draw/(N=1)" center width= 20;
define GroupVal2 /"Tube Not Collected = Other/(N=0)" center width= 20;
define GroupVal3 /"Tube Not Collected = Participants Refusal/(N=0)" center width= 20;
define GroupVal4 /"Tube Not Collected = Participants Attempted/(N=0)" center width= 20;
define Total /"Total Tube Not COllected" center width=10;
run; 
/*ods pdf close;
for the deviation tubes*/

proc freq data=tubeID_NotColl_NotColNotes;
title "Table 14. Tube Types of NotCollected by Specimen Setting and Locations at 06242022"; 
tables BioSpm_Setting_v1r0*BioSpm_Location_v1r0*BioTube_NotCol_Type/list missing;
where Tubetype1 =" " and NotCollection1>0;
run;
proc print data=shortdraw1 noobs label;
title "Table 15. Tube Types of NotCollected by Specimen Setting and Locations at 06242022";
var RcrtES_Site_v1r0 SST1
SST2 ACD EDTA Heparin Mouthwash Urine total;run;
/*basline Biospecimen Survey*/
proc freq data=tmp3; 
title "Table 16. N(%) of time between the biospecimen survey and biospecimen collection by day at 06242022";
table checkvisit/list missing; run;


proc means data=Biotube_col1 n nmiss mean std maxdec=2;
title "Table 17. the average time by minutes of biospecimen visit time between check-in and check-out";
var time_biochk;
class biochk_outlier;
run;

/*basline Biospecimen Survey*/
proc freq data=tmp3; 
title "Table 18. N(%) of baseline biospecimen survey submission from baseline Research Collections";
table SrvBLM_ResSrvCompl_v1r0/list missing; run;
ods pdf close;

***requested from Nicole on Jun. 27, 2022 for the biospecimen invitation;
data hp_id; set data.concept_ids_mn;
if RcrtES_Site_v1r0 = 531629870 and
RcrtV_Verification_v1r0 = 197316935 and
HdRef_Baseblood_v1r0 = 104430631 and
HdRef_Baseurine_v1r0 = 104430631 and
HdRef_Basesaliva_v1r0 = 104430631 and
HdWd_Activepart_v1r0 = 104430631 and
HdWd_HIPAArevoked_v1r0 = 104430631 and
HdWd_WdConsent_v1r0 = 104430631  then output;
run;

proc sql;
create table hp_id_bio as
select 
a. Connect_id, a. RcrtES_Site_v1r0, b. RcrtV_Verification_v1r0, a. HdRef_Baseblood_v1r0, a. HdRef_Baseurine_v1r0, a. HdRef_Basesaliva_v1r0, 
a. HdWd_Activepart_v1r0, a. HdWd_HIPAArevoked_v1r0, a. HdWd_WdConsent_v1r0, b. BioFin_BaseBloodCol_v1r0, b. BioFin_BaseUrineCol_v1r0, 
b. BioFin_BaseMouthCol_v1r0
from 
hp_id a
left join 
merged_recrbio_prod b
on a. connect_id =b. connect_id
order by a. connect_id;
quit;
run;
%let outpath=\\Mac\Home\Documents\CONNECT_projects\Biospecimen_Feb2022\Jing_projects\biospecQC_03082022\SASoutputs;

proc export data=hp_id_bio outfile="&path.\HP_connectID_biospecimen_scheduling_invitatio_06242022.csv" dbms=csv replace; run;

ods html;
