  //aSelectSourceServer Drop-down list Object Method
Case of 
	: (Form event code:C388=On Load:K2:1)
		ARRAY TEXT:C222(at_SelectSourceServer;0)
		Import_GetJamfProServerList (->at_SelectSourceServer)
		
	: (Form event code:C388=On Data Change:K2:15)
		  //They picked something new
		
		  // Reset the search box
		vt_SourceItemSearch:=""
		vl_lastMatchedUnselectedRow:=0
		
		  //Reset the list box
		ARRAY BOOLEAN:C223(ab_SourceItems_LB_SelectedRows;0)
		ARRAY TEXT:C222(at_sourceItemLB_types;0)
		ARRAY LONGINT:C221(al_sourceItemLB_IDs;0)
		ARRAY TEXT:C222(at_sourceItemLB_Names;0)
		  // Reset summary info
		vt_sourceSetSummary:=""
		  // Reset API headers box
		ARRAY TEXT:C222(at_httpHeader_Keys;0)
		ARRAY TEXT:C222(at_httpHeader_Values;0)
		  // Reset the Data Type popup menu
		
		  // Select the last item in the list -- its blank
		  // SELECT LIST ITEMS BY POSITION(vl_selectSourceData;Count list items(vl_selectSourceData))
		SELECT LIST ITEMS BY POSITION:C381(*;"SourceDataHierarcicalPopupMenu";Count list items:C380(*;"SourceDataHierarcicalPopupMenu"))
		
		vt_selectSourceData:=""
		  // SELECT LIST ITEMS BY POSITION(*;"ComboBox1";Count list items(*;"ComboBox1"))
		
		If (sh_arr_getCurrentValue (->at_SelectSourceServer)="Add a new server...")
			$vl_addServerWindowRef:=Open form window:C675("AddJamfProServer";Movable form dialog box:K39:8)
			SET WINDOW TITLE:C213("Add a Jamf Pro Server...";$vl_addServerWindowRef)
			DIALOG:C40("AddJamfProServer")
			CLOSE WINDOW:C154($vl_addServerWindowRef)
			Import_GetJamfProServerList (Self:C308)
		End if 
		
End case 
