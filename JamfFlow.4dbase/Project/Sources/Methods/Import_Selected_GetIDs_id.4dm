//%attributes = {}
  // Import_Selected_GetIDs_id

  // We have an ID reference in an XML for some object. 
  // That means there's a dependency on something. 
  // To add it to the list of selected items, we need: 
  // 1. The id number ("3")
  // 2. The type of object ("Packages")
  // 3. The name of the object ("Microsoft Office 2030.pkg")

  // Ideally, we'd be able to pluck all that right out of this item's XML, but there are lots of exceptions we'll need to handle. 

$vt_xmlElementRef:=$1
$vt_idElementValue:=$2
$vt_RootObjectInfo:=$3

  // Get some info so we know what we're dealing with. 
C_TEXT:C284($vt_xmlElementXpath)
$vt_xmlElementXpath:=sh_xml_getXpath ($vt_xmlElementRef;"")  // Initially pass "" -- this method is re-entrant


  // $vt_xmlElementParentName represents the parent object of this ID. 
  // Typically we can just replace the "_" with spaces and capitalize to make it 
  // pretty and that's it, but there are some remappings we need to handle for oddballs 
C_TEXT:C284($vt_xmlElementParentName)
$vt_parentElementRef:=DOM Get parent XML element:C923($vt_xmlElementRef;$vt_xmlElementParentName)  // Get its parent (what kind of ID is this?)
Case of   // Some items need mapping
	: ($vt_xmlElementParentName="Binding")
		$vt_xmlElementParentName:="Directory Binding"
	: ($vt_xmlElementXpath="/mobile_device/extension_attributes/extension_attribute/id")
		$vt_xmlElementParentName:="Mobile Device Extension Attribute"
	: ($vt_xmlElementXpath="/computer/extension_attributes/extension_attribute/id")
		$vt_xmlElementParentName:="Computer Extension Attribute"
	: ($vt_xmlElementXpath="/computer/configuration_profiles/configuration_profile/id")
		$vt_xmlElementParentName:="OS X configuration profile"
End case 
$vt_pluralUpperParentName:=sh_str_getPluralUpperForm ($vt_xmlElementParentName)  // Human-readable version

If ($vt_pluralUpperParentName="Configuration profiles")
	TRACE:C157
End if 

  // Get the name to go along with this ID

  // Step 1: Do we need to skip this? 
  // ====================================================
  // There are some IDs we need to skip because... 
  // - They're an internal reference to the item itself, e.g. /policy will have /policy/general/id
  // - There's no endpoint to get the item's XML, so we're never going to be able to import it. e.g. self-service icons
  // - They are LDAP Users and Groups -- the API does not expose detail on these
  // ====================================================
  // Step 2: Does this item use something other than name to identify itself? 
Case of 
	: ($vt_xmlElementParentName="general")  // This ID is a reference the selected item itself. Skip it. E.g. /policy/general/id
		$vt_tagToUseForName:="SKIP"
	: ($vt_xmlElementParentName="self_service_icon")
		$vt_tagToUseForName:="SKIP"
		  //vt_SkippedIcons:=vt_SkippedIcons+"(item) "+$vt_RootObjectInfo+<>CRLF
		  //vt_SkippedIcons:=vt_SkippedIcons+"(uses) "+$vt_nameElementValue+<>CRLF //ID="+$vt_idElementValue+" Name="+"[xpath] "+$vt_xmlElementXpath
		  //DOM EXPORT TO VAR($vt_parentElementRef;$vt_ElementXML)
		  //vt_SkippedIcons:=vt_SkippedIcons+Replace string($vt_ElementXML;"\r\r";"\r")+<>CRLF
		
		  // /mac_application/self_service/self_service_icon/id
		  // /mobile_device_application/self_service/self_service_icon/id
		  // /policy/self_service/self_service_icon/id
	: ($vt_xmlElementParentName="icon")
		$vt_tagToUseForName:="SKIP"
		  //vt_SkippedIcons:=vt_SkippedIcons+"(item) "+$vt_RootObjectInfo+<>CRLF
		  //vt_SkippedIcons:=vt_SkippedIcons+"(uses) "+$vt_nameElementValue+<>CRLF
		  // /mobile_device_application/self_service/self_service_icon/id
		  // /mobile_device_application/general/icon/id
	: (($vt_xmlElementParentName="user_group") & (Length:C16($vt_idElementValue)>4))
		$vt_tagToUseForName:="SKIP"
		  //vt_SkippedIcons:=vt_SkippedIcons+"(item) "+$vt_RootObjectInfo+<>CRLF
		  //vt_SkippedIcons:=vt_SkippedIcons+"(uses) "+$vt_nameElementValue+<>CRLF
	: ($vt_xmlElementParentName="connection")
		$vt_tagToUseForName:="SKIP"
		  //vt_SkippedIcons:=vt_SkippedIcons+"(item) "+$vt_RootObjectInfo+<>CRLF
		  //vt_SkippedIcons:=vt_SkippedIcons+"(uses) "+$vt_nameElementValue+<>CRLF
		  // /ldap_server/connection/id
	: ($vt_xmlElementXpath="allowed_file_extension")
		$vt_tagToUseForName:="extension"
	: ($vt_xmlElementXpath="computer_reports")
		$vt_tagToUseForName:="Computer_Name"
	: ($vt_xmlElementXpath="/computer/configuration_profiles/configuration_profile/id")  // Oddball. Frequently will not have a name, sometimes does. 
		$vt_tagToUseForName:="name"
	Else 
		$vt_tagToUseForName:="name"
