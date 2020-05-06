//%attributes = {}
  // deploy_jamfPro_precheck_set

$vl_setID:=$1
$vt_setName:=$2
$vt_targetServer:=$3
$vb_DeployAddDateCheckbox:=$4
$vt_Push_MergeOrCreateNew:=$5

$vb_goodToGo:=True:C214

QUERY:C277([XML:2];[XML:2]set_id:4=$vl_setID)
For ($vl_xmlIterator;1;Records in selection:C76([XML:2]))  // Loop through the xml records for the current set
	  // Re-parse the XML
	$vt_xml:=[XML:2]XML:2
	vl_error:=0
	ON ERR CALL:C155("sh_err_call")
	$vt_xmlRootElementReference:=DOM Parse XML variable:C720([XML:2]XML:2)
	ON ERR CALL:C155("")
	If (vl_error#0)
		  // We already parsed the xml so we should not get any errors, but just in case something changed...
		sh_msg_Alert ("Sorry, I couldn't parse the xml for "+[XML:2]ItemType:6+"/"+[XML:2]HumanReadableItemName:9+" in the "+$vt_setName+" set.")
		$vb_goodToGo:=False:C215
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't parse this XML."+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"------------ XML ------------"+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+[XML:2]XML:2+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"---------- END XML ----------"+<>CRLF
		  //vt_deployedItemsSummary:=vt_deployedItemsSummary+"Here's a script you can use to try it yourself..."+<>CRLF
		  //vt_deployedItemsSummary:=vt_deployedItemsSummary+"#!/bin/bash"+<>CRLF
		  //vt_deployedItemsSummary:=vt_deployedItemsSummary+"read-r-d '' xml << 'EOF'"+<>CRLF
		  //$vt_cleanXML:=Replace string([XML]XML;"\r";"")
		  //$vt_cleanXML:=Replace string($vt_cleanXML;"\"";"\\\"")
		  //vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_cleanXML+<>CRLF
		  //vt_deployedItemsSummary:=vt_deployedItemsSummary+"EOF"+<>CRLF
		  //vt_deployedItemsSummary:=vt_deployedItemsSummary+"echo $xml | xmllint --format -"+<>CRLF
	End if 
	
	If ($vb_goodToGo)
		  // The API will fail to import anything that has a uniqueness-constrained field if no value is submitted. 
		  // (You'll get a 409 back from the API.)
		
		  // Also, if we are adding items as new, we'll need to verify that the set items 
		  // have no name collisons with data already on target server
		
		  // Get a list of any attributes that need to be unique...
		QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Singular_Name:3=[XML:2]ItemType:6)
		$vt_UniqueValue_XPaths:=""
		$vt_UniqueValue_URLs:=""
		Case of 
			: ([Endpoints:7]isSingleton:16)  // Singletons don't have uniqueness contraints 
				
			: ([Endpoints:7]API_Endpoint_Name:8="healthcarelistener")
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[warn] There's no endpoint to check for healthcare listeners by name so we're not going to precheck. You could get a conflict error on import."+<>CRLF
			: ([Endpoints:7]API_Endpoint_Name:8="healthcarelistenerrule")
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[warn] There's no endpoint to check for healthcare listener rules by name so we're not going to precheck. You could get a conflict error on import."+<>CRLF
			Else 
				  // Typically, you can't have two items of the same type with the same name. 
				  // Like you can't have two policies called "Install Office"
				$vt_UniqueValue_XPaths:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17
				$vt_UniqueValue_URLs:=[Endpoints:7]XML_UniquenessConstraint_URLs:18
				If (($vt_UniqueValue_XPaths="") | ($vt_UniqueValue_URLs=""))
					  // This is unexpected
					  //ASSERT((($vt_UniqueValue_XPaths#"") & ($vt_UniqueValue_URLs#""));"Enter the uniqueness constraints for the "+[XML]ItemType+" endpoint.")
					  // sh_msg_Alert ("Enter the uniqueness constraints for the "+[XML]ItemType+" endpoint.")
					$vb_goodToGo:=False:C215
				End if 
		End case 
	End if 
	
	If ($vb_goodToGo)
		  // Validate the list of unique fields
		If (($vt_UniqueValue_XPaths="") | ($vt_UniqueValue_URLs=""))  // If there are uniqueness contraints 
			C_COLLECTION:C1488($ct_UniqueValue_XPaths;$ct_UniqueValue_URLs)
			$ct_UniqueValue_XPaths:=New collection:C1472
			$ct_UniqueValue_URLs:=New collection:C1472
		Else   // There are uniqueness constraints
			$ct_UniqueValue_XPaths:=Split string:C1554($vt_UniqueValue_XPaths;"\r")
			$ct_UniqueValue_URLs:=Split string:C1554($vt_UniqueValue_URLs;"\r")
			If (($ct_UniqueValue_XPaths.count())#($ct_UniqueValue_URLs.count()))
				sh_msg_Alert ("The counts of the URL and XPath uniqueness constraints don't match for the "+[XML:2]ItemType:6+" endpoint.")
				$vb_goodToGo:=False:C215
			End if 
		End if 
	End if 
	
	If ($vb_goodToGo)
		  // Make sure all the unique ness-constrained values have a value. 
		  // If we are creating new records, make sure there's not already a record 
		  // with the same uniqueness-constrained value on the target server
		For ($vl_xpathIterator;1;$ct_UniqueValue_XPaths.count())
			$vt_xpath:=$ct_UniqueValue_XPaths[$vl_xpathIterator-1]  // Get the value for the uniqueness-constrained value in the current xml
			$vt_URL:=$ct_UniqueValue_URLs[$vl_xpathIterator-1]  // The API call to see if the value exists in the target Jamf Pro
			$vt_FieldName:=sh_str_getLastWord ($vt_xpath;"/")
			  // For most endpoints, there is a rule that you cannot have 2 records with the same name. 
			  // But if we are adding datetime info to the name, that will make it unique so we don't need to check for dups.
			  // But we still need to check stuff like device serial numbers 
			  // So, if value to check for unique is anything other than name, or it is name but we're not putting a date time on it...
			If (($vt_FieldName#"name") | (($vt_FieldName="name") & Not:C34($vb_DeployAddDateCheckbox)))
				$vb_goodToGo:=deploy_jamfPro_precheck_set_XML ($vt_xmlRootElementReference;$vt_xpath;$vt_targetServer;$vt_URL;$vt_setName;$vt_FieldName;$vt_Push_MergeOrCreateNew)
				If (Not:C34($vb_goodToGo))
					$vl_xpathIterator:=$ct_UniqueValue_XPaths.count()  // pop the loop
				End if 
			End if 
		End for   // For ($vl_xpathIterator;1;$ct_xpathsToUniqueValues.count())
	End if 
	
	
	If (Not:C34($vb_goodToGo))
		$vl_xmlIterator:=Records in selection:C76([XML:2])  // Pop the loop
	End if 
	
	NEXT RECORD:C51([XML:2])
End for   // For ($vl_xmlIterator;1;Records in selection([XML]))  // Loop through the xml records for the current set


  // TODO - Look at the dependencies. 
  // All must either be in the set, or already on the target server. 


$0:=$vb_goodToGo