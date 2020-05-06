Case of 
	: (Form event code:C388=On Clicked:K2:4)
		
		  // Clear the listing arrays
		ARRAY TEXT:C222(at_sourceItemLB_types;0)
		ARRAY LONGINT:C221(al_sourceItemLB_IDs;0)
		ARRAY TEXT:C222(at_sourceItemLB_Names;0)
		  // Clear the search box
		vt_SourceItemSearch:=""
		  // Reset the Data Type popup menu
		SELECT LIST ITEMS BY POSITION:C381(vl_selectSourceData;Count list items:C380(vl_selectSourceData))
		vt_selectSourceData:=""
		
End case 