End case 


If ($vt_tagToUseForName="SKIP")
	$vt_nameElementValue:="n/a"
Else 
	ON ERR CALL:C155("sh_err_call")  // A few things will never have any name. But most will. 
	$vt_idNameElementRef:=DOM Get XML element:C725($vt_parentElementRef;"name";1;$vt_nameElementValue)
	ON ERR CALL:C155("")
	If (OK#1)
		  //We'll need to make up a name
		$vt_nameElementValue:=sh_str_getSingularForm (sh_str_getPluralUpperForm ($vt_xmlElementParentName))+" #"+$vt_idElementValue
		If (Not:C34($vt_xmlElementXpath="/computer/configuration_profiles/configuration_profile/id"))  // profile names in computer records happen so often it's not even worth loggging. 
			vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
			vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] I couldn't find a name for this item."+<>CRLF
			vt_selectedItemsSummary:=vt_selectedItemsSummary+$vt_nameElementValue+<>CRLF
			vt_selectedItemsSummary:=vt_selectedItemsSummary+"XPath: "+$vt_xmlElementXpath+<>CRLF
			vt_selectedItemsSummary:=vt_selectedItemsSummary+"ID="+$vt_idElementValue+" Name="+$vt_nameElementValue+<>CRLF
			DOM EXPORT TO VAR:C863($vt_parentElementRef;$vt_ElementXML)
			vt_selectedItemsSummary:=vt_selectedItemsSummary+Replace string:C233($vt_ElementXML;"\r\r";"\r")+<>CRLF
		End if 
	End if 
End if 

