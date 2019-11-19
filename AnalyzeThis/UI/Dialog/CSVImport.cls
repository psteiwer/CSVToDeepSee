/// Created using the page template: Default
Class AnalyzeThis.UI.Dialog.CSVImport Extends %ZEN.Dialog.standardDialog [ System = 4 ]
{
Parameter DOMAIN = "AnalyzeThis";

Parameter Version = 1;

Property INPUTTYPE As %ZEN.Datatype.string(ZENURL = "INPUTTYPE");

/// This is the temporary file name we saved on remote server, only saved when Input Type is LOCAL.
Property LOCALFILENAME As %ZEN.Datatype.string;

Property LineSize As %Integer [ InitialExpression = 10000 ];

Property hasHeaders As %ZEN.Datatype.string [ InitialExpression = 1 ];

Property Source As %String;

Property SourceClass As %String;

Property CubeName As %String;

Property propertyJSONStreamID As %ZEN.Datatype.string;

Property dataJSONStreamID As %ZEN.Datatype.string;

Property SourceType As %String;

/// Id used to track progress.
Property trackingId As %ZEN.Datatype.string;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
#htmlContent {
	width: 100%;	
}
/* Progress message style */
.progress { 
	color: green; 
	font-weight: bold;
}
/* style for title instructions */
div.Description	{
	font-size: 0.9em; 
	padding: 5px;
}
table.page {
	table-layout:fixed;	
}
/* style for import content table */
table.ContentTable	{ 
	font-family: Arial, Helvetica, sans-serif;
	border: 1px #888888 solid;
}
table.ContentTable th { 
	font-size: 12px;
	font-weight: bold;		
	background:white; 
	color: #888888;
	text-align: center;
	padding: 0 2px 0 2px;
}
table.ContentTable tr.LiteRow { background: white; font-size: 11px;}
table.ContentTable tr.DarkRow { background: #F1F0E7; font-size: 11px;}
table.ContentTable td { padding-left:2px; padding-right:2px; font-size: 11px; }
</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen"
	title="#(%page.dialogTitle)#" >
<html id="header" OnDrawContent="%DrawTitle" />
<form enctype="multipart/form-data" action="AnalyzeThis.UI.Dialog.CSVImport.zen">
<pane paneName="dialogBody" id="body"/>
<hgroup id="footer" width="99%" cellAlign="right">
<hgroup id="buttonHolder" cellAlign="right">
<button id="btnBack" controlClass="commandButtonDisabled" caption="Back" onclick="zenPage.previousPage();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnGoDash" controlClass="commandButtonDisabled" caption="Sample Dashboard" onclick="zenPage.seeDash();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnScoreDash" controlClass="commandButtonDisabled" caption="Sample ScoreCard" onclick="zenPage.seeScoreCard();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnGoStats" controlClass="commandButtonDisabled" caption="Cube Statistics" onclick="zenPage.nextPage();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnDone" controlClass="commandButton" caption="Done" onclick="zenPage.firePopupAction('okay','hi');" hidden="true" />
<button id="btnNext" controlClass="commandButtonDisabled" caption="Next" onclick="zenPage.nextPage();" disabled="true"/>
<submit id="btnSubmit" controlClass="commandButtonDisabled" caption="Next" hidden="true" disabled="true"/>
<button id="btnFinish" controlClass="commandButtonDisabled" caption="Import" onclick="zenPage.doImportJSON();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnCancel" controlClass="commandButton" caption="Cancel" onclick="zenPage.dialogCancel();" />
</hgroup>
</hgroup>
</form>
</page>
}

/// This XML block defines the contents of this pane.
XData dialogBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane id="body" cellStyle="padding-left:10px;">
<label id="idRespond" enclosingClass="note" controlStyle="color:red;" containerStyle="padding-top:10px;padding-left:4px;" hidden="true"/>
<tabGroup id="tabGroup">

<!-- First Page -->
<tab id="tab1" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
 <html OnDrawContent="DrawPageTitle" seed="1"/>
 
 <hgroup>
 <radioSet id="SourceType" name="SourceType" label="Source Type" valueList="CSV,Class,SQL" value="CSV" onclick="zenPage.SwitchSourceType();"/>
 </hgroup>
 
 <group id="SourceCSV" hidden="false">
 <radioSet id="InputType" name="InputType" label="The import file resides on" valueList="REMOTE,LOCAL" 
 onclick="zenPage.doLocationChange(zenThis.getValue());" value="REMOTE"/>
 
 <hgroup id="idInstructions" cellVAlign="bottom" enclosingStyle="padding-top:10px;">
<label id="Instructions" value="Please ensure the CSV file name starts with a letter"/>
</hgroup>
<hgroup id="idRemoteFile" cellVAlign="bottom" enclosingStyle="padding-top:20px;" >
<text id="FileName" size="70" label="Enter the path and name of the import file:" onchange="zenPage.UpdateSource(zenThis.getValue()); zenPage.updateState();"/>
<button caption="Browse..." containerStyle="padding-left:2px;" onclick="zenPage.browseSelect('FileName');"/>
</hgroup>
<fileUpload id="LocalFile" name="LocalFile" label="Select the path and name of the import file:" size="70" hidden="true" onchange="zenPage.UpdateLocalFile(zenThis.getValue());"/>

<checkbox id="chkHeaders" caption="This file has a header row" value="1" onchange="zenPage.UpdateHasHeaders(zenThis.getValue());" captionClass="zenLabel" hint=" (Check box to autmatically assign property names.)"/>
<checkbox id="chkRecurse" caption="Include subdirectories" captionClass="zenLabel" value="1" hidden="true"/>
</group>

<group id="SourceSQL" hidden="true">
<textarea id="SQLText" rows="4" cols="53" label="Enter Source SQL query" onchange="zenPage.UpdateSource(zenThis.getValue()); zenPage.updateState();"></textarea>
</group>

<group id="SourceClass" hidden="true">
<hgroup id="cubeProp" valign="top">
<text id="sourceClass" label="Source Class" size="70" required="false" hint="Required. This class must already exist." onchange="zenPage.UpdateSource(zenThis.getValue()); zenPage.updateState();"/>
<button caption="Browse..." onclick="zenPage.browseClass('sourceClass');" />
</hgroup>
</group>

<vgroup enclosingStyle="padding-top:10px;">
<label id="ChangeNameLabel" value="Change the name of the cube"/>
<hgroup>
<text id="CubeName" name="CubeName" size="70" label="CubeName" value="#(%page.CubeName)#" onchange="zenPage.UpdateCubeName(zenThis.getValue());"/>
</hgroup>
</vgroup>

