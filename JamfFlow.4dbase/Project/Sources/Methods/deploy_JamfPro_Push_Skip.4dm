//%attributes = {}
  // deploy_JamfPro_Push_Skip

  // There are some endpoints we're not even going to bother with. 
  // We can look into supporting them later

  // TO-DO --- Could we add custom handlers for some of these? 


$vt_API_Endpoint_Name:=$1

$vb_skipThisItem:=False:C215

Case of 
		
	: ($vt_API_Endpoint_Name="smtpserver")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] Skipping smtp server because it requires a password. Enter it by hand in the Jamf Pro webapp."+<>CRLF
		
	: ($vt_API_Endpoint_Name="gsxconnection")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] Skipping GSX Connection because I don't have the required auth token. Enter it by hand in the Jamf Pro webapp."+<>CRLF
		
	: ($vt_API_Endpoint_Name="vppaccounts")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] Skipping VPP account. These should be entered by hand to protect against license contention between two instances."+<>CRLF
		
	: ($vt_API_Endpoint_Name="vppassignments")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy VPP Assignments yet. It's best to let Jamf Pro calculate these."+<>CRLF
		
	: ($vt_API_Endpoint_Name="vppinvitations")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy VPP Invitations yet. It's best to let Jamf Pro calculate these."+<>CRLF
		
	: ($vt_API_Endpoint_Name="healthcarelistener")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy healthcare listeners yet"+<>CRLF
		
		  // This has no post, just put
		
		  // It also has no get by name, so you can't check for conflicts that way. 
		  // There may be no restriction on name uniqueness anyway. 
		  // We may be able to give it a pass
		
		  // Might be generally more effective to pull the listing XML and then scan the names in there. 
		  // But this would be a bad idea for devices, computers, and users
		
		
		  // ==============================================================================
		  // Some other weird 409 conflict errors to look into...
		
		  //• Sending Mobile device application: Slack
		  //[error] The API returned a "409" error when we tried to add this item.
		  //[info] This usually happens when the XML contains a reference to some other
		  //object (e.g. a site) that doesn't exist on the target Jamf Pro or when
		  //the API is enforcing some other validity check.
		  //[operation] POST to https: //o.jamfcloud.com/JSSResource/mobiledeviceapplications/id/0
		  //[API message] Conflict Error: App is not available for device assignment
		
	: ($vt_API_Endpoint_Name="healthcarelistenerrule")
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy healthcare listener rules yet"+<>CRLF
		
		  // These have post and put
		
		  // But it has no get by name, so you can't check for duplicate name conflicts that way. 
		  // Or maybe there's no restriction on name uniqueness? 
		  // We can skip them for now
		
	: ($vt_API_Endpoint_Name="patchsoftwaretitles")
		  // This fails on get by name so you get a 404 back when you check and it looks like the record does not exist. 
		  // Then you post the record and get a 409 back because it actually does and name is unique constrained
		  // E.g. https://my.jamfcloud.com/JSSResource/patchsoftwaretitles/name/Adobe%20Acrobat%20DC%20Classic%20Track
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy patch titles yet"+<>CRLF
		
	: ($vt_API_Endpoint_Name="Patch policies")
		  // Conflict Error: Invalid Software Title Configuration Id
		$vb_skipThisItem:=True:C214
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy patch policies yet"+<>CRLF
		
		
		
End case 

$0:=$vb_skipThisItem