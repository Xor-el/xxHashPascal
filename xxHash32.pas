unit xxHash32;

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
  TxxHash32 = class
  strict private

    function CalcSubHash(value: LongWord; buf: TBytes; index: Integer)
      : LongWord;
    function RotateLeft(value: LongWord; count: Integer): LongWord;

  type

    TXXH_State = Record
{$IFNDEF FPC}
    private
{$ENDIF}
      total_len: UInt64;
      seed: LongWord;
      v1: LongWord;
      v2: LongWord;
      v3: LongWord;
      v4: LongWord;
      memsize: LongWord;
      memory: TBytes;

    end;

  const
    PRIME32_1: LongWord = 2654435761;
    PRIME32_2: LongWord = 2246822519;
    PRIME32_3: LongWord = 3266489917;
    PRIME32_4: LongWord = 668265263;
    PRIME32_5: LongWord = 374761393;

  protected
    _state: TXXH_State;

  public
    constructor Create();
    destructor Destroy(); Override;
    procedure Init(seed: LongWord = 0);
    function Update(input: TBytes; len: LongWord): Boolean;
    function CalculateHash(buf: TBytes; len: LongWord = 0; seed: LongWord = 0)
      : LongWord;
    function Digest(): LongWord;

  end;

implementation

constructor TxxHash32.Create();
begin
  inherited Create;

end;

destructor TxxHash32.Destroy();
begin
  _state.memory := Nil;
  inherited Destroy;
end;

function TxxHash32.CalculateHash(buf: TBytes; len: LongWord = 0;
  seed: LongWord = 0): LongWord;
var
  v1, v2, v3, v4, bitconverted: LongWord;
  index, limit: Integer;
begin
  bitconverted := 0;
  index := 0;
  if (len = 0) then

    len := Length(buf);

  if (len >= 16) then

  begin
    limit := len - 16;
    v1 := seed + PRIME32_1 + PRIME32_2;
    v2 := seed + PRIME32_2;
    v3 := seed + 0;
    v4 := seed - PRIME32_1;

    while (index <= limit) do
    begin
      v1 := CalcSubHash(v1, buf, index);
      Inc(index, 4);
      v2 := CalcSubHash(v2, buf, index);
      Inc(index, 4);
      v3 := CalcSubHash(v3, buf, index);
      Inc(index, 4);
      v4 := CalcSubHash(v4, buf, index);
      Inc(index, 4);
    end;

    result := RotateLeft(v1, 1) + RotateLeft(v2, 7) + RotateLeft(v3, 12) +
      RotateLeft(v4, 18);
  end
  else
  begin
    result := seed + PRIME32_5;
  end;

  result := result + len;

  while (LongWord(index) <= len - 4) do
  begin

    // Replication of CSharp's BitConverter.ToUInt32 method.
    Move(buf[index], bitconverted, 4);
    result := result + (bitconverted * PRIME32_3);
    result := RotateLeft(result, 17) * PRIME32_4;
    Inc(index, 4);

  end;

  while (LongWord(index) < len) do
  begin
    result := result + buf[index] * PRIME32_5;
    result := RotateLeft(result, 11) * PRIME32_1;
    Inc(index);
  end;

  result := result xor (result shr 15);
  result := result * PRIME32_2;
  result := result xor (result shr 13);
  result := result * PRIME32_3;
  result := result xor (result shr 16);

end;

procedure TxxHash32.Init(seed: LongWord = 0);
begin

  _state.seed := seed;
  _state.v1 := seed + PRIME32_1 + PRIME32_2;
  _state.v2 := seed + PRIME32_2;
  _state.v3 := seed + 0;
  _state.v4 := seed - PRIME32_1;
  _state.total_len := 0;
  _state.memsize := 0;
  SetLength(_state.memory, 16);

end;

function TxxHash32.Update(input: TBytes; len: LongWord): Boolean;

var
  index, limit: Integer;
  v1, v2, v3, v4: LongWord;
begin
  index := 0;
  _state.total_len := _state.total_len + len;

  if ((_state.memsize + len) < 16) then
  begin

    // Some pointer black magic :) similar to CSharp's Array.Copy.
    Move((@input[0])^, (@_state.memory[_state.memsize])^, len);

    _state.memsize := _state.memsize + len;

    result := True;
    Exit;
  end;

  if (_state.memsize > 0) then
  begin

    // Some pointer black magic :) similar to CSharp's Array.Copy.
    Move((@input[0])^, (@_state.memory[_state.memsize])^, 16 - _state.memsize);

    _state.v1 := CalcSubHash(_state.v1, _state.memory, index);
    Inc(index, 4);
    _state.v2 := CalcSubHash(_state.v2, _state.memory, index);
    Inc(index, 4);
    _state.v3 := CalcSubHash(_state.v3, _state.memory, index);
    Inc(index, 4);
    _state.v4 := CalcSubHash(_state.v4, _state.memory, index);

    index := 0;
    _state.memsize := 0;
  end;

  if (LongWord(index) <= len - 16) then
  begin

    limit := len - 16;
    v1 := _state.v1;
    v2 := _state.v2;
    v3 := _state.v3;
    v4 := _state.v4;

    while (index <= limit) do
    begin
      v1 := CalcSubHash(v1, input, index);
      Inc(index, 4);
      v2 := CalcSubHash(v2, input, index);
      Inc(index, 4);
      v3 := CalcSubHash(v3, input, index);
      Inc(index, 4);
      v4 := CalcSubHash(v4, input, index);
      Inc(index, 4);
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

function TxxHash32.Digest(): LongWord;
var
  bitconverted: LongWord;
  index: Integer;
begin
  bitconverted := 0;
  index := 0;
  if (_state.total_len >= 16) then

    result := RotateLeft(_state.v1, 1) + RotateLeft(_state.v2, 7) +
      RotateLeft(_state.v3, 12) + RotateLeft(_state.v4, 18)

  else
  begin
    result := _state.seed + PRIME32_5;
  end;

  result := result + LongWord(_state.total_len);

  while (LongWord(index) + 4 <= _state.memsize) do

  begin

    // Replication of CSharp's BitConverter.ToUInt32 method.
    Move(_state.memory[index], bitconverted, 4);
    result := result + (bitconverted * PRIME32_3);
    result := RotateLeft(result, 17) * PRIME32_4;
    Inc(index, 4);
  end;

  while (LongWord(index) < _state.memsize) do
  begin
    result := result + _state.memory[index] * PRIME32_5;
    result := RotateLeft(result, 11) * PRIME32_1;
    Inc(index);
  end;

  result := result xor (result shr 15);
  result := result * PRIME32_2;
  result := result xor (result shr 13);
  result := result * PRIME32_3;
  result := result xor (result shr 16);
end;

function TxxHash32.CalcSubHash(value: LongWord; buf: TBytes; index: Integer)
  : LongWord;
var
  read_value: LongWord;
begin
  read_value := 0;
  Move(buf[index], read_value, 4);
  value := value + (read_value * PRIME32_2);
  value := RotateLeft(value, 13);
  value := value * PRIME32_1;
  result := value;

end;

function TxxHash32.RotateLeft(value: LongWord; count: Integer): LongWord;
begin

  result := (value shl count) or (value shr (32 - count));

end;

end.
