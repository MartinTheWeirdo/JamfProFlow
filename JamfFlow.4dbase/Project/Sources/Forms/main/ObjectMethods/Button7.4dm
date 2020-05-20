Case of 
	: (Records in set:C195("$ListboxSetManageXML")>1)
		sh_msg_Alert ("Please highlight just one record")
	: (Records in set:C195("$ListboxSetManageXML")=0)
		sh_msg_Alert ("Please highlight a record you want to delete")
		
	: (Records in set:C195("$ListboxSetManageXML")=1)
		If (Macintosh option down:C545)
			$vb_Yes:=True:C214
		Else 
			$vt_msg:="Are you sure you want to delete the selected XML record?"
			$vb_Yes:=sh_msg_Alert ($vt_msg;"Yes";"No")
		End if 
		If ($vb_Yes)
			CREATE SET:C116([XML:2];"$pre")
			USE SET:C118("$ListboxSetManageXML")
			DELETE RECORD:C58([XML:2])
			USE SET:C118("$pre")
			CLEAR SET:C117("$pre")
		End if 
End case 

  //Case of 
  //: (Records in set("$set_ManageSetsListbox")>1)
  //sh_msg_Alert ("Please highlight just one record")
  //: (Records in set("$set_ManageSetsListbox")=0)
  //sh_msg_Alert ("Please highlight a record you want to delete")
  //: (Records in set("$set_ManageSetsListbox")=1)
  //$vt_msg:="Are you sure you want to delete the selected record?"
  //$vb_Yes:=sh_msg_Alert ($vt_msg;"Yes";"No")
  //If ($vb_Yes)
  //USE SET("$set_ManageSetsListbox")
  //QUERY([XML];[XML]set_id=[Sets]ID)
  //DELETE SELECTION([XML])
  //DELETE SELECTION([Sets])
  //End if 
  //ALL RECORDS([Sets])
  //End case 
