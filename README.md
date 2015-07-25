#xxHashPascal#


A Pure Pascal Implementation of [xxHash](https://github.com/Cyan4973/xxHash)


**`Example`**

    uses
      SysUtils, xxHash32; // for 64bit xxHash, use xxHash64

	var
      input : TBytes; // note that input can be any data type like TBytes or String
      hash : TxxHash32; // for 64bit xxHash, use TxxHash64

    begin     
      hash := TxxHash32.Create; // for 64bit xxHash, use TxxHash64.Create
    try
      hash.Init(); // Initialize with Seed else (0) is used by default
      hash.Update(input[Low(input)], Length(input));
    //or
    { hash.Update(Pointer(input)^, Length(input)); }
      //...
      WriteLn(IntToHex(hash.Digest,8));
      ReadLn;
    finally
      hash.Free;
    end;
	end;
	
**`or`**
   
    {for xxHash32}
     WriteLn(IntToHex(TxxHash32.CalculateHash32(Input[Low(input)]),8));
    //or
    WriteLn(IntToHex(TxxHash32.CalculateHash32(Pointer(input)^),8));

    {for xxHash64}
	 WriteLn(IntToHex(TxxHash64.CalculateHash64(Input[Low(input)]),8));
    //or
    WriteLn(IntToHex(TxxHash64.CalculateHash64(Pointer(input)^),8));

    //if you wish to use a custom seed.
    {
    //if xxHash32  
    WriteLn(IntToHex(TxxHash32.CalculateHash32(input[Low(input)],Length(input),12345),8));
    //if xxHash64
    WriteLn(IntToHex(TxxHash64.CalculateHash64(input[Low(input)],Length(input),12345),8));
    // where (12345) is the Seed else (0) is used by default if not indicated
    }
    ReadLn;
 

**`Hints`**


	**FPC Users should disable Range and Overflow Checks.

**`Thanks`**

     Special thanks to Johan Bontes for helping me out with benchmarking, 
    various optimizations and corrections.

**`ChangeLog`**

    25-07-2015
    Both xxHash (32 and 64 bit) now produces same results as the original C version.

    16-07-2015
    First Commit