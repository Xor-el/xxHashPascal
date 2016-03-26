unit xxHash64;


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
  TxxHash64 = class
  strict private

    class function RotateLeft64(value: UInt64; count: Integer): UInt64;
      static; inline;

  type

    TXXH_State = Record

    private

      total_len: UInt64;
      seed: UInt64;
      v1: UInt64;
      v2: UInt64;
      v3: UInt64;
      v4: UInt64;
      memsize: LongWord;
      ptrmemory: Pointer;

    end;

  class var
  const
    PRIME64_1: UInt64 = 11400714785074694791;
    PRIME64_2: UInt64 = 14029467366897019727;
    PRIME64_3: UInt64 = 1609587929392839161;
    PRIME64_4: UInt64 = 9650029242287828579;
    PRIME64_5: UInt64 = 2870177450012600261;

  protected
    F_state: TXXH_State;

  public
    constructor Create();
    destructor Destroy(); Override;
    procedure Init(seed: UInt64 = 0);
    function Update(const input; len: Integer): Boolean;
    class function CalculateHash64(const HashData; len: Integer = 0;
      seed: UInt64 = 0): UInt64; static;
    function Digest(): UInt64;

  end;

implementation

constructor TxxHash64.Create();
begin
  inherited Create;

end;

destructor TxxHash64.Destroy();
begin

  FreeMem(F_state.ptrmemory, 32);
  inherited Destroy;
end;

procedure TxxHash64.Init(seed: UInt64 = 0);
begin

  F_state.seed := seed;
  F_state.v1 := seed + PRIME64_1 + PRIME64_2;
  F_state.v2 := seed + PRIME64_2;
  F_state.v3 := seed + 0;
  F_state.v4 := seed - PRIME64_1;
  F_state.total_len := 0;
  F_state.memsize := 0;
  GetMem(F_state.ptrmemory, 32);

end;

class function TxxHash64.CalculateHash64(const HashData; len: Integer = 0;
  seed: UInt64 = 0): UInt64;
var
  v1, v2, v3, v4: UInt64;
  ptrLimit, ptrEnd, ptrBuffer: Pointer;
begin
  ptrBuffer := @HashData;

  NativeUInt(ptrEnd) := NativeUInt(ptrBuffer) + UInt32(len);

  if len >= 32 then
  begin
    v1 := seed + PRIME64_1 + PRIME64_2;
    v2 := seed + PRIME64_2;
    v3 := seed;
    v4 := seed - PRIME64_1;

    NativeUInt(ptrLimit) := NativeUInt(ptrEnd) - 32;
    repeat
      v1 := PRIME64_1 * RotateLeft64(v1 + PRIME64_2 * PUInt64(ptrBuffer)^, 31);
      v2 := PRIME64_1 * RotateLeft64(v2 + PRIME64_2 *
        PUInt64(NativeUInt(ptrBuffer) + 8)^, 31);
      v3 := PRIME64_1 * RotateLeft64(v3 + PRIME64_2 *
        PUInt64(NativeUInt(ptrBuffer) + 16)^, 31);
      v4 := PRIME64_1 * RotateLeft64(v4 + PRIME64_2 *
        PUInt64(NativeUInt(ptrBuffer) + 24)^, 31);
      Inc(NativeUInt(ptrBuffer), 32);
    until not(NativeUInt(ptrBuffer) <= NativeUInt(ptrLimit));

    result := RotateLeft64(v1, 1) + RotateLeft64(v2, 7) + RotateLeft64(v3, 12) +
      RotateLeft64(v4, 18);

    v1 := RotateLeft64(v1 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v1) * PRIME64_1 + PRIME64_4;

    v2 := RotateLeft64(v2 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v2) * PRIME64_1 + PRIME64_4;

    v3 := RotateLeft64(v3 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v3) * PRIME64_1 + PRIME64_4;

    v4 := RotateLeft64(v4 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v4) * PRIME64_1 + PRIME64_4;
  end
  else
    result := seed + PRIME64_5;

  Inc(result, UInt64(len));

  while (NativeUInt(ptrBuffer) + 8) <= (NativeUInt(ptrEnd)) do
  begin
    result := result xor (PRIME64_1 * RotateLeft64(PRIME64_2 *
      PUInt64(ptrBuffer)^, 31));
    result := RotateLeft64(result, 27) * PRIME64_1 + PRIME64_4;
    Inc(NativeUInt(ptrBuffer), 8);
  end;

  if (NativeUInt(ptrBuffer) + 4) <= NativeUInt(ptrEnd) then
  begin
    result := result xor (PLongWord(ptrBuffer)^ * PRIME64_1);
    result := RotateLeft64(result, 23) * PRIME64_2 + PRIME64_3;
    Inc(NativeUInt(ptrBuffer), 4);
  end;

  while NativeUInt(ptrBuffer) < NativeUInt(ptrEnd) do
  begin
    result := result xor (PByte(ptrBuffer)^ * PRIME64_5);
    result := RotateLeft64(result, 11) * PRIME64_1;
    Inc(NativeUInt(ptrBuffer));
  end;

  result := result xor (result shr 33);
  result := result * PRIME64_2;
  result := result xor (result shr 29);
  result := result * PRIME64_3;
  result := result xor (result shr 32);