<expando caption="Advanced" animate="true" expanded="false">
<vgroup enclosingStyle="padding-top:10px;">
<label id="LimitLabel" value="Limit the amount of data to read" hint="(Data load will stop after limit is reached)"/>
<hgroup>
<text id="LineSize" name="LineSize" value="10000" size="15" label="Line Limit" onchange="zenPage.UpdateLineSize(zenThis.getValue());"/>
</hgroup>
</vgroup>
</expando>
</tab>

<!-- Second Page -->
<tab id="tab2" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
<group>
<html OnDrawContent="DrawSortPageTitle" seed="2"/>
<html id="htmlContent" OnDrawContent="PropertyCheckJSON" seed="" onrefresh="zenPage.drawDone(2);"/>
<label id="idProgress2" label="Loading File Content..." labelClass="progress"/>
</group>
</tab>

<!-- Third Page -->
<tab id="tab3" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
<html OnDrawContent="DrawPageTitle" seed="3"/>
<html id="htmlContent3" onrefresh="zenPage.updateProgress();"/>
<timer id="timer" ontimeout="zenPage.updateStatus();"/>
</tab>

<!-- Fourth Page -->
<tab id="tab4" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
<html OnDrawContent="DrawPageTitle" seed="4"/>
<html id="htmlContent4" onrefresh="zenPage.drawStats();"/>
<vgroup>
<html id="statsTable"/>
</vgroup>
</tab>
</tabGroup>
</pane>
}

/// Update the LineSize property
Method UpdateLineSize(value) [ Internal, ZenMethod ]
{
	Set ..LineSize=value
}

/// Update the hasHeaders property
Method UpdateHasHeaders(value) [ Internal, ZenMethod ]
{
	Set ..hasHeaders=value
}

/// Update the Source property
Method UpdateSource(value) [ Internal, ZenMethod ]
{
	Set ..Source=value
	Do ..GenerateCubeName()
}

/// Update the LOCALFILENAME property
Method UpdateLocalFile(value) [ Internal, ZenMethod ]
{
	Set ..LOCALFILENAME=value
	
	Set button=..%GetComponentById("btnSubmit")
	Set button.disabled=(value="")
	If value'="" {
		Set button.controlClass="commandButton"
	} Else {
		Set button.controlClass="commandButtonDisabled"
	}
	
	Do ..GenerateCubeName()
}

/// Fire popup action to navigate to dashboard
Method seeDash() [ Internal, ZenMethod ]
{
	Set pcube=..CubeName
	&JS<zenPage.firePopupAction('dash','#(pcube)#');>
}

/// Fire popup action to navigate to scorecard
Method seeScoreCard() [ Internal, ZenMethod ]
{
	Set pcube=..CubeName
	&JS<zenPage.firePopupAction('score','#(pcube)#');>
}

/// User changed to pick file between Remote and Local
ClientMethod doLocationChange(flag) [ Internal, Language = javascript ]
{
	if (flag == "LOCAL") {
		zen("idRemoteFile").setHidden(true);
		zen("LocalFile").setHidden(false);
		// for local we cannot allow for Directory
		// show Submit button
		zen("btnNext").setHidden(true);
		zen("btnSubmit").setHidden(false);
	} else {
		zen("idRemoteFile").setHidden(false);
		zen("LocalFile").setHidden(true);
		zen("btnNext").setHidden(false);
		zen("btnSubmit").setHidden(true);
		var Source=zen("FileName").getValue()
		if (zen("FileName").getValue() != "") {
			zen("btnNext").setProperty('disabled',Source=="");
			zen("btnNext").setProperty('controlClass', (Source!="" ? 'commandButton' :'commandButtonDisabled'));			
		}
	}
}

/// Start the Import
ClientMethod doImportJSON() [ Language = javascript ]
{
	//Before processing, make sure all property names are unique
	var count=1
	var ok=1
	var test=[];
	while (document.getElementById("propName"+count)!=null) {
		document.getElementById("propName"+count).style=""
		if (test[document.getElementById("propName"+count).value]!=null) {
			document.getElementById("propName"+test[document.getElementById("propName"+count).value]).style.border="2px solid #FF0000"
			document.getElementById("propName"+count).style.border="2px solid #FF0000"
			ok=0
		}
		test[document.getElementById("propName"+count).value]=count
		count+=1
	}
	
	if (!ok) {
		alert("Property names not unique.");
		return
	}
	
	zenPage.nextPage();
	zen("btnDone").setHidden(false);
	zen("btnCancel").setHidden(true);
	zenPage.updateState();
}

