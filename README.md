#xxHashPascal#


A pure Pascal Implementation of [xxHash](https://github.com/Cyan4973/xxHash)

32 bit version was Ported from CSharp to Pascal using this Library [xxHashSharp](https://github.com/noricube/xxHashSharp) With Some Fixes from the Original C Library

64 bit version was Ported from C to Pascal using the Original Library [xxHash](https://github.com/Cyan4973/xxHash)

**`Example`**



    uses
      SysUtils, xxHash32; // for 64bit xxHash, use xxHash64

	var
      input : TBytes;
      hash : TxxHash32; // for 64bit xxHash, use TxxHash64

    begin
       {$IFNDEF FPC}
	  input := TEncoding.UTF8.GetBytes('hello world');
	   {$ELSE}
	  MyString :=  'hello world';
      SetLength(input,Length(MyString));
      move(Pointer(MyString)^, input[0],Length(MyString));  
	     {$ENDIF}      
      hash := TxxHash32.Create; // for 64bit xxHash, use TxxHash64.Create
    try
      hash.Init(); // Initialize with Seed else (0) is used by default
      hash.Update(input, Length(input));
      //...
      WriteLn(IntToHex(hash.Digest,8));
      ReadLn;
    finally
      hash.Free;
    end;
	end;
	
**`or`**

	
	   {$IFNDEF FPC}
		  input := TEncoding.UTF8.GetBytes('hello world');
		{$ELSE}
		 MyString :=  'hello world';
    	 SetLength(input,Length(MyString));
     	move(Pointer(MyString)^, input[0],Length(MyString)); 
		  {$ENDIF}
      hash := TxxHash32.Create; // for 64bit xxHash, use TxxHash64.Create
    try
	    WriteLn(IntToHex(hash.CalculateHash(input),8));
     // or  
      {WriteLn(IntToHex(hash.CalculateHash(input, Length(input), 12345),8));
      where (12345) is the Seed else (0) is used by default if not indicated}
        ReadLn;
    finally
        hash.Free;
    end;

**`Hints`**


	**FPC Users should disable Range and Overflow Checks.