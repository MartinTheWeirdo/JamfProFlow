//%attributes = {}
  // sh_http_urlEncode

C_TEXT:C284($1;$url;$0;$encoded)
C_TEXT:C284($2;$mode)

If (Count parameters:C259#0)
	
	$url:=$1
	
	If (Count parameters:C259>1)
		$mode:=$2
	Else 
		$mode:="RFC 3986 URI"
	End if 
	
	C_LONGINT:C283($i)
	C_BOOLEAN:C305($shouldEncode)
	C_BLOB:C604($data)
	
	For ($i;1;Length:C16($url))
		
		$char:=Substring:C12($url;$i;1)
		$code:=Character code:C91($char)
		
		$shouldEncode:=False:C215
		
		Case of 
			: ($mode="RFC 2396")
				
				Case of 
					: ($code=33)
						  // !
					: ($code>38) & ($code<43)
						  // ' ( ) *
					: ($code=45)
						  // -
					: ($code=46)
						  // .
					: ($code>47) & ($code<58)
						  // 0 1 2 3 4 5 6 7 8 9
					: ($code>64) & ($code<91)
						  // A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
					: ($code=95)
						  // _
					: ($code>96) & ($code<123)
						  // a b c d e f g h i j k l m n o p q r s t u v w x y z
					: ($code=126)
						  // ~
					Else 
						$shouldEncode:=True:C214
				End case 
				
			: ($mode="RFC 3986")
				
				Case of 
					: ($code=45)
						  // -
					: ($code=46)
						  // .
					: ($code>47) & ($code<58)
						  // 0 1 2 3 4 5 6 7 8 9
					: ($code>64) & ($code<91)
						  // A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
					: ($code=95)
						  // _
					: ($code>96) & ($code<123)
						  // a b c d e f g h i j k l m n o p q r s t u v w x y z
					: ($code=126)
						  // ~
					Else 
						$shouldEncode:=True:C214
				End case 
				
			: ($mode="RFC 2396 URI")
				
				Case of 
						
					: ($code=33)
						  // !
					: ($code=36)
						  // $
						$shouldEncode:=True:C214
					: ($code=38)
						  // &
						$shouldEncode:=True:C214
					: ($code>38) & ($code<43)
						  // ' ( ) *
					: ($code>42) & ($code<48)
						  // + , - . /
						$shouldEncode:=True:C214
					: ($code>47) & ($code<58)
						  // 0 1 2 3 4 5 6 7 8 9
					: ($code=58)
						  // :
						$shouldEncode:=True:C214
					: ($code=59)
						  // ;
						$shouldEncode:=True:C214
					: ($code=61)
						  // =
						$shouldEncode:=True:C214
					: ($code=63)
						  // ?
						$shouldEncode:=True:C214
					: ($code=64)
						  // @
						$shouldEncode:=True:C214
					: ($code>64) & ($code<91)
						  // A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
					: ($code=95)
						  // _
					: ($code>96) & ($code<123)
						  // a b c d e f g h i j k l m n o p q r s t u v w x y z
					: ($code=126)
						  // ~
					Else 
						$shouldEncode:=True:C214
				End case 
				
			: ($mode="RFC 3986 URI")
				
				Case of 
					: ($code=36)
						  // $
					: ($code=38)
						  // &
					: ($code=43)
						  // +
						$shouldEncode:=True:C214
					: ($code>42) & ($code<48)
						  // + , - . /
						$shouldEncode:=True:C214
					: ($code>47) & ($code<58)
						  // 0 1 2 3 4 5 6 7 8 9
					: ($code=58)
						  // :
					: ($code=59)
						  // ;
					: ($code=61)
						  // =
					: ($code=63)
						  // ?
					: ($code=64)
						  // @
					: ($code>64) & ($code<91)
						  // A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
					: ($code=95)
						  // _
					: ($code>96) & ($code<123)
						  // a b c d e f g h i j k l m n o p q r s t u v w x y z
					: ($code=126)
						  // ~
					Else 
						$shouldEncode:=True:C214
				End case 
				
			: ($mode="WWW FORM")
				
				Case of 
					: ($code=32)
						
					: ($code=45)
						  // -
					: ($code=46)
						  // .
					: ($code>47) & ($code<58)
						  // 0 1 2 3 4 5 6 7 8 9
					: ($code>64) & ($code<91)
						  // A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
					: ($code=95)
						  // _
					: ($code>96) & ($code<123)
						  // a b c d e f g h i j k l m n o p q r s t u v w x y z
					: ($code=126)
						  // ~
					Else 
						$shouldEncode:=True:C214
				End case 
				
		End case 
		
		If ($shouldEncode)
			CONVERT FROM TEXT:C1011($char;"utf-8";$data)
			For ($j;0;BLOB size:C605($data)-1)
				$hex:=String:C10($data{$j};"&x")
				$encoded:=$encoded+"%"+Substring:C12($hex;Length:C16($hex)-1)
			End for 
		Else 
			If ($code=32)
				$encoded:=$encoded+"+"
			Else 
				$encoded:=$encoded+$char
			End if 
		End if 
		
	End for 
	
End if 

$0:=$encoded