
{$i MultiCfg.inc}

unit Terasoft_git.Framework.Bytes;

interface
  uses
    SysUtils;

  //to bytes
  function MD5OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
  function sha256OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
  function sha512OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
  function base64StringToBytes( const str: String; padding: Char = '=' ): TBytes;

  //from bytes
  function bytesToHexString(const bytes: TBytes) : String;
  function hexStringToBytes(const hex : AnsiString): TBytes;
  function bytesToBase64String( const bytes: TBytes; const wrapLines: boolean = true; padding: Char = '=' ): String;

  //bytes to Bytes
  function reverseBytes(b: TBytes): TBytes;

  function ReverseBits(b: Byte): Byte;
  function ReverseBitsOfBytes(bytes: TBytes): TBytes;

  //Insecure random number generator from delphi lib, but sometimes good for non critical purposes...
  function randomBytes(count: byte): TBytes;
  function concatBytes(const bytes: array of TBytes): TBytes;


implementation
  uses
    {$if defined(DXE_UP)}
      Spring.Cryptography,
    {$ifend}
    Soap.EncdDecd, Math;

function sha256OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
begin
  Result := bytes;
  with CreateSHA256 do
    while count > 0 do begin
      dec(count);
      Result := ComputeHash(Result);
    end;
end;

function sha512OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
begin
  Result := bytes;
  with CreateSHA512 do
    while count > 0 do begin
      dec(count);
      Result := ComputeHash(Result);
    end;
end;

function MD5OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
begin
  Result := bytes;
  with CreateMD5 do
    while count > 0 do begin
      dec(count);
      Result := ComputeHash(Result);
    end;
end;

function bytesToHexString(const bytes: TBytes) : String;
  var
    i     : LongInt;
begin
  Result := '';
  for i := 0 to Length(bytes) - 1 do
    Result := Result + IntToHex(bytes[i], 2);
end;
{ -------------------------------------------------------------------------- }

function hexStringToBytes(const hex : AnsiString): TBytes;
  var
    i, c  : Integer;
    str   : AnsiString;
    count : Integer;
begin
  Str := '';
  for i := 1 to length(hex) do
    if Upcase(Hex[i]) in ['0'..'9', 'A'..'F'] then
      str := str + hex[i];

  count := Length(str) div 2;
  setLength(Result, count);

  fillChar(pAnsiChar(@Result[0])^, length(Result), 0);

  for i := 0 to Count - 1 do begin
    val('$' + Copy(Str, (i shl 1) + 1, 2), Result[i], c);   {!!.01}
    if (c <> 0) then
      Exit;
  end;
end;

function reverseBytes(b: TBytes): TBytes;
  var
    i,j: Integer;
begin
  j := 0;
  i := length(b);
  SetLength(Result,i);
  while i>0 do begin
    dec(i);
    Result[j]:=b[i];
    inc(j);
  end;
end;

function bytesToBase64String( const bytes: TBytes; const wrapLines: boolean = true; padding: Char = '=' ): String;
begin
  Result := encodeBase64(bytes,length(bytes));
  if( not wrapLines ) then begin
    Result := StringReplace(Result,#13,'',[ rfReplaceAll ]);
    Result := StringReplace(Result,#10,'',[ rfReplaceAll ]);
  end;
  if(padding<>'=') then
    Result := StringReplace(Result, '=', padding, [ rfReplaceAll ]);

end;

function base64StringToBytes( const str: String; padding: Char ): TBytes;
  var
    s: String;
begin
  s := str;
  if(padding<>'=') then
    s := StringReplace(s,padding, '=', [ rfReplaceAll ]);

  Result := decodeBase64(s);
end;

const
  Table: array [Byte] of Byte = (
    0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240,
    8,136,72,200,40,168,104,232,24,152,88,216,56,184,120,248,
    4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244,
    12,140,76,204,44,172,108,236,28,156,92,220,60,188,124,252,
    2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242,
    10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250,
    6,134,70,198,38,166,102,230,22,150,86,214,54,182,118,246,
    14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254,
    1,129,65,193,33,161,97,225,17,145,81,209,49,177,113,241,
    9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249,
    5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245,
    13,141,77,205,45,173,109,237,29,157,93,221,61,189,125,253,
    3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243,
    11,139,75,203,43,171,107,235,27,155,91,219,59,187,123,251,
    7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247,
    15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255
  );

function ReverseBits(b: Byte): Byte;
begin
  Result := Table[b];
end;

function ReverseBitsOfBytes(bytes: TBytes): TBytes;
  var
    i: Integer;
begin
  Result := reverseBytes(bytes);
  i := Length(Result);
  while i > 0 do begin
    dec(i);
    Result[i] := ReverseBits(Result[i]);
  end;
end;

function randomBytes(count: byte): TBytes;
begin
  SetLength(Result,count);
  if(count>0) then
    CreateRandomNumberGenerator.GetBytes(Result);
end;

function concatBytes(const bytes: array of TBytes): TBytes;
  var
    tmp,i,index: Integer;
    total: Integer;
begin
  total := length(bytes);
  SetLength(Result,0);
  index := 0;
  for i := 0 to total - 1 do begin
    tmp := Length(bytes[i]);
    if(tmp = 0) then continue;
    setLength(Result,Length(Result)+tmp);
    Move(bytes[i][0],Result[index],tmp);
    inc(index,tmp);
  end;
end;


end.
