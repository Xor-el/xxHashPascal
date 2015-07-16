#xxHashPascal#


A pure Pascal Implementation of [xxHash](https://github.com/Cyan4973/xxHash)

32 bit version was Ported from CSharp to Pascal using this Library [xxHashSharp](https://github.com/noricube/xxHashSharp) With Some Fixes from the Original C Library

64 bit version was Ported from C to Pascal using the Original Library [xxHash](https://github.com/Cyan4973/xxHash)

Example
---------



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
	
or

	
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

Hints
------

	** FPC Users should disable Range and Overflow Checks.

License
----------
    Copyright (c) 2015 Ugochukwu Mmaduekwe ugo4brain@gmail.com

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:
    
    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.
    
    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
    
    3. This notice may not be removed or altered from any source distribution.
        
        