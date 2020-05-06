For ($i;Size of array:C274(ab_settings_cmdHx_Rows_isSelctd);1;-1)
	If (ab_settings_cmdHx_Rows_isSelctd{$i})
		DELETE FROM ARRAY:C228(at_setting_cmds;$i)
		DELETE FROM ARRAY:C228(at_settings_stdouts;$i)
	End if 
End for 

For ($i;1;Size of array:C274(ab_settings_cmdHx_Rows_isSelctd))
	ab_settings_cmdHx_Rows_isSelctd{$i}:=False:C215
End for 

