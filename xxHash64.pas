unit xxHash64;

{
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

}

interface

uses

  SysUtils;

type
  TxxHash64 = class
  strict private

    function CalcSubHash(value: UInt64; buf: TBytes; index: Integer): UInt64;
    function RotateLeft(value: UInt64; count: Integer): UInt64;

  type

    TXXH_State = Record
{$IFNDEF FPC}
    private
{$ENDIF}
      total_len: UInt64;
      seed: UInt64;
      v1: UInt64;
      v2: UInt64;
      v3: UInt64;
      v4: UInt64;
      memsize: LongWord;
      memory: TBytes;
    end;

  const
    PRIME64_1: UInt64 = 11400714785074694791;
    PRIME64_2: UInt64 = 14029467366897019727;
    PRIME64_3: UInt64 = 1609587929392839161;
    PRIME64_4: UInt64 = 9650029242287828579;
    PRIME64_5: UInt64 = 2870177450012600261;

  protected
    _state: TXXH_State;

  public
    constructor Create();
    destructor Destroy(); Override;
    procedure Init(seed: UInt64 = 0);
    function Update(input: TBytes; len: LongWord): Boolean;
    function CalculateHash(buf: TBytes; len: LongWord = 0;
      seed: UInt64 = 0): UInt64;
    function Digest(): UInt64;

  end;

implementation

constructor TxxHash64.Create();
begin
  inherited Create;

end;

destructor TxxHash64.Destroy();
begin
  _state.memory := Nil;
  inherited Destroy;
end;

function TxxHash64.CalculateHash(buf: TBytes; len: LongWord = 0;
  seed: UInt64 = 0): UInt64;
var
  v1, v2, v3, v4, bitconverted: UInt64;
  bitconverted2: LongWord;
  index, limit: Integer;
begin
  bitconverted := 0;
  bitconverted2 := 0;
  index := 0;
  if (len = 0) then

    len := Length(buf);

  if (len >= 32) then

  begin
    limit := len - 32;
    v1 := seed + PRIME64_1 + PRIME64_2;
    v2 := seed + PRIME64_2;
    v3 := seed + 0;
    v4 := seed - PRIME64_1;

    while (index <= limit) do
    begin
      v1 := CalcSubHash(v1, buf, index);
      Inc(index, 8);
      v2 := CalcSubHash(v2, buf, index);
      Inc(index, 8);
      v3 := CalcSubHash(v3, buf, index);
      Inc(index, 8);
      v4 := CalcSubHash(v4, buf, index);
      Inc(index, 8);
    end;

    result := RotateLeft(v1, 1) + RotateLeft(v2, 7) + RotateLeft(v3, 12) +
      RotateLeft(v4, 18);
    v1 := RotateLeft(v1 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v1) * PRIME64_1 + PRIME64_4;

    v2 := RotateLeft(v2 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v2) * PRIME64_1 + PRIME64_4;

    v3 := RotateLeft(v3 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v3) * PRIME64_1 + PRIME64_4;

    v4 := RotateLeft(v4 * PRIME64_2, 31) * PRIME64_1;
    result := (result xor v4) * PRIME64_1 + PRIME64_4;
  end
  else

    result := seed + PRIME64_5;

  Inc(result, LongWord(len));

  while (LongWord(index) <= len - 8) do

  begin

    // Replication of CSharp's BitConverter.ToUInt64 method.
    Move(buf[index], bitconverted, 8);
    result := result xor (PRIME64_1 *
      RotateLeft((bitconverted * PRIME64_2), 31));
    result := RotateLeft(result, 27) * PRIME64_1 + PRIME64_4;
    Inc(index, 8);
  end;

  if LongWord(index) <= (len - 4) then
  begin
    // Replication of CSharp's BitConverter.ToUInt32 method.
    Move(buf[index], bitconverted2, 4);
    result := (result xor bitconverted2) * PRIME64_1;
    result := RotateLeft(result, 23) * PRIME64_2 + PRIME64_3;
    Inc(index, 4);
  end;

  while (LongWord(index) < len) do
  begin
    result := (result xor buf[index]) * PRIME64_5;
    result := RotateLeft(result, 11) * PRIME64_1;
    Inc(index);
  end;

  result := result xor (result shr 33);
  result := result * PRIME64_2;
  result := result xor (result shr 29);
  result := result * PRIME64_3;
  result := result xor (result shr 32);

end;

procedure TxxHash64.Init(seed: UInt64 = 0);
begin

  _state.seed := seed;
  _state.v1 := seed + PRIME64_1 + PRIME64_2;
  _state.v2 := seed + PRIME64_2;
  _state.v3 := seed + 0;
  _state.v4 := seed - PRIME64_1;
  _state.total_len := 0;
  _state.memsize := 0;
  SetLength(_state.memory, 32);

end;

function TxxHash64.Update(input: TBytes; len: LongWord): Boolean;

var
  index, limit: Integer;
  v1, v2, v3, v4: UInt64;
