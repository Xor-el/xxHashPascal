unit xxHash32NormalTest;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  xxHash32;

type

  [TestFixture]
  TxxHash32NormalTest = class(TObject)
  protected Const
    DictionaryPath = 'Res\xxHash32_Dict.txt';
    class var FStringList: TStringList;

  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    (* &&&&&&&&&&&&&&&&&&&&&&&  xxHash32 Test  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

    [Test]
    procedure xxHashTest32NoRefCountedANSI();
    [Test]
    procedure xxHashTest32RefCountedANSI();
    [Test]
    procedure xxHash32SimpleANSI();
    [Test]
    procedure xxHash32SimpleANSIPointerVersion();
  end;

implementation

procedure TxxHash32NormalTest.Setup;
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

procedure TxxHash32NormalTest.TearDown;
begin
  FStringList.Free;
end;

(* &&&&&&&&&&&&&&&&&&&&&&&  xxHash32 Test  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

procedure TxxHash32NormalTest.xxHashTest32NoRefCountedANSI();
var
  tempByteArray: TArray<Byte>;
  tempStr: String;
  hash: TxxHash32;
  loopCount: Integer;
  tempStrArray: TArray<String>;
  tempString: String;
begin
  for loopCount := 0 to FStringList.Count - 1 do
  begin
    tempString := FStringList.Strings[loopCount];
    tempStrArray := tempString.Split([':'], None);
    tempByteArray := TEncoding.ANSI.GetBytes(tempStrArray[0]);
    hash := TxxHash32.Create;
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

procedure TxxHash32NormalTest.xxHashTest32RefCountedANSI();
var
  tempByteArray: TArray<Byte>;
  tempStr: String;
  hash: IIxxHash32;
  loopCount: Integer;
  tempStrArray: TArray<String>;
  tempString: String;

begin
  for loopCount := 0 to FStringList.Count - 1 do
  begin
    tempString := FStringList.Strings[loopCount];
    tempStrArray := tempString.Split([':'], None);
    tempByteArray := TEncoding.ANSI.GetBytes(tempStrArray[0]);
    hash := TxxHash32.Create;
    hash.Init(); // Initialize with Seed else (0) is used by default
    hash.Update(tempByteArray[Low(tempByteArray)], Length(tempByteArray));
    tempStr := UIntToStr(hash.Digest);

    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;

end;

procedure TxxHash32NormalTest.xxHash32SimpleANSI();
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
    tempStr := UIntToStr(TxxHash32.CalculateHash32(tempByteArray
      [Low(tempByteArray)], Length(tempByteArray)));
    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;
end;

procedure TxxHash32NormalTest.xxHash32SimpleANSIPointerVersion();
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
    tempStr := UIntToStr(TxxHash32.CalculateHash32(Pointer(tempByteArray)^,
      Length(tempByteArray)));
    Assert.AreEqual(tempStr, tempStrArray[1],
      Format('Assertion was called with Hash of %s and Plain Value %s',
      [tempStrArray[0], tempStrArray[1]]));
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TxxHash32NormalTest);

end.
