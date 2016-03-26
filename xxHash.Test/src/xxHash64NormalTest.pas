unit xxHash64NormalTest;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  xxHash64;

type

  [TestFixture]
  TxxHash64NormalTest = class(TObject)
  protected Const
    DictionaryPath = 'Res\xxHash64_Dict.txt';
    class var FStringList: TStringList;

  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    (* &&&&&&&&&&&&&&&&&&&&&&&  xxHash64 Test  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

    [Test]
    procedure xxHashTest64NoRefCountedANSI();
    [Test]
    procedure xxHashTest64RefCountedANSI();
    [Test]
    procedure xxHash64SimpleANSI();
    [Test]
    procedure xxHash64SimpleANSIPointerVersion();
  end;

implementation

procedure TxxHash64NormalTest.Setup;
var
  ExePath, SubbedPath, FixedPath: String;
begin
  ExePath := Application.ExeName;
  SubbedPath := ExtractFileDir(ExtractFileDir(ExtractFileDir(ExePath)));
  SubbedPath := StringReplace(SubbedPath, 'xxHash.Test', '', [rfReplaceAll]);
  FixedPath := SubbedPath + DictionaryPath;
  if not FileExists(FixedPath) then
    raise Exception.Create('Dictionary File not Found in ' + FixedPath);
  FStringList := TStringList.Create;
  try
    FStringList.LoadFromFile(FixedPath, TEncoding.ANSI);
  except
    raise Exception.Create('Error Loading Dictionary File');
  end;
end;

procedure TxxHash64NormalTest.TearDown;
begin
  FStringList.Free;
end;

(* &&&&&&&&&&&&&&&&&&&&&&&  xxHash64 Test  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

procedure TxxHash64NormalTest.xxHashTest64NoRefCountedANSI();
var
  tempByteArray: TArray<Byte>;
  tempStr: String;
  hash: TxxHash64;
  loopCount: Integer;
  tempStrArray: TArray<String>;
  tempString: String;
begin
  for loopCount := 0 to FStringList.Count - 1 do
  begin
    tempString := FStringList.Strings[loopCount];
    tempStrArray := tempString.Split([':'], None);
    tempByteArray := TEncoding.ANSI.GetBytes(tempStrArray[0]);
    hash := TxxHash64.Create;
    try
      hash.Init(); // Initialize with Seed else (0) is used by default
      hash.Update(tempByteArray[Low(tempByteArray)], Length(tempByteArray));
      tempStr := UIntToStr(hash.Digest);
    finally
      hash.Free;
    end;

    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;
end;

procedure TxxHash64NormalTest.xxHashTest64RefCountedANSI();
var
  tempByteArray: TArray<Byte>;
  tempStr: String;
  hash: IIxxHash64;
  loopCount: Integer;
  tempStrArray: TArray<String>;
  tempString: String;

begin
  for loopCount := 0 to FStringList.Count - 1 do
  begin
    tempString := FStringList.Strings[loopCount];
    tempStrArray := tempString.Split([':'], None);
    tempByteArray := TEncoding.ANSI.GetBytes(tempStrArray[0]);
    hash := TxxHash64.Create;
    hash.Init(); // Initialize with Seed else (0) is used by default
    hash.Update(tempByteArray[Low(tempByteArray)], Length(tempByteArray));
    tempStr := UIntToStr(hash.Digest);

    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;

end;

procedure TxxHash64NormalTest.xxHash64SimpleANSI();
var
  tempByteArray: TArray<Byte>;
  tempStr: String;
  loopCount: Integer;
  tempStrArray: TArray<String>;
  tempString: String;
begin
  for loopCount := 0 to FStringList.Count - 1 do
  begin
    tempString := FStringList.Strings[loopCount];
    tempStrArray := tempString.Split([':'], None);
    tempByteArray := TEncoding.ANSI.GetBytes(tempStrArray[0]);
    tempStr := UIntToStr(TxxHash64.CalculateHash64(tempByteArray
      [Low(tempByteArray)], Length(tempByteArray)));
    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;
end;

procedure TxxHash64NormalTest.xxHash64SimpleANSIPointerVersion();
var
  tempByteArray: TArray<Byte>;
  tempStr: String;
  loopCount: Integer;
  tempStrArray: TArray<String>;
  tempString: String;
begin
  for loopCount := 0 to FStringList.Count - 1 do
  begin
    tempString := FStringList.Strings[loopCount];
    tempStrArray := tempString.Split([':'], None);
    tempByteArray := TEncoding.ANSI.GetBytes(tempStrArray[0]);
    tempStr := UIntToStr(TxxHash64.CalculateHash64(Pointer(tempByteArray)^,
      Length(tempByteArray)));
    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TxxHash64NormalTest);

end.