/// Update the state of the template buttons.
/// Subclasses should call this method when they need to 
/// update the state of the footer buttons.
ClientMethod updateState() [ Language = javascript ]
{
	var btnBack=zen('btnBack');
	var btnNext=zen('btnNext');
	var btnFinish=zen('btnFinish');
	var btnGoStats=zen('btnGoStats');
	var btnHelp=zen('btnHelp');
	var btnSubmit=zen('btnSubmit');
	var multi=this.hasMultiplePages();

	if (0) {
		btnBack.setProperty('hidden',!this.canGoBack());
		btnBack.setProperty('disabled',!this.canGoBack());
		btnBack.setProperty('controlClass',	(this.canGoBack() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnNext) {
		btnNext.setProperty('hidden',!this.canGoNext());
		btnNext.setProperty('disabled',!this.canGoNext());
		btnNext.setProperty('controlClass',	(this.canGoNext() ? 'commandButton' :'commandButtonDisabled'));
	}
	// special for Import on this page. Hide regular Next and show Submit Next for LOCAL.
	if (zen("InputType").getValue()=="LOCAL") {
		btnSubmit.setProperty('disabled',true);
		btnSubmit.setProperty('controlClass', 'commandButtonDisabled');
	}
	if (btnFinish) {
		btnFinish.setProperty('disabled',!this.canFinish());
		btnFinish.setProperty('hidden',!this.canFinish());
		btnFinish.setProperty('controlClass', (this.canFinish() ? 'commandButton' :'commandButtonDisabled'));	
	}
}

/// Kicks off GenerateAll and starts the update timer
ClientMethod updateProgress() [ Language = javascript]
{
	var file=this.Source
	if (this.INPUTTYPE=='LOCAL') {
		file=this.LOCALFILENAME
	}
	this.trackingId=this.GenerateAll(this.SourceType,file,this.LineSize,this.hasHeaders,this.CubeName,this.propertyJSONStreamID,this.dataJSONStreamID);
	if (this.trackingId!='') {
		zen('timer').timeout=500;
		zen('timer').startTimer();
	}
}

/// Update the status area.
ClientMethod updateStatus() [ Language = javascript ]
{
	var status=this.CheckStatus(this.trackingId);
	var html=zen('htmlContent3');
	if (status != '') {
		html.setContent(status);
		zen('timer').timeout=250;
		zen('timer').startTimer();
	}
	else {
		this.trackingId='';
		
		if (zenPage.DashboardExists()) {
			zen("btnGoDash").setProperty('disabled',0);
			zen("btnGoDash").setProperty('hidden',0);
			zen("btnGoDash").setProperty('controlClass','commandButton');	
			
			// If the dashboard was generated, we know it is safe to proceed to stats tab
			zen("btnGoStats").setProperty('disabled',!this.canStat());
			zen("btnGoStats").setProperty('hidden',!this.canStat());
			zen("btnGoStats").setProperty('controlClass', (this.canStat() ? 'commandButton' :'commandButtonDisabled'));
		}
		
		if (zenPage.ScoreCardExists()) {
			zen("btnScoreDash").setProperty('disabled',0);
			zen("btnScoreDash").setProperty('hidden',0);
			zen("btnScoreDash").setProperty('controlClass','commandButton');
		}	
	}
	return;
}

ClientMethod showMsg(msg) [ Language = javascript ]
{
	zen("idRespond").setValue(msg);
 	zen("idRespond").setHidden(false);
}

/// Get the current status of the background task.
ClassMethod CheckStatus(pTrackingId As %String) As %String [ ZenMethod ]
{
	Set tOutput=""
	Set tIsComplete=0
	Set tIsErr=0

	Merge tTracking=^AnalyzeThis.GenerateTracking(pTrackingId)
	
	Set currStep=$O(tTracking(""),-1)
	If currStep="" Quit tOutput
	For tStep=1:1:currStep {
		
		Set tPhase=$Case(tStep,
							1:"Preparing JSON",
							2:"Generating Source Class",
							3:"Importing Data",
							4:"Generating Cube",
							5:"Populating Cube",
							:"Generating Sample Dashboard")
		
		Set tStatus=tTracking(tStep)
		
		If tStatus="Working..." {
			// Leave message as "Working..."
		} ElseIf $$$ISERR(tStatus) {
			Set tStatus=$System.Status.GetErrorText(tStatus)
			Set tIsErr=1
		} Else {
			Set tStatus="Complete"
			If tStep=6 {
				Set tIsComplete=1
			}
		}
		
		Set tOutput=tOutput _ "<tr style="""_$S(tIsErr:"color:#da4848;",1:"")_""">"
		Set tOutput=tOutput _ "<td>"_tPhase_"</td>"
		Set tOutput=tOutput _ "<td>"_tStatus_"</td>"
		Set tOutput=tOutput _ "</tr>"
	}
	For tStep=currStep+1:1:6 {
		//Set tOutput=tOutput _ "<tr style="""_$S(tErr'="":"color:#da4848;",tIsActive:"font-weight:bold;",1:"background:#E0E0F0;")_""">"
		Set tOutput=tOutput _ "<tr>"
		
		Set tPhase=$Case(tStep,
							1:"Preparing JSON",
							2:"Generating Source Class",
							3:"Importing Data",
							4:"Generating Cube",
							5:"Populating Cube",
							:"Generating Sample Dashboard")
		
		Set tOutput=tOutput _ "<td>"_tPhase_"</td>"
		Set tOutput=tOutput _ "<td>Not Yet Started</td>"
		Set tOutput=tOutput _ "</tr>"
	}
	
	If (tOutput'="") {
		Set tOutput="<div>"_$$$Text("Status")_ "</div><table class=""statusTable"" cellspacing=""0"" width=""100%"">" _ tOutput _ "</table>"
	}

	If (tIsComplete || tIsErr) {
		Kill ^AnalyzeThis.GenerateTracking(pTrackingId)
	}
	Quit tOutput
}

/// Start the build cube process in the background.
/// Return the tracking id.
ClassMethod GenerateAll(pSourceType,pSource, pLineSize, pHasHeaders, pCubeName, pPropertyJSONStreamId, pDataJSONStreamId) As %String [ ZenMethod ]
{
	Set tTrackingId=""
	Set tJobTimeOut=10
	
	Job ##class(AnalyzeThis.Generator).GenerateAll(pSourceType,pSource, pLineSize, pHasHeaders, pCubeName, pPropertyJSONStreamId, pDataJSONStreamId)::tJobTimeOut
	If '$Test {
		&js<alert('Unable to start background job.');>
		Set tTrackingId=""
	}
	Else {
		Set tTrackingId=$ZChild
	}
	Quit tTrackingId
}

/// Using the current cube name, check if a dashboard was generated for this cube
Method DashboardExists() As %Status [ ZenMethod ]
{
	Set dashName="Generated/Samples for "_..CubeName_".dashboard"
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	Quit st
}

/// Using the current cube name, check if a scorecard was generated for this cube
Method ScoreCardExists() As %Status [ ZenMethod ]
{
	Set dashName="Generated/Sample ScoreCard for "_..CubeName_".dashboard"
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	Quit st
}

/// Display cube stats in the status area
ClientMethod drawStats() [ Language = javascript ]
{
	document.getElementById("statsTable").innerHTML="<p>Generating Stats...</p>"
	document.getElementById("statsTable").innerHTML=zenPage.GetStats()
	zenPage.updateState();
}

/// Generate stats display
Method GetStats() As %String [ ZenMethod ]
{
	Set st=$$$OK
	
	Set mdx="SELECT [Measures].[%COUNT] on 1 from ["_..CubeName_"]"
	Set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
	Set totalmembers=rs.%GetOrdinalValue(1)
	Set html="<p>"_totalmembers_" facts have been built for Cube "_..CubeName_"</p><table border=""1""><th>Level Name</th><th>Number of Members</th><th>Percentage of Null Values</th>"
	Set st=##class(%DeepSee.Utils).%GetDimensionList(..CubeName,.info)
	Set d=$order(info(""))
	While d'="" {
		Set h=$order(info(d,""))
		While h'="" {
			Set l=$order(info(d,h,""))
			While l'="" {
				If $lg(info(d,h,l),1)="l" {
					Set spec="["_$lg(info(d,h,l),2)_"].["_$lg(info(d,h,l),3)_"].["_$lg(info(d,h,l),4)_"]"
					Set mdx="SELECT COUNT("_spec_".Members) on 1 from ["_..CubeName_"]"
					Set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
					Set members=rs.%GetOrdinalValue(1)
					
					Set mdx="SELECT ISNULL("_spec_".&[<null>],0)/[Measures].[%COUNT] on 1 from ["_..CubeName_"]"
					Set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
					Set nullpercent=(((rs.%GetOrdinalValue(1)*10000)\1)/100)
					Set html=html_"<tr><td>"_spec_"</td><td>"_members_"</td><td>"_nullpercent_"%</td></tr>"
				}
				Set l=$order(info(d,h,l))
			}
			Set h=$order(info(d,h))
		}
		Set d=$order(info(d))
	}
	Set html=html_"</table>"
	Quit html
}

