//%attributes = {}
  // Init

  // vt_deployedItemsStatus:=""
  // $vl_progressProcessRef:=Progress ("Deploying Configurations to Jamf Pro")

Case of 
	: (Count parameters:C259=1)
		  // Init
		$vt_callingActivityDescription:=$1
		
		$vt_progressProcessName:="Progress"
		$vl_progressProcessRef:=New process:C317(Current method name:C684;0;$vt_progressProcessName;$vt_callingActivityDescription;"*")
		$0:=$vl_progressProcessRef
		
	: (Count parameters:C259=2)
		  // Called from Init
		$vt_callingActivityDescription:=$1
		  //vb_closeProgressWindow:=False
		$vl_progressWindowRef:=Open form window:C675("Progress")
		SET WINDOW TITLE:C213($vt_callingActivityDescription;$vl_progressWindowRef)
		DIALOG:C40("Progress")
		
	Else 
		  //error
End case 