begin
  index := 0;
  _state.total_len := _state.total_len + LongWord(len);

  if ((_state.memsize + len) < 32) then
  begin

    // Some pointer black magic :) similar to CSharp's Array.Copy.
    Move((@input[0])^, (@_state.memory[_state.memsize])^, len);

    _state.memsize := _state.memsize + LongWord(len);

    result := True;
    Exit;
  end;

  if (_state.memsize > 0) then
  begin

    // Some pointer black magic :) similar to CSharp's Array.Copy.
    Move((@input[0])^, (@_state.memory[_state.memsize])^, 32 - _state.memsize);

    _state.v1 := CalcSubHash(_state.v1, _state.memory, index);
    Inc(index, 8);
    _state.v2 := CalcSubHash(_state.v2, _state.memory, index);
    Inc(index, 8);
    _state.v3 := CalcSubHash(_state.v3, _state.memory, index);
    Inc(index, 8);
    _state.v4 := CalcSubHash(_state.v4, _state.memory, index);

    index := 0;
    _state.memsize := 0;
  end;

  if (LongWord(index) <= len - 32) then
  begin

    limit := len - 32;
    v1 := _state.v1;
    v2 := _state.v2;
    v3 := _state.v3;
    v4 := _state.v4;

    while (index <= limit) do
    begin
      v1 := CalcSubHash(v1, input, index);
      Inc(index, 8);
      v2 := CalcSubHash(v2, input, index);
      Inc(index, 8);
      v3 := CalcSubHash(v3, input, index);
      Inc(index, 8);
      v4 := CalcSubHash(v4, input, index);
      Inc(index, 8);
    end;

    _state.v1 := v1;
    _state.v2 := v2;
    _state.v3 := v3;
    _state.v4 := v4;

  end;

  if (LongWord(index) < len) then
  begin

    // Some pointer black magic :) similar to CSharp's Array.Copy.
    Move((@input[index])^, (@_state.memory[0])^, len - LongWord(index));
    _state.memsize := len - LongWord(index);

  end;
  result := True;
end;

function TxxHash64.Digest(): UInt64;
var
  bitconverted, v1, v2, v3, v4: UInt64;
  bitconverted2: LongWord;
  index: Integer;
begin
  bitconverted := 0;
  bitconverted2 := 0;
  index := 0;
  if (_state.total_len >= 32) then
  begin
    v1 := _state.v1;
    v2 := _state.v2;
    v3 := _state.v3;
    v4 := _state.v4;
    result := RotateLeft(v1, 1) + RotateLeft(v2, 7) + RotateLeft(v3, 12) +
      RotateLeft(v4, 18);

    v1 := v1 * PRIME64_2;
    v1 := RotateLeft(v1, 31);
    v1 := v1 * PRIME64_1;
    result := result xor v1;
    result := result * PRIME64_1 + PRIME64_4;

    v2 := v2 * PRIME64_2;
    v2 := RotateLeft(v2, 31);
    v2 := v2 * PRIME64_1;
    result := result xor v2;
    result := result * PRIME64_1 + PRIME64_4;

    v3 := v3 * PRIME64_2;
    v3 := RotateLeft(v3, 31);
    v3 := v3 * PRIME64_1;
    result := result xor v3;
    result := result * PRIME64_1 + PRIME64_4;

    v4 := v4 * PRIME64_2;
    v4 := RotateLeft(v4, 31);
    v4 := v4 * PRIME64_1;
    result := result xor v4;
    result := result * PRIME64_1 + PRIME64_4;
  end
  else
  begin
    result := _state.seed + PRIME64_5;
  end;

  Inc(result, _state.total_len);

  while (LongWord(index) + 8 <= _state.memsize) do

  begin

    // Replication of CSharp's BitConverter.ToUInt64 method.
    Move(_state.memory[index], bitconverted, 8);
    result := result xor (PRIME64_1 *
      RotateLeft((bitconverted * PRIME64_2), 31));
    result := RotateLeft(result, 27) * PRIME64_1 + PRIME64_4;
    Inc(index, 8);
  end;

  if LongWord(index) + 4 <= (_state.memsize) then
  begin
    // Replication of CSharp's BitConverter.ToUInt32 method.
    Move(_state.memory[index], bitconverted2, 4);
    result := (result xor bitconverted2) * PRIME64_1;
    result := RotateLeft(result, 23) * PRIME64_2 + PRIME64_3;
    Inc(index, 4);
  end;

  while (LongWord(index) < _state.memsize) do
  begin
    result := (result xor _state.memory[index]) * PRIME64_5;
    result := RotateLeft(result, 11) * PRIME64_1;
    Inc(index);
  end;

  result := result xor (result shr 33);
  result := result * PRIME64_2;
  result := result xor (result shr 29);
  result := result * PRIME64_3;
  result := result xor (result shr 32);
end;

function TxxHash64.CalcSubHash(value: UInt64; buf: TBytes;
  index: Integer): UInt64;
var
  read_value: UInt64;
begin
  read_value := 0;
  Move(buf[index], read_value, 8);
  value := value + (read_value * PRIME64_2);
  value := RotateLeft(value, 31);
  value := value * PRIME64_1;
  result := value;

end;

function TxxHash64.RotateLeft(value: UInt64; count: Integer): UInt64;
begin

  result := (value shl count) or (value shr (64 - count));

end;

end.
