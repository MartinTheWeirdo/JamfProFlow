//%attributes = {}
  // Import_SaveItemList_Anon_R_spec 
  // $vt_elementValue_anon:=Import_SaveItemList_Anon_R_spec ($vt_elementValue;$vt_Detail_XML_PII_Replacement)

$vt_elementValue:=$1
$vt_Detail_XML_PII_Replacement:=$2

  // Extract Value, hash it, prepend tag. So "Mary Smith" == username_ELKJLDKFH. 
  // Could be more intellegent for thing mike@jamf.com == email_SDw2345@company.com
  // If the xpath on the PII matches the display name xpath, then the human-readble name on the XML record will be anonymized as well. 

$vl_lengthOfDigestPlaceholder:=0
ARRAY LONGINT:C221($al_regexPositions;0)
ARRAY LONGINT:C221($al_regexLength;0)
$vb_digestRequired:=Match regex:C1019("(<digest-{0,1}(\\d{0,2})>)";$vt_Detail_XML_PII_Replacement;1;$al_regexPositions;$al_regexLength)
Case of 
		
	: ($vb_digestRequired)  // Set $vt_xmlElementReference value to anonymized $vt_elementValue
		
		If (Size of array:C274($al_regexPositions)=0)
			TRACE:C157  // Error 
		Else 
			$vt_digestPlaceHolderString:=Substring:C12($vt_Detail_XML_PII_Replacement;$al_regexPositions{1};$al_regexLength{1})
		End if 
		If (Size of array:C274($al_regexPositions)#2)
			$vl_digestTruncateChars:=10
		Else 
			$vl_digestTruncateChars:=Num:C11(Substring:C12($vt_Detail_XML_PII_Replacement;$al_regexPositions{2};$al_regexLength{2}))
		End if 
		If ($vl_digestTruncateChars=0)
			$vl_digestTruncateChars:=10
		End if 
		$vt_elementValue_digest:=Generate digest:C1147($vt_elementValue;MD5 digest:K66:1)
		$vt_elementValue_digest:=Substring:C12($vt_elementValue_digest;Length:C16($vt_elementValue_digest)-$vl_digestTruncateChars)
		$vt_elementValue_anon:=Replace string:C233($vt_Detail_XML_PII_Replacement;$vt_digestPlaceHolderString;$vt_elementValue_digest)
		
	Else 
		
		  // Not a digest field
		Case of 
			: ($vt_Detail_XML_PII_Replacement="<email>")
				  // test if there is an @ first. Then...
				$vl_positionOfAtSign:=Position:C15("@";$vt_elementValue)
				If ($vl_positionOfAtSign>0)
					$vt_emailUser:=Substring:C12($vt_elementValue;1;$vl_positionOfAtSign-1)
					$vt_emailHost:=Substring:C12($vt_elementValue;Position:C15("@";$vt_elementValue)+1)
					$vl_positionOfLastPeriod:=sh_str_positionOfLast (".";$vt_emailHost)
					If ($vl_positionOfLastPeriod>0)
						$vt_emailSubLevel:=Substring:C12($vt_emailHost;1;$vl_positionOfLastPeriod-1)  // email.jamf
						$vt_emailTopLevel:=Substring:C12($vt_emailHost;$vl_positionOfLastPeriod)  // .com
					Else 
						$vt_emailSubLevel:=$vt_emailHost
						$vt_emailTopLevel:=".com"
					End if 
					$vt_emailUser_anon:=Generate digest:C1147($vt_emailUser;MD5 digest:K66:1)  // "f8f9510f841b2dc7be26a3836c46c00e"
					$vt_emailSubLevel_anon:=Generate digest:C1147($vt_emailSubLevel;MD5 digest:K66:1)
					C_BLOB:C604($B_emailUser_anon;$B_emailSubLevel_anon)
					TEXT TO BLOB:C554($vt_emailUser_anon;$B_emailUser_anon;UTF8 text with length:K22:16)
					TEXT TO BLOB:C554($vt_emailSubLevel_anon;$B_emailSubLevel_anon;UTF8 text with length:K22:16)
					BASE64 ENCODE:C895($B_emailUser_anon;$vt_emailUser_anon)  // AAAAIGZmZGEyNzhlOWFjYTg2YzRkYjVmYzI1ODViMTQwMmVm
					BASE64 ENCODE:C895($B_emailSubLevel_anon;$vt_emailSubLevel_anon)
					$vt_emailSubLevel_anon:=Substring:C12($vt_emailSubLevel_anon;Length:C16($vt_emailSubLevel_anon)-10)
					$vt_emailUser_anon:=Substring:C12($vt_emailUser_anon;Length:C16($vt_emailUser_anon)-8)
					$vt_elementValue_anon:="user_"+$vt_emailUser_anon+"@"+$vt_emailSubLevel_anon+$vt_emailTopLevel
				Else 
					$vt_elementValue_anon:=Generate digest:C1147($vt_elementValue;MD5 digest:K66:1)
					$vt_elementValue_anon:="user_"+Substring:C12($vt_elementValue_anon;10;10)+"@org.org"
				End if 
				
			: ($vt_Detail_XML_PII_Replacement="<serial>")  // PPYWWSSSCCC
				$vt_elementValue_anon:=Generate digest:C1147($vt_elementValue;MD5 digest:K66:1)
				$vt_elementValue_anon:="sn_"+$vt_elementValue_anon
				
			: ($vt_Detail_XML_PII_Replacement="<mac>")  // AA:AA:AA:AA:AA:AA
				$vt:=Generate digest:C1147($vt_elementValue;MD5 digest:K66:1)
				  //TEXT TO BLOB($vt;$B;UTF8 text with length)
				  //BASE64 ENCODE($B;$vt)  // AAAAIGZmZGEyNzhlOWFjYTg2YzRkYjVmYzI1ODViMTQwMmVm
				$vt_elementValue_anon:="Z"+Substring:C12($vt;5;1)+":"+Substring:C12($vt;7;2)+":"+Substring:C12($vt;9;2)+":"+Substring:C12($vt;11;2)+":"+Substring:C12($vt;13;2)+":"+Substring:C12($vt;15;2)
				
			: ($vt_Detail_XML_PII_Replacement="<udid>")  // 99999999-9999-9999-9999-9999999999999. (8/4/4/4/13 = 33)
				$vt:=Generate digest:C1147($vt_elementValue;SHA1 digest:K66:2)  // 40 chars, hex
				  //TEXT TO BLOB($vt;$B;UTF8 text with length)
				  //BASE64 ENCODE($B;$vt)  // AAAAIGZmZGEyNzhlOWFjYTg2YzRkYjVmYzI1ODViMTQwMmVm (28 Alphnumeric chars)
				  // These should be unique and consistent so hopefully we have enough entropy on the hash. 
				  // Otherwise we'd break update imports because we have to match a target device record on serial or udid. 
				$vt_elementValue_anon:=Substring:C12($vt;4;8)+"-"+Substring:C12($vt;13;4)+"-"+Substring:C12($vt;18;4)+"-"+Substring:C12($vt;23;4)+"-"+Substring:C12($vt;27;13)
				
			: ($vt_Detail_XML_PII_Replacement="<ip>")  // These don't have to be unique
				$vt_elementValue_anon:="99.99.99.99"
				
			Else   // Just swap in the literal replacement 
				$vt_elementValue_anon:=$vt_Detail_XML_PII_Replacement
				
		End case 
		
End case 

$0:=$vt_elementValue_anon
