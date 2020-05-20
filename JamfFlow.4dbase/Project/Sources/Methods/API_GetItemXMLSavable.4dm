//%attributes = {}
  // API_GetItemXMLSavable

$vt_selectedSourceServer:=$1
$vt_SelectedItemType:=$2
$vl_selectedItemID:=$3
$vb_skipItemsWithIssues:=$4

C_TEXT:C284($vt_xml)
$vt_xml:=""
C_TEXT:C284($vt_API_Unique_Item_Name)
$vt_API_Unique_Item_Name:=""

$vb_goodToGo:=True:C214
$vt_errorMessage:=""

C_OBJECT:C1216($vo_API_GetItemXML)
$vo_API_GetItemXML:=API_GetItemXML ($vt_selectedSourceServer;$vt_SelectedItemType;$vl_selectedItemID)

Case of 
	: (vl_Error=0)
		  // vt_savedItemsSummary:=vt_savedItemsSummary+"API call to "+$vt_selectedSourceServer+" succeeded."
	: (vl_Error=30)
		$vb_goodToGo:=False:C215
		$vt_errorMessage:=$vt_errorMessage+"[error][Network-30] Could not reach the server for "+$vt_selectedSourceServer+". Check network connection and host name."
	Else 
		$vb_goodToGo:=False:C215
		$vt_errorMessage:=$vt_errorMessage+"[error] API call to "+$vt_selectedSourceServer+" returned error "+String:C10(vl_Error)+"."
End case 

