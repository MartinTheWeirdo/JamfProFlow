//%attributes = {}
  // deploy
  // Called by deploy button in push utils form


vt_deployedItemsSummary:="[start] Deploying Configurations"+<>CRLF

  // Clear created item links display box on deploy tab
ARRAY TEXT:C222(at_DeployLinks_Names;0)
ARRAY TEXT:C222(at_DeployLinks_Links;0)

READ ONLY:C145([Endpoints:7])  // No need to be locking these... we're not writing anything to it. 
READ ONLY:C145([XML:2])
READ ONLY:C145([Sets:1])


  // Do some pre-checks first so we don't discover problems mid-way through
$vb_goodToGo:=True:C214

  // Did they tell us where they want stuff to go? 
$vt_selectedDeploymentOption:=sh_arr_getCurrentValue (->at_DeployOps_ListTab)
If ($vt_selectedDeploymentOption="")
	sh_msg_Alert ("Please select a deployment option (Jamf Pro, Git, etc.)")
	$vb_goodToGo:=False:C215
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[stop] Missing user option selection"+<>CRLF
End if 

  //Did they highlight some sets?
If ($vb_goodToGo)
	If (Records in set:C195("$ab_DeploySetsHighlightedSet")<1)
		sh_msg_Alert ("Please highlight the configuration set (or sets) you want to deploy")
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[stop] Missing user set selection"+<>CRLF
		ABORT:C156
	End if 
End if 

  //CREATE SET([Sets];"$CurrentListBoxDisplay")
  //USE SET("$ab_DeploySetsHighlightedSet")

  // Verify xml is parsable
If ($vb_goodToGo)
	FIRST RECORD:C50([Sets:1])
	For ($vl_pushListIterator;1;Records in selection:C76([Sets:1]))  // Loop throught the list of sets
		If (Is in set:C273("$ab_DeploySetsHighlightedSet"))
			QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)  // Load the XML records for this set
			$vl_NumberOfItemsToSave:=Records in selection:C76([XML:2])  // For Progress
			
			  //$vl_progressProcessRef:=Progress_New ("Parsing XML for set "+sh_str_dq ([Sets]Name);900;500)
			
			For ($vl_xmlIterator;1;$vl_NumberOfItemsToSave)  // Loop through the xml records for the current set
				
				  //Progress SET PROGRESS ($vl_progressProcessRef;$vl_xmlIterator/$vl_NumberOfItemsToSave;"Parsing "+[XML]ItemType+": "+[XML]HumanReadableItemName;False)
				
				$vt_xml:=[XML:2]XML:2
				vl_error:=0
				ON ERR CALL:C155("sh_err_call")
				$vt_xmlRootElementReference:=DOM Parse XML variable:C720([XML:2]XML:2)
				ON ERR CALL:C155("")
				If (vl_error#0)
					sh_msg_Alert ("I couldn't parse the xml for "+[XML:2]ItemType:6+"/"+[XML:2]HumanReadableItemName:9+" in the "+[Sets:1]Name:2+" set.")
					$vb_goodToGo:=False:C215
					$vl_pushListIterator:=Records in selection:C76([Sets:1])  // Pop the loop
					vt_deployedItemsSummary:=vt_deployedItemsSummary+"[stop] Unparsable xml"
				Else 
					If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
						DOM CLOSE XML:C722($vt_xmlRootElementReference)
					End if 
				End if 
			End for   // For ($vl_xmlIterator;1;Records in selection([XML]))  // Loop through the xml records for the current set
			
			  //sh_prg_close ($vl_progressProcessRef)  // Close progress window
			
		End if   // if(Is in set("$ab_DeploySetsHighlightedSet"))
		NEXT RECORD:C51([Sets:1])
	End for   // For ($vl_pushListIterator;1;Records in selection([Sets]))  // Loop throught the list of sets
End if 


If ($vb_goodToGo)  // These will do their own [set] looping since there may be things that need to happen before they start processing. 
	Case of 
		: ($vt_selectedDeploymentOption="Upload to Jamf Pro")
			$vb_goodToGo:=deploy_jamfPro 
			
		: ($vt_selectedDeploymentOption="Save to disk")
			$vt_eol_choice:=sh_arr_getCurrentValue (->at_deploy_save_lineEndingPopup)
			$vb_goodToGo:=deploy_SaveToDisk ($vt_eol_choice;"Desktop")
			BEEP:C151
			
		: ($vt_selectedDeploymentOption="Git")
			$vb_goodToGo:=deploy_git 
			BEEP:C151
			
	End case 
End if 

READ WRITE:C146([Endpoints:7])
READ WRITE:C146([XML:2])
READ WRITE:C146([Sets:1])


