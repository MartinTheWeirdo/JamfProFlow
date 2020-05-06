//%attributes = {}
  // deploy_git_saveToLocalRepo

$vt_localRepoSystemPath:=$1
$vb_goodToGo:=True:C214

FIRST RECORD:C50([Sets:1])
For ($vl_setIterator;1;Records in selection:C76([Sets:1]))  // Loop throught the list of sets
	
	If (Is in set:C273("$ab_DeploySetsHighlightedSet"))
		
		$vt_setFolderPath:=$vt_localRepoSystemPath+Replace string:C233([Sets:1]Name:2;":";"_")
		
		If (Test path name:C476($vt_setFolderPath)=Is a folder:K24:2)
			  // We need to clear it out in case there were some items in there from a previous export that aren't in the set any more. 
			  // Double check we're in the git folder before doing a recursive folder delete
			$vt_gitTestpath:=$vt_localRepoSystemPath+".git"
			If (Test path name:C476($vt_gitTestpath)=Is a document:K24:1)
				DELETE FOLDER:C693($vt_setFolderPath;Delete with contents:K24:24)
			End if 
		End if 
		
		CREATE FOLDER:C475($vt_setFolderPath;*)
		
		  // Write some info about the set to a metadata file
		$vt_jsonString:=""
		
		For ($vl_fieldNumber;1;Get last field number:C255(->[Sets:1]))
			If (Is field number valid:C1000(->[Sets:1];$vl_fieldNumber))
				$vt_fieldName:=Field name:C257(Table:C252(->[Sets:1]);$vl_fieldNumber)
				If ($vt_fieldName#"ID")
					$vt_jsonString:=$vt_jsonString+sh_str_dq ($vt_fieldName)
					$vt_jsonString:=$vt_jsonString+":"
					$vt_jsonString:=$vt_jsonString+JSON Stringify:C1217((Field:C253(Table:C252(->[Sets:1]);$vl_fieldNumber))->)
					$vt_jsonString:=$vt_jsonString+","
				End if 
			End if 
		End for 
		
		If ($vt_jsonString="@,")
			$vt_jsonString:=Substring:C12($vt_jsonString;1;Length:C16($vt_jsonString)-1)
		End if 
		
		$vt_jsonString:="[{"+$vt_jsonString+"}]"
		
		
		  // $vt_jsonString:=Selection to JSON([Sets])
		$vt_jsonFilePath:=$vt_setFolderPath+":set_info.json"
		TEXT TO DOCUMENT:C1237($vt_jsonFilePath;$vt_jsonString;"UTF-8";Document with LF:K24:22)
		
		
		QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
		For ($vl_xmlIterator;1;Records in selection:C76([XML:2]))  // Loop throught the list of sets
			QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Singular_Name:3=[XML:2]ItemType:6)
			$vt_xmlFolderPath:=$vt_setFolderPath+":"+[Endpoints:7]Human_Readable_Plural_Name:2
			If (Test path name:C476($vt_xmlFolderPath)#Is a folder:K24:2)
				CREATE FOLDER:C475($vt_xmlFolderPath;*)
			End if 
			$vt_xmlFilePath:=$vt_xmlFolderPath+":"+Replace string:C233([XML:2]HumanReadableItemName:9;":";"_")+".xml"
			$vt_xml:=Replace string:C233([XML:2]XML:2;"\r";"\n")
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
$vl_setCount:=Records in set:C195("$ab_DeploySetsHighlightedSet")
If ($vl_setCount=1)
	FIRST RECORD:C50([Sets:1])
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"Exported 1 set to local Git repo."
Else 
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"Exported "+String:C10($vl_setCount)+" sets to local Git repo."
End if 

$0:=$vb_goodToGo