If ($vb_goodToGo)
	  // Fetch info from response object...
	$vt_xml:=$vo_API_GetItemXML.XML
	$vl_httpStatusCode:=$vo_API_GetItemXML.httpStatusCode
	$vt_URL:=$vo_API_GetItemXML.URL
	CLEAR VARIABLE:C89($vo_API_GetItemXML)
	
	If ($vl_httpStatusCode#200)
		$vb_goodToGo:=False:C215
		$vt_errorMessage:=$vt_errorMessage+"[error] API call to "+$vt_URL+" returned http response code "+String:C10($vl_httpStatusCode)+<>CRLF
	End if   // If ($httpStatusCode#200)
End if 

If ($vb_goodToGo)
	If ($vt_xml="")
		$vb_goodToGo:=False:C215
		$vt_errorMessage:=$vt_errorMessage+"[error] API call to "+$vt_URL+" returned without error but did not supply any XML"+<>CRLF
	End if   // If ($XML="")
End if 

If ($vb_goodToGo)
	
	  // Parse the XML
	
	  // We have an issue with our XML for /computerreports that makes it unparsable. 
	  // An XML tag cannot contain a ":"
	  // -:1: namespace error : Namespace prefix Enrollment_Method on _PreStage_enrollment
	  // _Check_in><Full_Name>User Pro</Full_Name><Enrollment_Method:_PreStage_enrollment
	
	Case of 
		: ($vt_SelectedItemType="Computer Report")
			$vt_xml:=Replace string:C233($vt_xml;"Enrollment_Method:";"Enrollment_Method")
	End case 
	
	C_TEXT:C284($vt_xmlRootElementReference)
	ON ERR CALL:C155("sh_err_call")
	$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
	ON ERR CALL:C155("")
	If (OK=0)
		$vb_goodToGo:=False:C215
		$vt_errorMessage:=$vt_errorMessage+"[error] An API GET returned XML but I could not parse it."+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+"[type]"+$vt_SelectedItemType
		$vt_errorMessage:=$vt_errorMessage+"[URL]"+$vt_URL+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+"-------------------- XML --------------------"+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+$vt_xml+<>CRLF
	End if 
End if 


If ($vb_goodToGo)
	  // We were able to parse the xml
	
	
	
End if 



If ($vb_goodToGo)
	  // Do any of the data types require additional pruning to produce POST-able XML? 
	  // Smart groups should have their members pruned so they recalculate on the target server.
	
	  // Find out if it is a smart group
	Case of 
		: ($vt_SelectedItemType="Mobile device groups")
			$vt_xpath:="/mobile_device_group/is_smart"
		: ($vt_SelectedItemType="Computer groups")
			$vt_xpath:="/computer_group/is_smart"
		: ($vt_SelectedItemType="User groups")
			$vt_xpath:="/user_group/is_smart"
		Else 
			$vt_xpath:=""
	End case   // Entity-specific xml pruning
	
	If ($vt_xpath#"")
		ON ERR CALL:C155("sh_err_call")
		$vt_elementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpath)
		If (vl_error#0)
			$vb_goodToGo:=False:C215
			vt_savedItemsSummary:=vt_savedItemsSummary+"[error] Could not find the smart/static group flag in the xml."
			$vt_errorMessage:=$vt_errorMessage+"-------------------- XML --------------------"+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+$vt_xml+<>CRLF
			LogMessage (Current method name:C684;Current method path:C1201;"XML Parse";"warning";"Error finding issmart element")
		Else 
			DOM GET XML ELEMENT VALUE:C731($vt_elementRef;$vt_isSmart_TF)
			If (vl_error#0)
				$vb_goodToGo:=False:C215
				$vt_errorMessage:=$vt_errorMessage+"[error] Could not get value of the is_smart element"+<>CRLF
				$vt_errorMessage:=$vt_errorMessage+"-------------------- XML --------------------"+<>CRLF
				$vt_errorMessage:=$vt_errorMessage+$vt_xml+<>CRLF
			Else 
				Case of 
					: ($vt_isSmart_TF="true")
						  // Prune the device/user list
						Case of 
							: ($vt_SelectedItemType="Mobile device groups")
								$vt_xpath:="/mobile_device_group/mobile_devices"
							: ($vt_SelectedItemType="Computer groups")
								$vt_xpath:="/computer_group/computers"
							: ($vt_SelectedItemType="User groups")
								$vt_xpath:="/user_group/users"
							Else 
								$vt_xpath:=""
						End case   // Entity-specific xml pruning
						
						$vt_elementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpath)
						
						
						
					: ($vt_isSmart_TF="false")
						
						_4D:C1698
						  // @@@
						
					Else 
						$vb_goodToGo:=False:C215
						$vt_errorMessage:=$vt_errorMessage+"[error] Value of the is_smart element is expected to be either true or false"+<>CRLF
						$vt_errorMessage:=$vt_errorMessage+"-------------------- XML --------------------"+<>CRLF
						$vt_errorMessage:=$vt_errorMessage+$vt_xml+<>CRLF
				End case 
				
				
			End if 
		End if 
		ON ERR CALL:C155("")
	End if 
	
End if 

If ($vb_goodToGo)
	  // Get the unique name value for this item. Usually it's the same as the
	  // human readable, but for computers and mobile devices we use serial 
	  // number since more than one device can have the same name.
	  // We'll get the right field to use from the [Endpoints] table.
	
	  // We don't need to do this for singletons. 
	
	QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Plural_Name:2=$vt_SelectedItemType)
	If ([Endpoints:7]isSingleton:16=True:C214)
		$vt_API_Unique_Item_Name:="Singleton"
	Else 
		$vt_API_Unique_Item_Name:=""
		$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;[Endpoints:7]xpath_to_lookup_by_Name:22)
		If (OK=1)
			DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_API_Unique_Item_Name)
		End if 
	End if 
	
	If ($vt_API_Unique_Item_Name="")
		$vb_goodToGo:=False:C215
		$vt_errorMessage:=$vt_errorMessage+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+"[ERROR] Could not find the unique name for an item"+<>CRLF
		If ($vt_SelectedItemType="Mobile devices")
			$vt_errorMessage:=$vt_errorMessage+"[INFO] In the case of personally-owned mobile devices, we don't"+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+"know the device serial number so we can't upload the device to"+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+"another Jamf Pro."+<>CRLF
		Else 
			$vt_errorMessage:=$vt_errorMessage+"[INFO] Each Jamf Pro record needs to have a unique name so"+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+"we can check if it exists when we deply it to a target server."+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+"In most cases, the API will refuse to import any items that don't"+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+"have the required fields. For example, all policies need to have"+<>CRLF
			$vt_errorMessage:=$vt_errorMessage+"a name and all devices need to have a serial number."+<>CRLF
		End if 
		$vt_errorMessage:=$vt_errorMessage+"[ITEM TYPE] "+$vt_SelectedItemType+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+"[XPATH] "+[Endpoints:7]xpath_to_lookup_by_Name:22+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+"================== START XML =================="+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+$vt_xml+<>CRLF
		$vt_errorMessage:=$vt_errorMessage+"=================== END XML ==================="+<>CRLF+<>CRLF
	End if 
