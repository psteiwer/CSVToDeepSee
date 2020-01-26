Class AnalyzeThis.Installer
{

ClassMethod RunInstaller(pRootDir)
{
	Set tSC=$$$OK

	set namespace = $ZNspace
	set app = $System.CSP.GetDefaultApp(namespace) _ "/"

	try {
		do EnableDeepSee^%SYS.cspServer(app)
	} catch (ex) {
		set tSC=ex.AsStatus()
		write !,"WARNING: failed to enable DeepSee for "_namespace_" namespace."
	}
	
	If $g(pRootDir)'="" {
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
