//%attributes = {}
  // get_ItemDetailURL
  // get_ItemDetailURL ($vt_jssURL;$vt_ItemType;$vl_itemID)

$vt_jssURL:=$1
$vt_ItemType:=$2
$vl_itemID:=$3

$vt_ItemTypeSubURL:="/"+Lowercase:C14(Replace string:C233($vt_ItemType;" ";""))+".html?id="

$0:=$vt_jssURL+$vt_ItemTypeSubURL+String:C10($vl_itemID)



  //QUERY([Endpoints];[Endpoints]Human_Readable_Plural_Name=$vt_itemType)
  //$vt_url:=[Endpoints]Detail_Web_Page
  //If ($vt_itemJssID#"0")
  //$vt_url:=Replace string($vt_url;"{id}";$vt_itemJssID)
  //End if 
  //If ($vt_url#"")
  //$vt_url:=$vt_selectedSourceServer+$vt_url
  //End if