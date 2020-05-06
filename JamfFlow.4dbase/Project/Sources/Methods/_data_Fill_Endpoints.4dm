//%attributes = {}
QUERY:C277([Endpoints:7];[Endpoints:7]Detail_XML_ID_Element_xpath:31="")
For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	
	Case of 
		: ([Endpoints:7]isSingleton:16)
			[Endpoints:7]Detail_XML_ID_Element_xpath:31:=""
			
		: ([Endpoints:7]xpath_to_displayed_Name:19="@/general/@")
			[Endpoints:7]Detail_XML_ID_Element_xpath:31:=[Endpoints:7]Detail_XML_Root_Element_xpath:5+"/general/id"
		Else 
			[Endpoints:7]Detail_XML_ID_Element_xpath:31:=[Endpoints:7]Detail_XML_Root_Element_xpath:5+"/id"
	End case 
	
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 

BEEP:C151
ABORT:C156








QUERY:C277([Endpoints:7];[Endpoints:7]xpath_to_lookup_by_Name:22="")
For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	[Endpoints:7]xpath_to_lookup_by_Name:22:=[Endpoints:7]xpath_to_displayed_Name:19
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 

BEEP:C151
ABORT:C156



QUERY:C277([Endpoints:7];[Endpoints:7]XML_UniquenessConstraint_Xpaths:17="@ @")
For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=Replace string:C233([Endpoints:7]XML_UniquenessConstraint_Xpaths:17;" ";"_")
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 

