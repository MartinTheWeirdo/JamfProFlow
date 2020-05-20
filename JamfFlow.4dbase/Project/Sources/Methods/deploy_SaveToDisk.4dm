//%attributes = {}
  // deploy_SaveToDisk

$vt_eol_choice:=$1
$vt_folder:=$2

$vb_goodToGo:=False:C215

If (Records in selection:C76([Sets:1])=1)
	$vt_message:="Where would you like to save the selected set?"
Else 
	$vt_message:="Where would you like to save the selected sets?"
End if 

  // Exporting to a folder for non-git use
$vt_defaultPath:=System folder:C487(Desktop:K41:16)
$vt_RequestedBaseFolderPath:=Select folder:C670($vt_message;$vt_defaultPath;Use sheet window:K24:11)
If (OK=1)
	$vt_dateTimeStamp:=Replace string:C233(String:C10(Current date:C33;ISO date GMT:K1:10;Current time:C178);":";"")
	$vt_exportFolderPath:=$vt_RequestedBaseFolderPath+"Jamf Pro API Configuration Sets"+":Exported "+$vt_dateTimeStamp
Else 
	$vt_exportFolderPath:=""
End if 

If ($vt_exportFolderPath#"")
	CREATE FOLDER:C475($vt_exportFolderPath;*)
	FIRST RECORD:C50([Sets:1])
	For ($vl_setIterator;1;Records in selection:C76([Sets:1]))  // Loop throught the list of sets
		
		If (Is in set:C273("$ab_DeploySetsHighlightedSet"))
			
			
			$vt_setFolderPath:=$vt_exportFolderPath+":"+Replace string:C233([Sets:1]Name:2;":";"_")
			CREATE FOLDER:C475($vt_setFolderPath;*)
			QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
			For ($vl_xmlIterator;1;Records in selection:C76([XML:2]))  // Loop throught the list of sets
				QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Singular_Name:3=[XML:2]ItemType:6)
				$vt_xmlFolderPath:=$vt_setFolderPath+":"+[Endpoints:7]Human_Readable_Plural_Name:2
				If (Test path name:C476($vt_xmlFolderPath)#Is a folder:K24:2)
					CREATE FOLDER:C475($vt_xmlFolderPath;*)
				End if 
				$vt_xmlFilePath:=$vt_xmlFolderPath+":"+Replace string:C233([XML:2]HumanReadableItemName:9;":";"_")+".xml"
				If ($vt_eol_choice="Windows (CRLF)")
					$vt_xml:=Replace string:C233([XML:2]XML:2;"\r";"\r\n")
				Else 
					$vt_xml:=Replace string:C233([XML:2]XML:2;"\r";"\n")
				End if 
				TEXT TO DOCUMENT:C1237($vt_xmlFilePath;$vt_xml;"UTF-8";Document with LF:K24:22)
				
				  // For the created item links display box on the deploy tab
				APPEND TO ARRAY:C911(at_DeployLinks_Names;[XML:2]ItemType:6+" "+[XML:2]HumanReadableItemName:9)
				APPEND TO ARRAY:C911(at_DeployLinks_Links;"file://"+Convert path system to POSIX:C1106($vt_xmlFilePath))  // 
				NEXT RECORD:C51([XML:2])
			End for 
			
		End if   //If (Is in set("$ab_DeploySetsHighlightedSet"))
		NEXT RECORD:C51([Sets:1])
	End for   // For ($vl_pushListIterator;1;Records in selection([Sets]))  // Loop throught the list of sets
	
	
	  // Send a done message to the transcript
	If ($vt_folder="Git")
		$vt_exportDestinationDescription:="Git"
	Else 
		$vt_exportDestinationDescription:=sh_str_dq ($vt_exportFolderPath)
	End if 
	If (Records in set:C195("$ab_DeploySetsHighlightedSet")=1)
		FIRST RECORD:C50([Sets:1])
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Exported "+sh_str_dq ([Sets:1]Name:2)+" to "+$vt_exportDestinationDescription
	Else 
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Exported "+String:C10(Records in set:C195("$ab_DeploySetsHighlightedSet"))+" sets to "+$vt_exportDestinationDescription
	End if 
	
	$vb_goodToGo:=True:C214
	
End if 

$0:=$vb_goodToGo