end;

function TxxHash64.Update(const input; len: Integer): Boolean;
var
  v1, v2, v3, v4: UInt64;
  ptrBuffer, ptrTemp, ptrEnd, ptrLimit: Pointer;
begin
  ptrBuffer := @input;

  F_state.total_len := F_state.total_len + UInt64(len);

  if ((F_state.memsize + UInt32(len)) < UInt32(32)) then
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
    Move(ptrBuffer^, ptrTemp^, 32 - F_state.memsize);

    F_state.v1 := PRIME64_1 * RotateLeft64(F_state.v1 + PRIME64_2 *
      PUInt64(F_state.ptrmemory)^, 31);
    F_state.v2 := PRIME64_1 * RotateLeft64(F_state.v2 + PRIME64_2 *
      PUInt64(NativeUInt(F_state.ptrmemory) + 8)^, 31);
    F_state.v3 := PRIME64_1 * RotateLeft64(F_state.v3 + PRIME64_2 *
      PUInt64(NativeUInt(F_state.ptrmemory) + 16)^, 31);
    F_state.v4 := PRIME64_1 * RotateLeft64(F_state.v4 + PRIME64_2 *
      PUInt64(NativeUInt(F_state.ptrmemory) + 24)^, 31);

    ptrBuffer := Pointer(NativeUInt(ptrBuffer) + (32 - F_state.memsize));
    F_state.memsize := 0;
  end;

  if NativeUInt(ptrBuffer) <= (NativeUInt(ptrEnd) - 32) then
  begin
    v1 := F_state.v1;
    v2 := F_state.v2;
    v3 := F_state.v3;
    v4 := F_state.v4;

    ptrLimit := Pointer(NativeUInt(ptrEnd) - 32);
    repeat
      v1 := PRIME64_1 * RotateLeft64(v1 + PRIME64_2 * PUInt64(ptrBuffer)^, 31);
      v2 := PRIME64_1 * RotateLeft64(v2 + PRIME64_2 *
        PUInt64(NativeUInt(ptrBuffer) + 8)^, 31);
      v3 := PRIME64_1 * RotateLeft64(v3 + PRIME64_2 *
        PUInt64(NativeUInt(ptrBuffer) + 16)^, 31);
      v4 := PRIME64_1 * RotateLeft64(v4 + PRIME64_2 *
        PUInt64(NativeUInt(ptrBuffer) + 24)^, 31);
      Inc(NativeUInt(ptrBuffer), 32);
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

function TxxHash64.Digest: UInt64;
var
  v1, v2, v3, v4: UInt64;
  ptrBuffer, ptrEnd: Pointer;

begin
  if F_state.total_len >= UInt64(32) then
  begin
    v1 := F_state.v1;
    v2 := F_state.v2;
    v3 := F_state.v3;
    v4 := F_state.v4;

    result := RotateLeft64(v1, 1) + RotateLeft64(v2, 7) + RotateLeft64(v3, 12) +
      RotateLeft64(v4, 18);

    v1 := RotateLeft64(v1 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v1) * PRIME64_1 + PRIME64_4;

    v2 := RotateLeft64(v2 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v2) * PRIME64_1 + PRIME64_4;

    v3 := RotateLeft64(v3 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v3) * PRIME64_1 + PRIME64_4;

    v4 := RotateLeft64(v4 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v4) * PRIME64_1 + PRIME64_4;
  end
  else
    result := F_state.seed + PRIME64_5;

  Inc(result, F_state.total_len);

  ptrBuffer := F_state.ptrmemory;
  ptrEnd := Pointer(NativeUInt(ptrBuffer) + F_state.memsize);

  while (NativeUInt(ptrBuffer) + 8) <= NativeUInt(ptrEnd) do
  begin
    result := result xor (PRIME64_1 * RotateLeft64(PRIME64_2 *
      PUInt64(ptrBuffer)^, 31));
    result := RotateLeft64(result, 27) * PRIME64_1 + PRIME64_4;
    Inc(NativeUInt(ptrBuffer), 8);
  end;

  if (NativeUInt(ptrBuffer) + 4) <= NativeUInt(ptrEnd) then
  begin
    result := result xor PLongWord(ptrBuffer)^ * PRIME64_1;
    result := RotateLeft64(result, 23) * PRIME64_2 + PRIME64_3;
    Inc(NativeUInt(ptrBuffer), 4);
  end;

  while NativeUInt(ptrBuffer) < NativeUInt(ptrEnd) do
  begin
    result := result xor (PByte(ptrBuffer)^ * PRIME64_5);
    result := RotateLeft64(result, 11) * PRIME64_1;
    Inc(NativeUInt(ptrBuffer));
  end;

  result := result xor (result shr 33);
  result := result * PRIME64_2;
  result := result xor (result shr 29);
  result := result * PRIME64_3;
  result := result xor (result shr 32);
end;

class function TxxHash64.RotateLeft64(value: UInt64; count: Integer): UInt64;
begin

  result := (value shl count) or (value shr (64 - count));

end;

{$POINTERMATH OFF}

end.