BEEP:C151
ABORT:C156



ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	[Endpoints:7]XML_UniquenessConstraint_URLs:18:=Replace string:C233([Endpoints:7]XML_UniquenessConstraint_URLs:18;"\n";"\r")
	[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=Replace string:C233([Endpoints:7]XML_UniquenessConstraint_Xpaths:17;"\n";"\r")
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 

BEEP:C151
ABORT:C156





  //
  // IMPORT HELPER FIELDS
  //

  // Paths to pull the item names out of a get to base endpoint
ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	
	
	$url:=""
	Case of 
		: ([Endpoints:7]API_Endpoint_Name:8="computercheckin")
			$url:="/view/settings/computer/checkIn"  // https://jamf.jamfcloud.com/view/settings/computer/checkIn
			
		: ([Endpoints:7]isSingleton:16=True:C214)
			Case of 
				: ([Endpoints:7]API_Endpoint_Name:8="computer@")
					$vt:=Replace string:C233([Endpoints:7]API_Endpoint_Name:8;"computer";"")
					$url:="/view/settings/computer/"+$vt  // https://jamf.jamfcloud.com/view/settings/computer/checkIn
				Else 
					$url:="/view/settings/"+[Endpoints:7]API_Endpoint_Name:8
			End case 
		Else 
			  //https://jamf.jamfcloud.com/computers.html?id=34&o=r
			  //https://jamf.jamfcloud.com/policies.html?id=36&o=r
			  //https://jamf.jamfcloud.com/OSXConfigurationProfiles.html?id=8&o=r
			$url:="/"+[Endpoints:7]API_Endpoint_Name:8+".html?id={id}"
			
	End case 
	
	If ($url#"")
		[Endpoints:7]Detail_Web_Page:4:=$url
		SAVE RECORD:C53([Endpoints:7])
	End if 
	NEXT RECORD:C51([Endpoints:7])
End for 

BEEP:C151
ABORT:C156





  //
  // IMPORT HELPER FIELDS
  //
  // Paths to pull the item names out of a get to base endpoint
ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	Case of 
		: ([Endpoints:7]isSingleton:16=True:C214)
			[Endpoints:7]Import_XPathToRootElement:26:=""
			[Endpoints:7]Import_XPathToItemElement:6:=""
			[Endpoints:7]Import_DisplayNameElementName:25:=""
		: ([Endpoints:7]API_Endpoint_Name:8="accounts")
			[Endpoints:7]Import_XPathToRootElement:26:="/accounts/users/"
			[Endpoints:7]Import_XPathToItemElement:6:="/accounts/users/user"
			[Endpoints:7]Import_DisplayNameElementName:25:="name"
		: ([Endpoints:7]API_Endpoint_Name:8="allowedfileextensions")
			[Endpoints:7]Import_XPathToRootElement:26:="/allowed_file_extensions/"
			[Endpoints:7]Import_XPathToItemElement:6:="/allowed_file_extensions/allowed_file_extension"
			[Endpoints:7]Import_DisplayNameElementName:25:="extension"
		Else 
			$vt2:=[Endpoints:7]Detail_XML_Root_Element_xpath:5
			$vt2:=sh_str_getPluralUpperForm ($vt2)
			$vt2:=Replace string:C233($vt2;" ";"_")
			$vt2:=Lowercase:C14($vt2)
			[Endpoints:7]Import_XPathToRootElement:26:=$vt2
			[Endpoints:7]Import_XPathToItemElement:6:=$vt2+[Endpoints:7]Detail_XML_Root_Element_xpath:5
			[Endpoints:7]Import_DisplayNameElementName:25:="name"
	End case 
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 

BEEP:C151
ABORT:C156







ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	
	If (Locked:C147([Endpoints:7]))
		TRACE:C157
	End if 
	
	  // Singltons have no uniquness checks
	If ([Endpoints:7]isSingleton:16)
		[Endpoints:7]XML_UniquenessConstraint_URLs:18:=""
		[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=""
	Else 
		Case of 
			: ([Endpoints:7]API_Endpoint_Name:8="allowedfileextensions")
				[Endpoints:7]API_URL_to_lookup_by_Name:21:="/JSSResource/allowedfileextensions​/extension​/{extension}"
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:="/allowed_file_extension/extension"
			: ([Endpoints:7]API_Endpoint_Name:8="computers")
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=""
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/computers​/serialnumber​/{serialnumber}/subset/general"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/computers/udid/{udid}/subset/general"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/computers/macaddress/{macaddress}/subset/general"
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=""
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/computer/general/serial_number"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/computer/general/mac_address"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/computer/general/udid"
			: ([Endpoints:7]API_Endpoint_Name:8="mobiledevices")
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=""
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/mobiledevices​/serialnumber​/{serialnumber}/subset/general"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/mobiledevices/udid/{udid}/subset/general"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/mobiledevices/macaddress/{macaddress}/subset/general"
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=""
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/mobile_device/general/serial_number"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/mobile_device/general/mac_address"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/mobile_device/general/udid"
			: ([Endpoints:7]API_Endpoint_Name:8="users")
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=""
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/users/name/{name}"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:=[Endpoints:7]XML_UniquenessConstraint_URLs:18+"/JSSResource/users/email/{email}"
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=""
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/user/name"+<>CRLF
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+"/user/email"
			Else 
				[Endpoints:7]XML_UniquenessConstraint_URLs:18:="/JSSResource/"+[Endpoints:7]API_Endpoint_Name:8+"/name"
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:="/"+Lowercase:C14([Endpoints:7]Human_Readable_Singular_Name:3)+"/name"
		End case 
	End if 
	
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 




ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	
	
	If ([Endpoints:7]isSingleton:16)
		[Endpoints:7]API_URL_to_lookup_by_Name:21:="/JSSResource/"+[Endpoints:7]API_Endpoint_Name:8
		[Endpoints:7]API_URL_to_lookup_by_id:23:="/JSSResource/"+[Endpoints:7]API_Endpoint_Name:8
	Else 
		
		[Endpoints:7]API_URL_to_lookup_by_id:23:="/JSSResource/"+[Endpoints:7]API_Endpoint_Name:8+"/"+"id"+"/{id}"
		
		Case of 
			: ([Endpoints:7]API_Endpoint_Name:8="allowedfileextensions")
				[Endpoints:7]API_URL_to_lookup_by_Name:21:="/JSSResource/allowedfileextensions​/extension​/{extension}"
			: ([Endpoints:7]API_Endpoint_Name:8="computers")
				[Endpoints:7]API_URL_to_lookup_by_Name:21:="/JSSResource/computers​/serialnumber​/{serialnumber}"
			: ([Endpoints:7]API_Endpoint_Name:8="mobiledevices")
				[Endpoints:7]API_URL_to_lookup_by_Name:21:="/JSSResource/mobiledevices​/serialnumber​/{serialnumber}"
			Else 
				[Endpoints:7]API_URL_to_lookup_by_Name:21:="/JSSResource/"+[Endpoints:7]API_Endpoint_Name:8+"/"+"name"+"/{name}"
		End case 
	End if 
	
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 



ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	Case of 
		: ([Endpoints:7]isSingleton:16)
			[Endpoints:7]API_URL_to_lookup_by_Name:21:="/"+[Endpoints:7]API_Endpoint_Name:8
		: ([Endpoints:7]API_Endpoint_Name:8="allowedfileextensions")
			[Endpoints:7]API_URL_to_lookup_by_Name:21:="/allowedfileextensions​/extension​/{extension}"
		: ([Endpoints:7]API_Endpoint_Name:8="computers")
			[Endpoints:7]API_URL_to_lookup_by_Name:21:="/computers​/serialnumber​/{serialnumber}"
		: ([Endpoints:7]API_Endpoint_Name:8="mobiledevices")
			[Endpoints:7]API_URL_to_lookup_by_Name:21:="/mobiledevices​/serialnumber​/{serialnumber}"
		Else 
			[Endpoints:7]API_URL_to_lookup_by_Name:21:="/"+[Endpoints:7]API_Endpoint_Name:8+"/"+"name"+"/{name}"
	End case 
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 



ALL RECORDS:C47([Endpoints:7])
For ($i;1;Records in selection:C76([Endpoints:7]))
	Case of 
		: ([Endpoints:7]isSingleton:16)
			[Endpoints:7]push priority:20:=10
		: ([Endpoints:7]API_Endpoint_Name:8="users")
			[Endpoints:7]push priority:20:=30
		: ([Endpoints:7]API_Endpoint_Name:8="Computers")
			[Endpoints:7]push priority:20:=90
		: ([Endpoints:7]API_Endpoint_Name:8="mobiledevices")
			[Endpoints:7]push priority:20:=90
		: ([Endpoints:7]API_Endpoint_Name:8="@groups")
			[Endpoints:7]push priority:20:=80
		Else 
			[Endpoints:7]push priority:20:=50
	End case 
	SAVE RECORD:C53([Endpoints:7])
	NEXT RECORD:C51([Endpoints:7])
End for 


ALL RECORDS:C47([Endpoints:7])

For ($i;1;Records in selection:C76([Endpoints:7]))
	[Endpoints:7]Detail_XML_Root_Element_xpath:5:="/"+Lowercase:C14([Endpoints:7]Human_Readable_Singular_Name:3)
	[Endpoints:7]Detail_XML_Root_Element_xpath:5:=Replace string:C233([Endpoints:7]Detail_XML_Root_Element_xpath:5;" ";"_")
	If (Not:C34([Endpoints:7]isSingleton:16))
		[Endpoints:7]Import_XPathToItemElement:6:="/"+Lowercase:C14([Endpoints:7]Human_Readable_Plural_Name:2)+"/"+Lowercase:C14([Endpoints:7]Human_Readable_Singular_Name:3)
		[Endpoints:7]Import_XPathToItemElement:6:=Replace string:C233([Endpoints:7]Import_XPathToItemElement:6;" ";"_")
		
		[Endpoints:7]xpath_to_displayed_Name:19:="/"+Lowercase:C14([Endpoints:7]Human_Readable_Singular_Name:3)+"/name"
		[Endpoints:7]xpath_to_displayed_Name:19:=Replace string:C233([Endpoints:7]xpath_to_displayed_Name:19;" ";"_")
		
		SAVE RECORD:C53([Endpoints:7])
	End if 
	NEXT RECORD:C51([Endpoints:7])
End for 



For ($i;1;Records in selection:C76([Endpoints:7]))
	If (Not:C34([Endpoints:7]isSingleton:16))
		Case of 
			: ([Endpoints:7]API_Endpoint_Name:8="allowedfileextensions")
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:="/allowedfileextensions​/extension​/{extension}"
			: ([Endpoints:7]API_Endpoint_Name:8="")
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:=""
			Else 
				[Endpoints:7]XML_UniquenessConstraint_Xpaths:17:="/"+[Endpoints:7]Human_Readable_Singular_Name:3+"/"+"name"+"/{name}"
		End case 
		SAVE RECORD:C53([Endpoints:7])
		NEXT RECORD:C51([Endpoints:7])
	End if 
End for 

  //[Jamf Pro Object Names]Human_Readable_Plural_Name:=Uppercase([Jamf Pro Object Names]API_Endpoint_Name[[1]])+Substring([Jamf Pro Object Names]API_Endpoint_Name;2)

  //$vt_string:=[Endpoints]Human_Readable_Plural_Name
  //$vl_len:=Length($vt_string)
  //Case of 
  //: (Substring($vt_string;$vl_len-2)="ies")
  //  // "Stories" to "Story"
  //$vt_string:=Substring($vt_string;1;$vl_len-3)+"y"
  //: (Substring($vt_string;$vl_len-3)="ches")
  //  // "Searches" to "Search"
  //$vt_string:=Substring($vt_string;1;$vl_len-2)
  //: (Substring($vt_string;$vl_len-2)="ses")
  //  // "Classes" to "Class"
  //$vt_string:=Substring($vt_string;1;$vl_len-2)
  //: (Substring($vt_string;$vl_len)="s")
  //  // "Hats" to "Hat"
  //$vt_string:=Substring($vt_string;1;$vl_len-1)
  //End case 
  //[Endpoints]Human_Readable_Singular_Name:=$vt_string


  // If it matches its singlular, it's a singleton
  //[Endpoints]isSingleton:=([Endpoints]Human_Readable_Singular_Name=[Endpoints]Human_Readable_Plural_Name)


  //[Jamf Pro Object Names]Has_Mathod_Delete:=True
  //[Jamf Pro Object Names]Has_Method_Get:=True
  //[Jamf Pro Object Names]Has_Method_Post:=True
  //[Jamf Pro Object Names]Has_Method_Put:=True
  //[Jamf Pro Object Names]XML_Instance_Element_Name
  //[Jamf Pro Object Names]XML_Root_Element_Name
  //[Jamf Pro Object Names]xpath_To_Scoping_SubElement
