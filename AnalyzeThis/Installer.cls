Class AnalyzeThis.Installer
{

XData FullInstall [XMLNamespace = INSTALLER ]
{
<Manifest>
	<Default Name="NAMESPACE" Value="AnalyzeThis"/>
	<Default Name="DBNAME" Value="AnalyzeThis"/>
	<Default Name="RESOURCE" Value="%DB_${DBNAME}" />
	
	<Namespace Name="${NAMESPACE}" Code="${DBNAME}-CODE" Data="${DBNAME}-DATA" Create="yes" Ensemble="0">
		<Configuration>
			<Database Name="${DBNAME}-CODE" Dir="${APPPATH}${DBNAME}-CODE" Create="yes" Resource="${RESOURCE}"/>
			<Database Name="${DBNAME}-DATA" Dir="${APPPATH}${DBNAME}-DATA" Create="yes" Resource="${RESOURCE}"/>
		</Configuration>
		<Import File="${APPPATH}/AnalyzeThis/Installer.cls"/>
		<Invoke Class="AnalyzeThis.Installer" Method="RunInstaller" CheckStatus="1">
			<Arg Value="${APPPATH}"/>
		</Invoke>
	</Namespace>
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
	#; Let XGL document generate code for this method.
	Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "FullInstall")
}

ClassMethod RunFullInstaller(pRootDir) As %Status
{
	Set tVars("APPPATH")=pRootDir
	Quit ..setup(.tVars,3)
}

ClassMethod RunInstaller(pRootDir) As %Status
{
	Set tSC=$$$OK
	
	If pRootDir'="" {
		Do $system.OBJ.LoadDir(pRootDir_"/AnalyzeThis","ck",,1)
		Set tSC=..ImportImage(pRootDir_"/Assets/AnalyzeThis_BookCover.png")
		If $$$ISERR(tSC) Quit
	}
	
	Set tItem=##class(%DeepSee.UserLibrary.Link).%New()
	Set tItem.fullName="Analyze This"
	Set tPage="AnalyzeThis.UI.CSVImport.zen"
	Set tItem.href=$system.CSP.GetPortalApp($namespace,tPage) _ tPage
	Set tItem.title="Analyze This"
	Set tItem.bookCover="{background: {style:'background:white;',src:'covers/AnalyzeThis_Cover.png'},header: {text:'$type',style:'display: none;'},title: {text:'$title',style:'display: none;'},image: {style:'display: none;',src:'deepsee/ds2_globe_44.png',imageStyle:'width:64px;height:64px;'},subtitle: {style:'display: none;'},footer: {text:'$owner',style:'display: none;'}}"
	Set tSC=tItem.%Save()
	
	Quit tSC
}

/// Import AnalyzeThis image, code taken from %DeepSee.UI.Dialog.ImageUpload:%OnSubmit
ClassMethod ImportImage(pDir) As %Status
{
	Set tSC=$$$OK
	Set tStream=##class(%Stream.FileBinary).%New()
	Set tSC=tStream.LinkToFile(pDir)
	If $$$ISERR(tSC) Quit
	Set tName="AnalyzeThis_Cover.png"

	If $IsObject(tStream)&&(tName'="") {
		Set tFileName=##class(%File).NormalizeDirectory(tName,##class(%DeepSee.UI.Dialog.ImageUpload).%GetImageDirectory())
		Set tLocalFile=##class(%File).%New(tFileName)
		Set tSC=tLocalFile.Open("WSN")
		If $$$ISERR(tSC) Quit
		
		Set tSC=tLocalFile.CopyFrom(tStream)
		If $$$ISERR(tSC) Quit

		Do tLocalFile.Close()
	}
	
	Quit tSC
}

}