If ($vt_tagToUseForName="SKIP")
	  // Could log something for the skipped items. 
	If ($vt_xmlElementParentName#"general")
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"[xpath] "+$vt_xmlElementXpath+<>CRLF
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"ID="+$vt_idElementValue+" Name="+$vt_nameElementValue+<>CRLF
		  //DOM EXPORT TO VAR($vt_parentElementRef;$vt_ElementXML)
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+Replace string($vt_ElementXML;"\r\r";"\r")+<>CRLF
	End if 
Else 
	APPEND TO ARRAY:C911(at_importSelectedID_Types;$vt_pluralUpperParentName)
	APPEND TO ARRAY:C911(al_importSelectedID_IDs;Num:C11($vt_idElementValue))
	APPEND TO ARRAY:C911(at_importSelectedID_Names;$vt_nameElementValue)
End if 














  //  // Import_Selected_GetIDs_id

  //  // We have an ID reference in an XML for some object. 
  //  // That means there's a dependency on something. 
  //  // To add it to the list of selected items, we need: 
  //  // 1. The id number ("3")
  //  // 2. The type of object ("Packages")
  //  // 3. The name of the object ("Microsoft Office 2030.pkg")

  //$vt_xmlElementRef:=$1

  //  // Get its parent (what kind of ID is this?)
  //C_TEXT($vt_xmlElementParentName)
  //$vt_parentElementRef:=DOM Get parent XML element($vt_xmlElementRef;$vt_xmlElementParentName)
  //  // Get the name of the item associated with this ID. (Like the device name, group name, etc.)
  //  // Most things use a "name" tag for this. Case statement will handle oddballs 
  //C_TEXT($vt_nameElementValue)
  //Case of 
  //: ($vt_xmlElementParentName="self_service_icon")
  //  // We have a problem with this one. It may appear in computer and mobile device profiles, mobile device apps, and policies
  //  // But it may have a different structure in each of these. 
  //$vt_xmlElementRef_Prnt:=DOM Get parent XML element($vt_xmlElementRef;$vt_prntElemName)
  //$vt_xmlElementRef_PrntPrnt:=DOM Get parent XML element($vt_xmlElementRef_Prnt;$vt_prntPrntElemName)
  //$vt_xmlElementRef_PrntPrntPrnt:=DOM Get parent XML element($vt_xmlElementRef_PrntPrnt;$vt_prntPrntPrntElemName)
  //  // mac_application > self_service > self_service_icon

  //Case of 
  //: ($vt_prntPrntPrntElemName="mac_application")
  //  //<self_service_icon>
  //  //<id>244</id>
  //  //<uri>https:  //trial.jamfcloud.com//iconservlet/?id=244</uri>
  //  //<data>iVBORw0K...
  //  //</self_service_icon>
  //$vt_idNameElementRef:=DOM Get XML element($vt_parentElementRef;"uri";1;$vt_nameElementValue)
  //Else 
  //$vt_idNameElementRef:=DOM Get XML element($vt_parentElementRef;"filename";1;$vt_nameElementValue)
  //End case 

  //: ($vt_xmlElementParentName="allowed_file_extension")
  //$vt_idNameElementRef:=DOM Get XML element($vt_parentElementRef;"extension";1;$vt_nameElementValue)
  //: ($vt_xmlElementParentName="computer_reports")
  //$vt_idNameElementRef:=DOM Get XML element($vt_parentElementRef;"Computer_Name";1;$vt_nameElementValue)
  //Else 
  //$vt_idNameElementRef:=DOM Get XML element($vt_parentElementRef;"name";1;$vt_nameElementValue)
  //End case 

  //  // There are some IDs we won't consider as dependencies because 
  //  // - They're an internal reference to the item itself, e.g. /policy will have /policy/general/id
  //  // - There's no endpoint to get the item's XML to import, e.g. self-service icons
  //  // - They are LDAP Users and Groups -- the API does not expose detail on these
  //C_TEXT($vt_xmlElementXpath)
  //$vt_xmlElementXpath:=""
  //$vt_xmlElementXpath:=sh_xml_getXpath ($vt_xmlElementRef;$vt_xmlElementXpath)  // Initially pass "" -- this method is re-entrant
  //Case of 
  //: ($vt_xmlElementParentName="general")
  //  // This ID is a reference the selected item itself. Skip it. 
  //  // /policy/general/id
  //: ($vt_xmlElementParentName="self_service_icon")
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] Unhandled Self Service Icon item: "+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"XPath: "+$vt_xmlElementXpath+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"ID="+$vt_idElementValue+" Name="+$vt_nameElementValue+<>CRLF
  //: (($vt_xmlElementParentName="user_group") & (Length($vt_idElementValue)>4))
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"[warn] Unhandled LDAP User Group item: "+$vt_xmlElementXpath+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"ID="+$vt_idElementValue+" Name="+$vt_nameElementValue+<>CRLF
  //: ($vt_xmlElementParentName="icon")
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] Unhandled Icon item: "+$vt_xmlElementXpath+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"ID="+$vt_idElementValue+" Name="+$vt_nameElementValue+<>CRLF
  //DOM EXPORT TO VAR($vt_parentElementRef;$vt_ElementXML)
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+Replace string($vt_ElementXML;"\r\r";"\r")+<>CRLF
  //: ($vt_xmlElementParentName="connection")
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] Unhandled LDAP Connection item: "+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"XPath: "+$vt_xmlElementXpath+<>CRLF
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+"ID="+$vt_idElementValue+" Name="+$vt_nameElementValue+<>CRLF
  //DOM EXPORT TO VAR($vt_parentElementRef;$vt_ElementXML)
  //vt_selectedItemsSummary:=vt_selectedItemsSummary+Replace string($vt_ElementXML;"\r\r";"\r")+<>CRLF
  //Else 
  //Case of 
  //: ($vt_xmlElementParentName="Binding")
  //$vt_xmlElementParentName:="Directory Binding"
  //: ($vt_xmlElementXpath="/mobile_device/extension_attributes/extension_attribute/id")
  //  // Extension attributes appear in device xml as just "extension_attribute" but the endpoint 
  //  //  is either /computerextensionattributes or /mobiledeviceextensionattributes. 
  //  // You have to look at the full path to tell. 
  //$vt_xmlElementParentName:="Mobile Device Extension Attribute"
  //: ($vt_xmlElementXpath="/computer/extension_attributes/extension_attribute/id")
  //  // Extension attributes appear in device xml as just "extension_attribute" but the endpoint 
  //  //  is either /computerextensionattributes or /mobiledeviceextensionattributes. 
  // You have to look at the full path to tell. 
  //$vt_xmlElementParentName:="Computer Extension Attribute"
  //End case 

  //$vt_pluralUpperParentName:=sh_str_getPluralUpperForm ($vt_xmlElementParentName)
  //APPEND TO ARRAY(at_importSelectedID_Types;$vt_pluralUpperParentName)
  //APPEND TO ARRAY(al_importSelectedID_IDs;Num($vt_idElementValue))
  //APPEND TO ARRAY(at_importSelectedID_Names;$vt_nameElementValue)
  //End case 