/// Using file properties, create the cube name
Method GenerateCubeName() [ ZenMethod ]
{
	If ..SourceType="CSV" {
		Set file=""
		If ..%GetValueById("InputType")="LOCAL" {
			Set file=..LOCALFILENAME
		} Else {
			Set file=..Source
		}
		If $length(file,"\")>$length(file,"/") {
			Set tName=$zstrip($replace($piece($piece(file,"\",*),".",1),"DEEPSEE",""),"*PCW")
		} Else {
			Set tName=$zstrip($replace($piece($piece(file,"/",*),".",1),"DEEPSEE",""),"*PCW")
		}
	} ElseIf ..SourceType="Class" {
		Set tName=..Source
		// Class should end in .cls, extract package + .cls extension to get class name
		// If class does not end in .cls, handle appropriately
		Set tCls=1
		If $zconvert($extract(tName,*-3,*),"U")'=".CLS" {
			Set tCls=0
		}
		Set tName=$piece(tName,".",*-tCls)
	} Else {
		// SouceType not supported to auto generate class name
		Quit
	}
	
	Set ..CubeName=tName
	Set ..SourceClass="AnalyzeThis.Generated."_tName
	Do ..%SetValueById("CubeName",tName)
}

/// Validates and updates the cube name property
Method UpdateCubeName(tName) [ ZenMethod ]
{
	If ($$$UPPER($ZStrip(tName,"<N"))'=$$$UPPER(tName)) {
		&JS<alert("Name cannot start with a number!")
		zenPage.getComponentById("CubeName").setValue("#(..CubeName)#")>
	}
	Set ..CubeName=tName
	Set ..SourceClass="AnalyzeThis.Generated."_tName
}

/// This method is fired up after onDrawContent is finished. Hide progress message and display error if exists.
ClientMethod drawDone(tab) [ Language = javascript ]
{
	
	var result=this.GetStatus(tab);
	var id="idProgress"+tab;
	if (result.Status == "Done") {
		if (result.Error != "") {
			this.showMsg(result.Error);
			zen("btnFinish").setProperty('disabled',true);
			zen("btnFinish").setProperty('controlClass','commandButtonDisabled');
		}
	} else {
		zen("btnNext").setProperty('disabled',true);
		zen("btnNext").setProperty('controlClass','commandButtonDisabled');
		zen("btnFinish").setProperty('disabled',true);
		zen("btnFinish").setProperty('controlClass','commandButtonDisabled');
	}
	zen(id).setHidden(true);
}

/// Return true if this template can go to the next page (i.e., enable
/// the Next button).<br>
ClientMethod canGoNext() [ Language = javascript ]
{
	var tabGroup=zen('tabGroup');
	var tabNo=tabGroup.getCurrTabNo();	
	var flag=false;
	switch(tabNo) {
	case 1:
		flag=true;
		if (this.INPUTTYPE == "LOCAL") flag=false;
		break;
	case 2:
		break;
	case 3:
		break;
	case 4:
		break;
	}
	return flag;
}

/// Return true if this template can go to the stats page (i.e., enable
/// the stats button).<br>
ClientMethod canStat() [ Language = javascript ]
{
	var tabGroup=zen('tabGroup');
	var tabNo=tabGroup.getCurrTabNo();	
	var flag=false;
	switch(tabNo) {
	case 1:
		break;
	case 2:
		break;
	case 3:
		flag=true;
		break;
	case 4:
		break;
	}
	return flag;
}

/// Return true if this template can go to the previous page (i.e., enable
/// the Back button).<br>
/// This is implemented by subclasses.
ClientMethod canGoBack() [ Language = javascript ]
{
	var tabGroup=zen('tabGroup');
	var tabNo=tabGroup.getCurrTabNo();
	var flag=true;
	switch(tabNo) {
	case 1:
		flag=false;
		break;
	case 2:
		break;
	case 3:
		break;
	case 4:
		break;
	}	
	return flag
}

/// Return true if this template can Finish (i.e., enable
/// the Finish button).<br>
ClientMethod canFinish() [ Language = javascript ]
{
	var tabGroup=zen('tabGroup');
	var tabNo=tabGroup.getCurrTabNo();
	var flag=false;
	switch(tabNo) {
	case 1:
		break;
	case 2:
		flag=true;
		break;
	case 3:
		break;
	case 4:
		break;
	}
	
	return flag;
}

ClientMethod hasMultiplePages() [ Language = javascript ]
{
	return true;
}

/// Go to the next page of the template (if there is one).<br>
ClientMethod nextPage() [ Language = javascript ]
{
	var tabGroup=zen('tabGroup');
	var tabNo=tabGroup.getCurrTabNo();
	var html=zen("htmlContent");
	this.showMsg("",1);	
	switch(tabNo) {
	case 1:
		var SourceType=zen("SourceType").getValue();
		
		if (SourceType=="CSV") {
			var Source=zen("FileName").getValue();
			var inputtype="REMOTE"
			if (this.LOCALFILENAME != "") {
				Source=this.LOCALFILENAME;
				inputtype="LOCAL";
			}
			var ok=this.ValidateFile(Source);
			if (ok == 0) {
				this.showMsg($$$Text("File required."),1);	
				zen("FileName").focus();
				break;
			}
			if (ok == -1) {
				this.showMsg($$$Text("You have entered a directory path without a file name."),1);
				zen("FileName").focus();
				break;	
			}
			if (ok == -2) {
				this.showMsg($$$Text("File does not exist!"),1);
				zen("FileName").focus();
				break;		
			}
			if (ok == -3) {
				this.showMsg($$$Text("File Name cannot start with a number!"),1);
				zen("FileName").focus();
				break;		
			}
			html.setProperty('seed',Source);
		} else if (SourceType=="SQL") {
			var sql=zen("SQLText").getValue();
			if (sql=="") {
				this.showMsg($$$Text("SQL Query required."),1);
				zen("SQLText").focus();
				break;
			}
			html.setProperty('seed',sql);
		} else if (SourceType=="Class") {
			var sourceClass=zen("sourceClass").getValue();
			if (sourceClass=="") {
				this.showMsg($$$Text("Source Class required."),1);
				zen("sourceClass").focus();
				break;
			}
			html.setProperty('seed',sourceClass);
		}
		
		if (zen("CubeName").getValue()=="") {
			this.showMsg($$$Text("Cube Name required."),1);
			zen("CubeName").focus();
			break;
		}

		var uniquename=zenPage.UniqueName(zen("CubeName").getValue());
		if (uniquename!="") {
			this.showMsg($$$Text(uniquename),1);
			zen("CubeName").focus();
			break;
		}
		
		tabGroup.showNextTab();
		break;
	case 2:
		var html=zen("htmlContent3");
		html.setProperty('seed',1);
		tabGroup.showNextTab();
		break;
	case 3:
		var html=zen("htmlContent4");
		html.setProperty('seed',1);
		tabGroup.showNextTab();
		break;
	case 4:
		break;
	}
	zenPage.updateState();
}

/// Go to the previous page of the template (if there is one).<br>
/// This is implemented by subclasses.
ClientMethod previousPage() [ Language = javascript ]
{
	var tabGroup=zen('tabGroup');
	var tabNo=tabGroup.getCurrTabNo();
	switch(tabNo) {
	case 1:
		break;
	case 2:
		tabGroup.showPreviousTab();
		zenPage.updateState();
		if (zen("InputType").getValue()=="LOCAL") {
			zen('btnNext').setProperty('hidden',true);
		}
		break;
	case 3:
		tabGroup.showPreviousTab();
		zenPage.updateState();
		break;
	case 4:
		tabGroup.showPreviousTab();
		zenPage.updateState();
		break;
	}
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Internal, Language = javascript ]
{
	this.invokeSuper('onloadHandler',arguments);
	if (this.InvalidParam) {
		zen("btnNext").setHidden(true);
	}
	this.onstartHandler();
}

ClientMethod getDialogValue() [ Internal, Language = javascript ]
{
	return ""
}

/// User clicked the Browse button.
ClientMethod browseSelect(name) [ Internal, Language = javascript ]
{
	var Dir=zen(name).getValue();
	zenLaunchPopupWindow('%ZEN.Dialog.fileSelect.zen?Dir='+encodeURIComponent(Dir)+'&wildcard=*.csv&showdirectoryonly=0','FileSelect','resizable,width=600,height=700');
}

/// Returning from file select OR qualifers dialog and setting the value into the appropriate field.
/// The id of the field that needs to be updated is saved in "dialogClicked".
ClientMethod onPopupAction(popupName, action, value) [ Internal, Language = javascript ]
{
	if (action=="ok") {
		if (popupName=="sourceClass") {
			zenPage.getComponentById(popupName).setValue(value);
			zenPage.UpdateSource(value);
			zenPage.updateState();
		} else if (popupName=="FileSelect") {
			zen("FileName").setValue(value);
			zenPage.UpdateSource(value);
			zenPage.GenerateCubeName();
			zenPage.updateState();
		}	
	}
}

/// This is called when the template is first displayed;
/// This provides a chance to load the last filetype, etc.
ClientMethod onstartHandler() [ Internal, Language = javascript ]
{
	this.onresizeHandler();
	// if this is from the submit of the Local file, load the content of the file on tab 2.
	if (this.INPUTTYPE == "LOCAL") {
		// set the first tab for LOCAL correctly
		this.doLocationChange("LOCAL");		
		if (this.LOCALFILENAME != "") {
			var html=zen("htmlContent");
			html.setProperty('seed',this.LOCALFILENAME);
			var tabGroup=zen('tabGroup');
			var tabNo=tabGroup.getCurrTabNo();
			if (tabNo == 1) {
				tabGroup.showNextTab();
			}
			zenPage.updateState();
		} 
		zen("btnNext").setHidden(true);
	}
}

/// Get the (localized) title string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String [ Internal ]
{
	Quit $$$TextHTML("Import Data")
}

/// Get the (localized) subtitle string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetSubtitle() As %String [ Internal ]
{
	Quit ""
}

/// This callback is called after the server-side page 
/// object and all of its children are created.<br/>
/// Subclasses can override this to add, remove, or modify 
/// items within the page object model, or to provide values
/// for controls.
Method %OnAfterCreatePage() As %Status [ Internal ]
{
	Set tSC=##super()
	If $$$ISERR(tSC) Quit tSC
	
	// try and determine if user is on *same* machine as server
	// if so, do not provide local upload option
	Set tTCPAddr=$SYSTEM.TCPDevice.PeerAddr(0)
	Set tClientAddr=$G(%request.CgiEnvs("REMOTE_ADDR"))
	Set tIsLocal=((tClientAddr="127.0.0.1") ! (tClientAddr="::1")) & ((tTCPAddr="127.0.0.1") ! (tTCPAddr="::1"))
	If tIsLocal {
		Set ..%GetComponentById("InputType").hidden=1
		Set ..%GetComponentById("LocalFile").hidden=1
	}
	Set ..SourceType=..%GetComponentById("SourceType").value
	Set Source=""
	Set ..%GetComponentById("FileName").value=Source
	#; Set for Remote input types choice: ServerName or local machine
	Set ..%GetComponentById("InputType").displayList=$zu(110)_","_$$$Text("My Local Machine")
	If $G(%request.Data("INPUTTYPE",1))="LOCAL" {
		Set %page.LOCALFILENAME=$G(%session.Data($Username,"Import","LOCALFileName"))
		Set ..%GetComponentById("InputType").value="LOCAL"
	}
	If $G(%request.Data("LineSize",1)) '= "" {
		Set %page.LineSize=$G(%request.Data("LineSize",1))
		Set ..%GetComponentById("LineSize").value=$G(%request.Data("LineSize",1))
		Set ..LineSize=$G(%request.Data("LineSize",1))
	}
	If $G(%request.Data("CubeName",1)) '= "" {
		Set %page.CubeName=$G(%request("CubeName",1))
		Set ..%GetComponentById("CubeName").value=$G(%request.Data("CubeName",1))
		Set ..CubeName=$G(%request.Data("CubeName",1))
	}
	Quit $$$OK
}

ClassMethod DrawSortPageTitle(pSeed As %String) As %Status [ Internal ]
{
	Set tPageTitle="<i>Please sort each column as Dimension, Date, or Measure. "_ 
	"<br/>A Measure might be something like revenue, or total discharges.<br/>If it is a measure, please specify if it is a number or currency."_
	"<br/>A Dimension would be things like zip code, state, or measure description</i>"
	&html<<div class="Description">#(tPageTitle)#
	</div><hr size="1"/>>
	Quit 1
}

ClassMethod DrawPageTitle(pSeed As %String) As %Status [ Internal ]
{
	Set tPageTitle="Import Data"
	&html<<div class="Description">#(tPageTitle)#
	</div><hr size="1"/>>
	Quit 1
}

/// Draw preview content of the CSV file for user to confirm properties
Method PropertyCheckJSON(pSeed) As %Status [ ZenMethod ]
{
	Set tSC=$$$OK
	
	Quit:pSeed="" tSC
	
	// Get JSON from CSV
	Set file=""
	If ..INPUTTYPE="LOCAL" {
		Set file=..LOCALFILENAME
	} Else {
		Set file=..Source
	}
	If ..SourceType="SQL" {
		Set tSC=##class(AnalyzeThis.Utils).SQLToJSON(pSeed,.propertiesJSONStreamId,.dataJSONStreamId,10)
	} ElseIf ..SourceType="Class" {
		// Get the SQL table name and then pass through SQL method
		Set sqlQuery=##class(AnalyzeThis.Utils).ClassToQuery(pSeed)
		Set tSC=##class(AnalyzeThis.Utils).SQLToJSON(sqlQuery,.propertiesJSONStreamId,.dataJSONStreamId,10)
	} Else {
		Set tSC=##class(AnalyzeThis.UI.Dialog.CSVImport).CSVToJSON(file,.propertiesJSONStreamId,.dataJSONStreamId,10,..hasHeaders)
	}
	
	Quit:$$$ISERR(tSC) tSC
	
	Set ..propertyJSONStreamID=propertiesJSONStreamId
	Set ..dataJSONStreamID=dataJSONStreamId
	
	Set properties=##class(%Stream.FileBinary).%OpenId(propertiesJSONStreamId)
	Set propertyObj={}.%FromJSON(properties)
	
	Set data=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	Set dataArray=[].%FromJSON(data)
	
 	Quit:$$$ISERR(tSC) tSC
 	
	&html<<table border=1>>
	&html<<tr>>
	Set iter=propertyObj.Display.%GetIterator()
	While iter.%GetNext(.key,.val) {
		If propertyObj.Ignore.%Get(key) {
			Continue
		}
		Set format=0
		&html<<td align="center" style="vertical-align:top;">Include? <input type="checkbox" name="includeCol#(key)#" id="includeCol#(key)#" onchange="zenPage.updateProp('#(key)#','Include',this.checked,'#(propertiesJSONStreamId)#');" checked></br><select id="propType#(key)#" onchange="zenPage.swapFormat('#(key)#',value); zenPage.updateProp('#(key)#','Type',value,'#(propertiesJSONStreamId)#');">>
			&html<<option value="%String" selected="selected">Dimension</option>>
			&html<<option value="%Integer">Measure</option>>
			&html<<option value="%Date">Date</option>>
			&html<<option value="%TimeStamp">TimeStamp</option>>
		&html<</select></br><select id="dateFormat#(key)#" style="display:none;" onchange="zenPage.updateProp('#(key)#','DateFormat',value,'#(propertiesJSONStreamId)#');"/>>
			&html<<option value="1" #($select(format=1:"selected='selected'",1:""))#>MM/DD/[YY]YY</option>>
			&html<<option value="2">DD Mmm [YY]YY</option>>
			&html<<option value="3" #($select(format=3:"selected='selected'",1:""))#>YYYY-MM-DD</option>>
			&html<<option value="4">DD/MM/[YY]YY</option>>
			&html<<option value="5" #($select(format=5:"selected='selected'",1:""))#>YYYY</option>>
			/*&html<<option value="5">Mmm [D]D, YYYY</option>>
			&html<<option value="6">Mmm [D]D YYYY</option>>
			&html<<option value="7">Mmm DD [YY]YY</option>>
			&html<<option value="8">YYYYMMDD</option>>
			&html<<option value="9">Mmmmm [D]D, YYYY</option>>
			&html<<option value="10">W</option>>
			&html<<option value="11">Www</option>>
			&html<<option value="12">Wwwwww</option>>
			&html<<option value="13">[D]D/[M]M/YYYY </option>>
			&html<<option value="14">nnn</option>>
			&html<<option value="15">DD/MM/[YY]YY</option>>
			&html<<option value="16">YYYYc[M]Mc[D]Dc</option>>
			&html<<option value="17">YYYYc [M]Mc [D]Dc</option>>
			&html<<option value="18">[D]D Mmmmm YYYY</option>>
			&html<<option value="19">[D]D [M]M YYYY</option>>
			&html<<option value="20">[D]D Mmmmm YYYY</option>>
			&html<<option value="21">[D]D [M]M YYYY</option>>*/
			&html<<option value="30">$H</option>>
			&html<</select><select id="intFormat#(key)#" style="display:none;" onchange="zenPage.updateProp('#(key)#','IntFormat',value,'#(propertiesJSONStreamId)#');"/>>
			&html<<option value="%Integer" selected="selected">Integer</option>>
			&html<<option value="%Double">Double</option>>
			&html<<option value="%Library.Currency">Currency</option>>
			&html<</select></td>>
	}
	&html<</tr>>
	&html<<tr>>
	Set iter=propertyObj.Display.%GetIterator()
	While iter.%GetNext(.key,.val) {
		If propertyObj.Ignore.%Get(key) {
			Continue
		}
		&html<<th><input type="text" id="propName#(key)#" maxlength="31" value="#(val)#" onchange="zenPage.updateProp('#(key)#','Display',value,'#(propertiesJSONStreamId)#');"></input></th>>
	}
	&html<</tr>>
	Set iter=dataArray.%GetIterator()
	While ((iter.%GetNext(.key,.val)) && (key<10)) {
		If propertyObj.Ignore.%Get(key) {
			Continue
		}
		&html<<tr>>
		Set tPropNum=-1
		Set iter2=val.%GetIterator()
		While iter2.%GetNext(.key2,.val2) {
			&html<<td id="p#($I(tPropNum))#r#(key)#">#(val2)#</td>>
		}
		&html<</tr>>
	}
	&html<</table>>
	Set %session.Data($Username,"Import","ContentStatus") = "Done"
	Quit tSC
}

/// Changes formatting options based on the type
ClientMethod swapFormat(propID, value) [ Internal, Language = javascript ]
{
	if ((value=='%Date') || (value=='%TimeStamp'))  {
		document.getElementById("dateFormat"+propID).style.display=""
		document.getElementById("intFormat"+propID).style.display="none"
		
		zenPage.autoDateFormat(propID);
	} else if (value=='%Integer') {
		document.getElementById("intFormat"+propID).style.display=""
		document.getElementById("dateFormat"+propID).style.display="none"
	} else {
		document.getElementById("dateFormat"+propID).style.display="none"
		document.getElementById("intFormat"+propID).style.display="none"
	}
}

/// Try and automatically select the date format
ClientMethod autoDateFormat(propID) [ Internal, Language = javascript ]
{
	var dates=[];
	for (var i=0;i<10;i++) {
		var prop=document.getElementById("p"+propID+"r"+i);
		if (prop==null) {
			return
		}
		var temp=parseInt(zenPage.findDateType(prop.innerHTML));
		if (typeof dates[temp]=="undefined") {
			dates[temp]=1;
		} else {
			dates[temp]+=1;
		}
	}

	var typemaxval=0;
	var typemaxpos=0;
	for (var i=0;i<dates.length;i++) {
		if (dates[i]>typemaxval) {
			typemaxpos=i;
			typemaxval=dates[i];
		}
	}
	
	// Can enhance this later to keep type 0 and prevent user from going to next page if type=0
	if (typemaxpos==0) {
		typemaxpos=1;
	}
	
	document.getElementById("dateFormat"+propID).value=typemaxpos;
	document.getElementById("dateFormat"+propID).onchange();
}

/// As changes are made to the properties, update the JSON stream
Method updateProp(key, which, value, stream) [ ZenMethod ]
{
	Set propertyJSON=##class(%Stream.FileBinary).%OpenId(stream)
	Set propertyObj={}.%FromJSON(propertyJSON)
	
	Do propertyObj.%Get(which).%Set(key,value)
	
	Do propertyObj.%ToJSON(.propertyJSON)
	Do propertyJSON.%Save()
}

Method findDateType(pValue) As %Integer [ ZenMethod ]
{
	Quit ##class(AnalyzeThis.UI.Dialog.CSVImport).FindType(pValue)
}

/// Given a value, find the best guess of type
ClassMethod FindType(value) As %Integer
{
	Set type=0
	
	If (value?1.2N1"/"1.2N1"/"2.4N) {
		//	[N]N/[N]N/[NN]NN
		Set type=1
	} ElseIf (value?2N1" "1(1(1"J",1"j")1(1"A",1"a")1(1"N",1"n"),1(1"F",1"f")1(1"E",1"e")1(1"B",1"b"),1(1"M",1"m")1(1"A",1"a")1(1"R",1"r"),1(1"A",1"a")1(1"P",1"p")1(1"R",1"r"),1(1"M",1"m")1(1"A",1"a")1(1"Y",1"y"),1(1"J",1"j")1(1"U",1"u")1(1"N",1"n"),1(1"J",1"j")1(1"U",1"u")1(1"L",1"l"),1(1"A",1"a")1(1"U",1"u")1(1"G",1"g"),1(1"S",1"s")1(1"E",1"e")1(1"P",1"p"),1(1"O",1"o")1(1"C",1"c")1(1"T",1"t"),1(1"N",1"n")1(1"O",1"o")1(1"V",1"v"),1(1"D",1"d")1(1"E",1"e")1(1"C",1"c"))1" "2.4N) {
		//  NN (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) [NN]NN
		Set type=2
	} ElseIf (value?4N1"-"1.2N1"-"1.2N) {
		//	NNNN-[N]N-[N]N
		Set type=3
	} ElseIf (value?2N1"/"2N1"/"2.4N) {
		//  NN/NN/[NN]NN
		Set type=4
	} ElseIf ((value?1"18"2N)||(value?1"19"2N)||(value?1"20"2N)||(value?1"21"2N)) {
		//	18NN, 19NN, 20NN, 21NN
		Set type=5
	} ElseIf (value?5N) {
		// NNNNN, $H format
		Set type=30
	}
	
	Quit type
}

/// tab = 2: Content - when DrawContent is finished, Status is "Done".
ClassMethod GetStatus(tab) As %ZEN.proxyObject [ Internal, ZenMethod ]
{
	Set proxy=##class(%ZEN.proxyObject).%New()
	Set proxy.Status=$G(%session.Data($Username,"Import","ContentStatus"))
	Set proxy.Error=$G(%session.Data($Username,"Import","ContentError"))
	Quit proxy
}

/// Validate file name.
ClassMethod ValidateFile(FILE) As %Integer [ Internal, ZenMethod ]
{
	If $ZStrip(FILE,"<>W")="" Quit 0
	#; Entered directory only!
	If ##class(%File).DirectoryExists(FILE) Quit -1
	#; File does not exist!"
	If '##class(%File).Exists(FILE) Quit -2
	Set tFILE=$PIECE(FILE,"\",*)
	If ($$$UPPER($ZStrip(tFILE,"<N"))'=$$$UPPER(tFILE)) Quit -3
	Set tFILE=$PIECE(FILE,"/",*)
	If ($$$UPPER($ZStrip(tFILE,"<N"))'=$$$UPPER(tFILE)) Quit -3
	Quit 1
}

ClassMethod UniqueName(pName) As %String [ Internal, ZenMethod ]
{
	Set tResponse=""
	Set tSQL="SELECT ID FROM %Dictionary.ClassDefinition WHERE ID %STARTSWITH ?"
	Set tRS=##class(%SQL.Statement).%ExecDirect(,tSQL,"AnalyzeThis.Generated."_$E(pName,1,16))
	Set tNotUnique=tRS.%Next()
	If tNotUnique {
		Set tResponse="First 16 characters of CubeName must be unique from existing CubeNames. "_pName_" is not unique from "_$Piece(tRS.ID,".",*)
	}
	Quit tResponse
}

/// This method is invoked only when user selects to import from Local Machine.<br/>
/// The necessary parameters are passed in URL. The temp file name is saved in %session and to be used in loading content.
ClassMethod %OnSubmit(pSubmit As %ZEN.Submit) As %Status [ Internal ]
{
	Set tStream=pSubmit.%GetStream("LocalFile")
	Set dir=##class(%File).SubDirectoryName($zu(12),"Temp")
	#; If temp directory does not exist, create it now
	If ##class(%File).DirectoryExists(dir)=0 {
		Do ##class(%File).CreateDirectory(dir)
	}
	#; Get proper delimeter since SubDirectoryName does not include delimeter
	Set tDelim="\"
	If $$$isUNIX Set tDelim="/"
	If $$$isVMS Set tDelim=""
	#; Give it a name so it won't be deleted automatically
	Set DirFileName=dir_tDelim_pSubmit.%Data("CubeName")_".stream"
	Set file=##class(%Stream.FileBinary).%New()
	Set tSC=file.LinkToFile(DirFileName)
	If tStream '= "" {
		#; Copy the stream from local server
		Set tSC=file.CopyFrom(tStream)
		#; Save it to the file stream on the remote server
		If tSC Set tSC=file.%Save()
	}
	Set %response.Context("INPUTTYPE")="LOCAL"
	Set %response.Context("LineSize")=pSubmit.%Data("LineSize")
	Set %response.Context("CubeName")=pSubmit.%Data("CubeName")
	//  remember popup info
	Set %response.Context("$ZEN_POPUP")=1
	Set %response.Context("$ZEN_POPUPPARENT")=+$G(%request.Data("$ZEN_POPUPPARENT",1))
	Set %response.Context("$ZEN_SOFTMODAL")=..%OnUseSoftModals()  
	//  save the temp local file name to be used in later to load content
	Set %session.Data($Username,"Import","LOCALFileName")=DirFileName

	Quit tSC
}

/// This client event, if present, is fired when the page is resized.
ClientMethod onresizeHandler() [ Internal, Language = javascript ]
{
	zenbody=document.getElementById("zenBody")
	body=document.getElementById("body")
	body.offsetHeight=body.parentNode.offsetHeight+'px'
	body.style.height=body.parentNode.offsetHeight+'px'
	body.offsetWidth=(zenbody.offsetWidth-20)+'px'
	body.style.width=(zenbody.offsetWidth-20)+'px'
}

Method SwitchSourceType() As %Status [ZenMethod]
{
	Set st=$$$OK
	
	Set sourceType=..%GetComponentById("SourceType")
	Set sourceCSV=..%GetComponentById("SourceCSV")
	Set sourceSQL=..%GetComponentById("SourceSQL")
	Set sourceClass=..%GetComponentById("SourceClass")
	Set sourceClassFile=..%GetComponentById("sourceClass")
	
	Set ..SourceType=sourceType.value
	If sourceType.value="CSV" {
		// Unhide CSV
		Set sourceCSV.hidden=0
		
		// Hide others
		Set sourceSQL.hidden=1
		Set sourceClass.hidden=1
		
		Set sourceClassFile.required=0
	} ElseIf sourceType.value="SQL" {
		// Unhide SQL
		Set sourceSQL.hidden=0
		
		// Hide others
		Set sourceCSV.hidden=1
		Set sourceClass.hidden=1
		
		Set sourceClassFile.required=0
	} ElseIf sourceType.value="Class" {
		// Unhide SQL
		Set sourceClass.hidden=0
		
		// Hide others
		Set sourceCSV.hidden=1
		Set sourceSQL.hidden=1
		
		Set sourceClassFile.required=1
	}
	
	Quit st
}

/// Takes a CSV file and returns two stream IDs containing relating to a JSON object for the Properties and a JSON object for the Data
ClassMethod CSVToJSON(pFileName As %String = "C:\Users\psteiwer\Documents\simplecsv.csv", ByRef propertyJSONStreamId, ByRef dataJSONStreamId, pMaxLines As %Integer = 0, pHasHeaders As %Boolean = 1, pNewLine As %String = {$c(13,10)}) As %Status
{
	Set st=$$$OK
	
	Set stream=##class(%Stream.FileBinary).%New()
	Do stream.LinkToFile(pFileName)
	Set s=##class(AnalyzeThis.Utils).ReadStream(.stream)
	Set pNewLine=##class(AnalyzeThis.Utils).DetermineNewLine(s)
	Set s=$replace(s,$c(13),"\r")
	Set s=$replace(s,$c(10),"\n")
	Set pNewLine=$zconvert(pNewLine,"O","JS")
	Set m=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine(pNewLine))
	Set m.Text=s
	Set m2=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp(pNewLine))
	Set properties={}
	Set propposition={}
	Set displayarray=[]
	Set typearray=[]
	Set dateformatarray=[]
	Set includearray=[]
	Set intformatarray=[]
	// ignorearray is an array that says if a column has an empty header
	Set ignorearray=[]
	Set dynamicArray=[]
	Set pos=0
	
	Try {
		If ##class(AnalyzeThis.Utils).GetNextRegex(.m,.line) {
			Set m2.Text=line
			Set propcount=-1
			While ##class(AnalyzeThis.Utils).GetNextRegex(.m2,.prop,0) {
				Set propcount=$i(propcount)
				If pHasHeaders {
					Set prop=$zstrip($zstrip(prop,">",","),">C")
					Set:$e(prop,1)="""" prop=$e(prop,2,*)
					Set:$e(prop,*)="""" prop=$e(prop,1,*-1)
					Set prop=$zstrip(prop,"*P")
				} Else {
					Set prop="Property"_propcount
				}
				Do displayarray.%Push(prop)
				Do typearray.%Push("%String")
				Do dateformatarray.%Push("")
				Do intformatarray.%Push("")
				Do includearray.%Push("true")
				Do ignorearray.%Push(prop="")
				Do propposition.%Set(prop,propcount)
			}
			Do properties.%Set("Properties",propposition)
			Do properties.%Set("Display",displayarray)
			Do properties.%Set("Type",typearray)
			Do properties.%Set("DateFormat",dateformatarray)
			Do properties.%Set("IntFormat",intformatarray)
			Do properties.%Set("Include",includearray)
			Do properties.%Set("Ignore",ignorearray)
			
			If pHasHeaders {
				Set pos=m.End-1
			} Else {
				Do m.ResetPosition()
			}
		} Else {
			// Headers too long, pick different file
		}
		
		Set totalprops=propcount
		Set done=0
		Set linecount=0
	} Catch ex {
		Set st=$$$ERROR($$$GeneralError,"Error reading CSV")
	}
	
	If $$$ISERR(st) Quit st
	
	Try {
		While ('done)&&((pMaxLines=0)||(linecount<pMaxLines)) {
			While ##class(AnalyzeThis.Utils).GetNextRegex(.m,.line)&&((pMaxLines=0)||(linecount<pMaxLines)) {
				Set dynamicObject={}
				Set linecount=$i(linecount)
				Set m2.Text=line
				Set propcount=-1
				Set ignore=0
				While ##class(AnalyzeThis.Utils).GetNextRegex(.m2,.val,0) {
					Set propcount=$i(propcount)
					Set val=$zstrip($zstrip(val,">",","),">C")
					If ignorearray.%Get(propcount) {
						If val'="" {
							// If this row has data, stop processing the row
							Set ignore=1
							Quit
						} Else {
							// If this row does not have data for this column, we can continue processing other columns
							Continue
						}
					}
					Set:$e(val,1)="""" val=$e(val,2,*)
					Set:$e(val,*)="""" val=$e(val,1,*-1)
					//w "Cell: "_val,!
					Do dynamicObject.%Set(properties.Display.%Get(propcount),val)
				}
				If (totalprops=propcount) && ('ignore) {
					Do dynamicArray.%Push(dynamicObject)
					Set pos=m.End
				}
			}
			
			Set s=$e(s,pos,*)
			If stream.AtEnd {
				Set done=1
			} Else {
				//If less than half available memory is used, double available memory
				If $s<($zs/2*1024) {
					Set $zs=$zs*2
				}
				Set s=##class(AnalyzeThis.Utils).ReadStream(.stream,s)
				Set s=$replace(s,$c(13),"\r")
				Set s=$replace(s,$c(10),"\n")
				Set m.Text=s
			}
		}
	} Catch ex {
		// Reached max len, pop one item from array
		Set st=ex.AsStatus()
	}
	
	If $$$ISERR(st) Quit st
	
	Set dataJSONStream=##class(%Stream.FileBinary).%New()
	Do dynamicArray.%ToJSON(.dataJSONStream)
	Do dataJSONStream.%Save()
	Set dataJSONStreamId=dataJSONStream.%Id()
	
	Set propertyJSONStream=##class(%Stream.FileBinary).%New()
	Do properties.%ToJSON(.propertyJSONStream)
	Do propertyJSONStream.%Save()
	Set propertyJSONStreamId=propertyJSONStream.%Id()
	
	Quit st
}

/// Invoke class finder dialog.
ClientMethod browseClass(popupName) [ Language = javascript ]
{
	var mode="sourceclasses";
	zenLaunchPopupWindow('_DeepSee.UI.Dialog.finderDialog.cls?MODE='+encodeURIComponent(mode),popupName,'resizable,width=900,height=500');
}
}
