unit xxHash32;


{$POINTERMATH ON}

{$IFDEF FPC}
{$mode delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  SysUtils
{$ELSE}
    System.SysUtils
{$ENDIF};

type
  TxxHash32 = class
  strict private

    class function RotateLeft32(value: LongWord; count: Integer): LongWord;
      static; inline;

  type

    TXXH_State = Record

    private

      total_len: UInt64;
      seed: LongWord;
      v1: LongWord;
      v2: LongWord;
      v3: LongWord;
      v4: LongWord;
      memsize: LongWord;
      ptrmemory: Pointer;

    end;

  class var
  const
    PRIME32_1: LongWord = 2654435761;
    PRIME32_2: LongWord = 2246822519;
    PRIME32_3: LongWord = 3266489917;
    PRIME32_4: LongWord = 668265263;
    PRIME32_5: LongWord = 374761393;

  protected
    F_state: TXXH_State;

  public
    constructor Create();
    destructor Destroy(); Override;
    procedure Init(seed: LongWord = 0);
    function Update(const input; len: Integer): Boolean;
    class function CalculateHash32(const HashData; len: Integer = 0;
      seed: LongWord = 0): LongWord; static;
    function Digest(): LongWord;

  end;

implementation

constructor TxxHash32.Create();
begin
  inherited Create;

end;

destructor TxxHash32.Destroy();
begin

  FreeMem(F_state.ptrmemory, 16);
  inherited Destroy;
end;

procedure TxxHash32.Init(seed: LongWord = 0);
begin

  F_state.seed := seed;
  F_state.v1 := seed + PRIME32_1 + PRIME32_2;
  F_state.v2 := seed + PRIME32_2;
  F_state.v3 := seed + 0;
  F_state.v4 := seed - PRIME32_1;
  F_state.total_len := 0;
  F_state.memsize := 0;
  GetMem(F_state.ptrmemory, 16);

end;

function TxxHash32.Update(const input; len: Integer): Boolean;
var
  v1, v2, v3, v4: LongWord;
  ptrBuffer, ptrTemp, ptrEnd, ptrLimit: Pointer;

begin

  ptrBuffer := @input;

  F_state.total_len := F_state.total_len + UInt64(len);

  if ((F_state.memsize + UInt32(len)) < UInt32(16)) then
  begin

    ptrTemp := Pointer(NativeUInt(F_state.ptrmemory) + F_state.memsize);

    Move(ptrBuffer^, ptrTemp^, len);

    F_state.memsize := F_state.memsize + UInt32(len);

    result := True;
    Exit;
  end;

  ptrEnd := Pointer(NativeUInt(ptrBuffer) + UInt32(len));

  if F_state.memsize > 0 then
  begin
    ptrTemp := Pointer(NativeUInt(F_state.ptrmemory) + F_state.memsize);
    Move(ptrBuffer^, ptrTemp^, 16 - F_state.memsize);

    F_state.v1 := PRIME32_1 * RotateLeft32(F_state.v1 + PRIME32_2 *
      PLongWord(F_state.ptrmemory)^, 13);
    F_state.v2 := PRIME32_1 * RotateLeft32(F_state.v2 + PRIME32_2 *
      PLongWord(NativeUInt(F_state.ptrmemory) + 4)^, 13);
    F_state.v3 := PRIME32_1 * RotateLeft32(F_state.v3 + PRIME32_2 *
      PLongWord(NativeUInt(F_state.ptrmemory) + 8)^, 13);
    F_state.v4 := PRIME32_1 * RotateLeft32(F_state.v4 + PRIME32_2 *
      PLongWord(NativeUInt(F_state.ptrmemory) + 12)^, 13);

    ptrBuffer := Pointer(NativeUInt(ptrBuffer) + (16 - F_state.memsize));
    F_state.memsize := 0;
  end;

  if NativeUInt(ptrBuffer) <= (NativeUInt(ptrEnd) - 16) then
  begin
    v1 := F_state.v1;
    v2 := F_state.v2;
    v3 := F_state.v3;
    v4 := F_state.v4;

    ptrLimit := Pointer(NativeUInt(ptrEnd) - 16);
    repeat
      v1 := PRIME32_1 * RotateLeft32(v1 + PRIME32_2 *
        PLongWord(ptrBuffer)^, 13);
      v2 := PRIME32_1 * RotateLeft32(v2 + PRIME32_2 *
        PLongWord(NativeUInt(ptrBuffer) + 4)^, 13);
      v3 := PRIME32_1 * RotateLeft32(v3 + PRIME32_2 *
        PLongWord(NativeUInt(ptrBuffer) + 8)^, 13);
      v4 := PRIME32_1 * RotateLeft32(v4 + PRIME32_2 *
        PLongWord(NativeUInt(ptrBuffer) + 12)^, 13);
      Inc(NativeUInt(ptrBuffer), 16);
    until not(NativeUInt(ptrBuffer) <= NativeUInt(ptrLimit));

    F_state.v1 := v1;
    F_state.v2 := v2;
    F_state.v3 := v3;
    F_state.v4 := v4;
  end;

  if NativeUInt(ptrBuffer) < NativeUInt(ptrEnd) then
  begin
    ptrTemp := F_state.ptrmemory;
    Move(ptrBuffer^, ptrTemp^, NativeUInt(ptrEnd) - NativeUInt(ptrBuffer));
    F_state.memsize := NativeUInt(ptrEnd) - NativeUInt(ptrBuffer);
  end;

  result := True;

end;

class function TxxHash32.CalculateHash32(const HashData; len: Integer = 0;
  seed: LongWord = 0): LongWord;
var
  v1, v2, v3, v4: LongWord;
  ptrLimit, ptrEnd, ptrBuffer: Pointer;
begin
  ptrBuffer := @HashData;
  ptrEnd := Pointer(NativeUInt(ptrBuffer) + UInt32(len));

  if len >= 16 then
  begin
    ptrLimit := Pointer(NativeUInt(ptrEnd) - 16);
    v1 := seed + PRIME32_1 + PRIME32_2;
    v2 := seed + PRIME32_2;
    v3 := seed;
    v4 := seed - PRIME32_1;

    repeat
      v1 := PRIME32_1 * RotateLeft32(v1 + PRIME32_2 *
        PLongWord(ptrBuffer)^, 13);
      v2 := PRIME32_1 * RotateLeft32(v2 + PRIME32_2 *
        PLongWord(NativeUInt(ptrBuffer) + 4)^, 13);
      v3 := PRIME32_1 * RotateLeft32(v3 + PRIME32_2 *
        PLongWord(NativeUInt(ptrBuffer) + 8)^, 13);
      v4 := PRIME32_1 * RotateLeft32(v4 + PRIME32_2 *
        PLongWord(NativeUInt(ptrBuffer) + 12)^, 13);
      Inc(NativeUInt(ptrBuffer), 16);
    until not(NativeUInt(ptrBuffer) <= NativeUInt(ptrLimit));

    result := RotateLeft32(v1, 1) + RotateLeft32(v2, 7) + RotateLeft32(v3, 12) +
      RotateLeft32(v4, 18);
  end
  else
    result := seed + PRIME32_5;

  Inc(result, UInt32(len));

  while (NativeUInt(ptrBuffer) + 4) <= (NativeUInt(ptrEnd)) do
  begin
    result := result + PLongWord(ptrBuffer)^ * PRIME32_3;
    result := RotateLeft32(result, 17) * PRIME32_4;
    Inc(NativeUInt(ptrBuffer), 4);
  end;

  while NativeUInt(ptrBuffer) < NativeUInt(ptrEnd) do
  begin
    result := result + PByte(ptrBuffer)^ * PRIME32_5;
    result := RotateLeft32(result, 11) * PRIME32_1;
    Inc(NativeUInt(ptrBuffer));
  end;

  result := result xor (result shr 15);
  result := result * PRIME32_2;
  result := result xor (result shr 13);
  result := result * PRIME32_3;
  result := result xor (result shr 16);
end;

function TxxHash32.Digest: LongWord;
var
  ptrBuffer, ptrEnd: Pointer;
begin
  if F_state.total_len >= UInt64(16) then
    result := RotateLeft32(F_state.v1, 1) + RotateLeft32(F_state.v2, 7) +
      RotateLeft32(F_state.v3, 12) + RotateLeft32(F_state.v4, 18)
  else
    result := F_state.seed + PRIME32_5;
  Inc(result, F_state.total_len);

  ptrBuffer := F_state.ptrmemory;
  ptrEnd := Pointer(NativeUInt(ptrBuffer) + F_state.memsize);
  while (NativeUInt(ptrBuffer) + 4) <= (NativeUInt(ptrEnd)) do
  begin
    result := result + PLongWord(ptrBuffer)^ * PRIME32_3;
    result := RotateLeft32(result, 17) * PRIME32_4;
    Inc(NativeUInt(ptrBuffer), 4);
  end;

  while NativeUInt(ptrBuffer) < NativeUInt(ptrEnd) do
  begin
    result := result + PByte(ptrBuffer)^ * PRIME32_5;
    result := RotateLeft32(result, 11) * PRIME32_1;
    Inc(NativeUInt(ptrBuffer));
  end;

  result := result xor (result shr 15);
  result := result * PRIME32_2;
  result := result xor (result shr 13);
  result := result * PRIME32_3;
  result := result xor (result shr 16);
end;

class function TxxHash32.RotateLeft32(value: LongWord; count: Integer)
  : LongWord;
begin

  result := (value shl count) or (value shr (32 - count));

end;

{$POINTERMATH OFF}

end.
