Case of 
	: (Form event code:C388=On Load:K2:1)
		ARRAY TEXT:C222(at_selectedItemsListBox_types;0)
		ARRAY LONGINT:C221(al_selectedItemsListBox_ids;0)
		ARRAY TEXT:C222(at_selectedItemsListBox_names;0)
		OBJECT SET RGB COLORS:C628(at_selectedItemsListBox_types;"Black";"LAVENDER")
		
	: (Form event code:C388=On Drag Over:K2:13)
		$0:=0
		
		  //C_POINTER($vp_srcObject)
		  //C_LONGINT($vl_srcElement)
		  //C_LONGINT($vl_srcProcess)
		  //DRAG AND DROP PROPERTIES($vp_srcObject;$vl_srcElement;$vl_srcProcess)
		  //$vt_SourceObjectName:=RESOLVE POINTER($vp_srcObject)
		
		  //If ($vt_SourceObjectName="ab_SourceItems_LB_SelectedRows")
		  //  // Accept the drag and drop if it is from the selectable items list box
		  //$0:=0
		  //Else 
		  //$0:=-1
		  //End if 
		
		
	: (Form event code:C388=On Drop:K2:12)
		
		  //ARRAY TEXT($signatures_at;0)
		  //ARRAY TEXT($nativeTypes_at;0)
		  //ARRAY TEXT($formatNames_at;0)
		  //GET PASTEBOARD DATA TYPE($signatures_at;$nativeTypes_at;$formatNames_at)
		  //If (Find in array($signatures_at;"com.4d.private.text.native")#-1)  // there is 4D text in pasteboard
		  //$vl_selectedItemID:=Num(Get text from pasteboard)
		  //End if 
		  //$vl_selectedItemID2:=vl_draggedItemID
		
		  //C_POINTER($vp_srcObject)
		  //C_LONGINT($vl_srcElement)
		  //C_LONGINT($vl_srcProcess)
		  //DRAG AND DROP PROPERTIES($vp_srcObject;$vl_srcElement;$vl_srcProcess)
		  //$vt_SourceObjectName:=RESOLVE POINTER($vp_srcObject)
		
		  //$w:=ab_SourceItems_LB_SelectedRows{$vl_srcElement}
		  //$x:=at_sourceItemLB_types{$vl_srcElement}
		  //$y:=al_sourceItemLB_IDs{$vl_srcElement}
		  //$z:=at_sourceItemLB_Names{$vl_srcElement}
		
		  //vt_selectedItemsSummary:=""
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+String($vl_selectedItemID)+Char(Carriage return)
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+String($vl_selectedItemID2)+Char(Carriage return)
		
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+String($w;"True;False")+char(Carriage return)
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+$x+char(Carriage return)
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+string($y)+char(Carriage return)
		  //vt_selectedItemsSummary:=vt_selectedItemsSummary+string($z)+char(Carriage return)
End case 

  //sourceItemsListBox
  //ab_SourceItems_LB_SelectedRows



  //APPEND TO ARRAY(at_sourceItemLB_Categories;$vt_SelectedSourceDataType)
  //APPEND TO ARRAY(al_sourceItemLB_IDs;Num($vt_id))
  //APPEND TO ARRAY(at_sourceItemLB_Names;$vt_name)


  //$al_selectedNumber:=al_sourceItemDisplay_IDs{$vl_RowNumber}
  //$at_SelectedName:=at_sourceItemDisplay_Names{$vl_RowNumber}
  //$vl_SourceDataPopupMenuItemPos:=Selected list items(aSelectSourceData)
  //GET LIST ITEM(aSelectSourceData;$vl_SourceDataPopupMenuItemPos;$vl_ItemRef;$vs_SubItemText;$hSublist;$vbExpanded)

  //x:=$al_selectedNumber
  //x:=$vs_SubItemText
  //x:=$at_SelectedName