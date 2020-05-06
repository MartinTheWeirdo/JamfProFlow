//%attributes = {}
  // deploy_JamfPro_Push_prune_smart

$vt_xmlRootElementReference:=$1

Case of 
	: ([XML:2]ItemType:6="Computer Group")
		  // If it's a smart group, prune the members list so target can calculate it for itself.
		$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;"/computer_group/is_smart")
		If (OK=1)
			$vt_isSmart:=""
			DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_isSmart)
			If (OK=0)
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't get the value for the isSmart tag for this group."+<>CRLF
			Else 
				If ($vt_isSmart="True")
					$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;"/computer_group/computers")
					If (OK=1)
						DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
						If (OK#1)
							sh_msg_Alert ("[Error] I wasn't able to prune the member list from "+[Sets:1]Name:2+"/"+[XML:2]HumanReadableItemName:9)
							ABORT:C156
						End if 
					End if 
				End if 
			End if 
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't locate the tag to see if this group is smart or static. All groups should have that tag."+<>CRLF
			TRACE:C157  // Supin' wrong. Groups should always have isSmart
		End if 
		
		
	: ([XML:2]ItemType:6="Mobile Device Group")
		  // If it's a smart group, prune the members list so target can calculate it for itself.
		$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;"/mobile_device_group/is_smart")
		If (OK=1)
			$vt_isSmart:=""
			DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_isSmart)
			If (OK=0)
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't get the value for the isSmart tag for this group."+<>CRLF
			Else 
				If ($vt_isSmart="True")
					$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;"/mobile_device_group/computers")
					If (OK=1)
						DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
						If (OK#1)
							sh_msg_Alert ("[Error] I wasn't able to prune the member list from "+[Sets:1]Name:2+"/"+[XML:2]HumanReadableItemName:9)
							ABORT:C156
						End if 
					End if 
				End if 
			End if 
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't locate the tag to see if this group is smart or static. All groups should have that tag."+<>CRLF
			TRACE:C157  // Supin' wrong. Groups should always have isSmart
		End if 
		
		
	: ([XML:2]ItemType:6="User Group")
		  // If it's a smart group, prune the members list so target can calculate it for itself.
		$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;"/user_group/is_smart")
		If (OK=1)
			$vt_isSmart:=""
			DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_isSmart)
			If (OK=0)
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't get the value for the isSmart tag for this group."+<>CRLF
			Else 
				If ($vt_isSmart="True")
					$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;"/user_group/users")
					If (OK=1)
						DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
						If (OK#1)
							sh_msg_Alert ("[Error] I wasn't able to prune the member list from "+[Sets:1]Name:2+"/"+[XML:2]HumanReadableItemName:9)
							ABORT:C156
						End if 
					End if 
				End if 
			End if 
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] I couldn't locate the tag to see if this group is smart or static. All groups should have that tag."+<>CRLF
			TRACE:C157  // Supin' wrong. Groups should always have isSmart
		End if 
		
		
		
End case 