End if 

If ($vb_goodToGo)
	  // Pass the xml object back to text so we have pretty-print formatting
	DOM EXPORT TO VAR:C863($vt_xmlRootElementReference;$vt_xml)
	$vt_xmlHeader:="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\n"
	$vt_xml:=Replace string:C233($vt_xml;$vt_xmlHeader;"")
	$vt_xmlHeader:="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\r"
	$vt_xml:=Replace string:C233($vt_xml;$vt_xmlHeader;"")
End if   // If ($xml_rootElementRef="") Able to parse...




If (Not:C34($vb_goodToGo))
	$vt_xml:=""  // If there was an error, set xml to blank. This will indicate to the calling method that there was an error and the item should not be saved. 
	vt_savedItemsSummary:=vt_savedItemsSummary+$vt_errorMessage
	LogMessage (Current method name:C684;Current method path:C1201;"Import>GetXMLSavable";"HTTP-XML";$vt_errorMessage)
	  // sh_msg_Alert ("There was an issue obtaining the XML for an item. Please see the transcript for more information.")
	If (Not:C34($vb_skipItemsWithIssues))  // The haven't yet told us what they want to do when we hit a snag.
		$vb_yes:=sh_msg_Alert ("There was an issue obtaining the XML for an item. Do you want me to just skip over these items or stop?";"Skip";"Stop")
		$vb_skipItemsWithIssues:=$vb_yes
	End if 
End if 

C_OBJECT:C1216($o_xmlInfo)
OB SET:C1220($o_xmlInfo;"vt_xml";$vt_xml;"vt_API_Unique_Item_Name";$vt_API_Unique_Item_Name;"vb_goodToGo";$vb_goodToGo;"vb_skipItemsWithIssues";$vb_skipItemsWithIssues)

If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
	DOM CLOSE XML:C722($vt_xmlRootElementReference)
End if 

$0:=$o_xmlInfo

  //When saving, you will get a 409 if there is a duplicate 
  // UDID -- can test with GET /computers/udid/{udid}
  // Serial Number
  // MAC Address/Alternate

  //<p>Error: Duplicate UDID</p>
  //<p>Error: Duplicate serial number</p>
  //<p>Error: Duplicate MAC address</p>
  //<p>Error: Duplicate alternate MAC address</p>


  //<p>Error: Management password is required</p>
  // GET Provides this...
  // <remote_management>
  //  <managed>True</managed>
  //  <management_username>radmin</management_username>
  //  <management_password_sha256 since="9.23">8dd068501f2426db7f35dee3ade944f01363fa9ec0b3315e0de18f3a64663994</management_password_sha256>
  // </remote_management>

  // Needs to be written as this... (will have to prompt for password)
  //<computer>
  // <general>
  //  <remote_management>
  //   <management_password>Password</management_password>
  //  </remote_management>
  // </general>
  //</computer>




  // Could have a feature to randomize the UDID



  //[debug]HTTP_Status : 409
  //[debug]requestResponse :<html>
  //<head>
  //<title>Status page</title>
  //</head>
  //<body style="font-family: sans-serif;">
  //<p style="font-size: 1.2em;font-weight: bold;margin: 1em 0px;">Conflict</p>
  //<p>Error: Duplicate UDID</p>
  //<p>You can get technical details<a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.10">here</a>.<br>
  //Please continue your visit at our<a href="/">home page</a>.
  //</p>
  //</body>
  //</html>

  //[debug]HTTP_Status : 409
  //[debug]requestResponse :<html>
  //<head>
  //<title>Status page</title>
  //</head>
  //<body style="font-family: sans-serif;">
  //<p style="font-size: 1.2em;font-weight: bold;margin: 1em 0px;">Conflict</p>
  //<p>Error: Duplicate serial number</p>
  //<p>You can get technical details<a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.10">here</a>.<br>
  //Please continue your visit at our<a href="/">home page</a>.
  //</p>
  //</body>
  //</html>
