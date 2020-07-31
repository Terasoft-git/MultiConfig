unit Terasoft_git.Framework.Bytes;

interface
  uses
    SysUtils;

  //to bytes
  function MD5OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
  function sha256OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
  function sha512OfBytes(const bytes: TBytes; count: Integer = 1): TBytes;
  function base64StringToBytes( const str: String ): TBytes;

  //from bytes
  function bytesToHexString(const bytes: TBytes) : String;
  function hexStringToBytes(const hex : AnsiString): TBytes;
  function bytesToBase64String( const bytes: TBytes; const wrapLines: boolean = true ): String;

  //bytes to Bytes
  function reverseBytes(b: TBytes): TBytes;


implementation
  uses
    Spring.Cryptography, Soap.EncdDecd;

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

function bytesToBase64String( const bytes: TBytes; const wrapLines: boolean = true ): String;
begin
  Result := encodeBase64(bytes,length(bytes));
  if( not wrapLines ) then begin
    Result := StringReplace(Result,#13,'',[ rfReplaceAll ]);
    Result := StringReplace(Result,#10,'',[ rfReplaceAll ]);
  end;
end;

function base64StringToBytes( const str: String ): TBytes;
begin
  Result := decodeBase64(str);
end;

end.
