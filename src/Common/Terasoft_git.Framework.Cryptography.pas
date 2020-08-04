
{$i multicfg.inc}

unit Terasoft_git.Framework.Cryptography;

interface
  uses
    Terasoft_git.Framework.Types, SysUtils;

  const
  {$if not defined(DEBUG)}
    CRYPTO_DEFSALTLEN = 4;
  {$else}
      CRYPTO_DEFSALTLEN = 12;
      CRYPTO_DUMMY_SEED = 'DUMMY KEY ALLERT!!! Just For initialization and test!!! Do not use this SEED!!!';
  {$ifend}

  type

    //Simple interface for cryptografy

    ICryptografy = interface
    ['{CBD63C23-179E-4005-986C-195CD8CFF66E}']
      function encryptStringToBase64(const str: WideStringFramework; wrapLines: boolean = false; padding: Char = '='): WideStringFramework; stdcall;
      function decryptBase64ToString(const base64: WideStringFramework; padding: Char = '='): WideStringFramework; stdcall;
      procedure setSeedString(const seed: WideStringFramework);stdcall;
      procedure setSaltLen(const value: Integer);stdcall;
      function getSaltlen: Integer;stdcall;
      property saltLen: Integer read getSaltlen write setSaltlen;
    end;

    {$if defined(DXE_UP)}
      ICryptografyEx = interface(ICryptografy)
      ['{366C2391-95B8-4412-A045-28F732A01FC3}']
        function encryptString(const str: WideStringFramework): TBytes;stdcall;
        function encryptBytes(const bytes: TBytes): TBytes;stdcall;
        function decryptBytes(const bytes: TBytes): TBytes;stdcall;
        procedure setSeed(const seed: TBytes);stdcall;
      end;
    {$ifend}

  var
    globalCrypter: ICryptografy;

  function createCrypter(const seed: {$if defined(__MULTICFG_IMPL__)}TBytes{$else}WideStringFramework{$ifend}): ICryptografy;
  function encryptStringToBase64(const str: String; wrapLines: boolean = false; crypter: ICryptografy = nil; padding: Char = '='): String;
  function decryptBase64ToString(const base64: String; decrypter: ICryptografy = nil; padding: Char = '='): String;

implementation

  uses
    {$if defined(DXE_UP)}

      Spring.Cryptography,  
    {$ifend}
    Terasoft_git.Framework.Bytes,
    Terasoft_git.Framework.Initializer.Iface;


 {$if defined(__CRYPTO_IMPL__)}
  type
    // Simple Crypter that uses Spring.Cryptography
    TCrypter=class(TInterfacedObject, ICryptografy
          {$if defined(DXE_UP)}
            , ICryptografyEx
          {$ifend}
    )
    protected
      fSaltlen: Integer;
      crypter: ISymmetricAlgorithm;
      function encryptString(const str: WideStringFramework): TBytes;stdcall;
      function encryptBytes(const bytes: TBytes): TBytes;stdcall;
      function decryptBytes(const bytes: TBytes): TBytes;stdcall;
      procedure setHexSeed(const hexSeed: WideStringFramework);stdcall;
      procedure setSeed(const seed: TBytes);stdcall;
      procedure setSaltLen(const value: Integer);stdcall;
      function getSaltlen: Integer;stdcall;
      function encryptStringToBase64(const str: WideStringFramework; wrapLines: boolean = false; padding: Char = '='): WideStringFramework; stdcall;
      function decryptBase64ToString(const base64: WideStringFramework; padding: Char = '='): WideStringFramework; stdcall;
      procedure setSeedString(const seed: WideStringFramework);stdcall;
    public
      constructor Create;
      destructor Destroy; override;
    end;
  {$ifend}

function encryptStringToBase64(const str: String; wrapLines: boolean = false; crypter: ICryptografy = nil; padding: Char = '='): String;
begin
  if(crypter=nil) then
    crypter := globalCrypter;
  if(crypter=nil) then
    raise Exception.Create('encryptStringToBase64: Crypter not specified.');
  Result := crypter.encryptStringToBase64(str, wrapLines, padding );
end;

function decryptBase64ToString(const base64: String; decrypter: ICryptografy = nil; padding: Char = '='): String;
begin
  if(decrypter=nil) then
    decrypter := globalCrypter;
  if(decrypter=nil) then
    raise Exception.Create('encryptStringToBase64: Decrypter not specified.');
  Result := decrypter.decryptBase64ToString(base64,padding);
end;

function createCrypter(const seed: {$if defined(__MULTICFG_IMPL__)}TBytes{$else}WideStringFramework{$ifend}): ICryptografy;
 {$if defined(__CRYPTO_IMPL__)}
    var
      c: TCrypter;
 {$ifend}
begin
 {$if defined(__CRYPTO_IMPL__)}
    c := TCrypter.Create;
    c.setSeed(seed);
    Result := c;
 {$else}
   Result := createIfaceDllMultiCfg.createCrypter(seed);
 {$ifend}
end;

{$if defined(__CRYPTO_IMPL__)}

{ TCripter }

constructor TCrypter.Create;
begin
  inherited;
  fSaltlen := CRYPTO_DEFSALTLEN;
  crypter := CreateTripleDES;
  crypter.CipherMode := TCipherMode.CBC;
end;

function TCrypter.encryptBytes(const bytes: TBytes): TBytes;
  var
    b: TBytes;
begin
  // Always concat 2 bytes ramdonly..
  b := randomBytes(fSaltlen);
  Result := crypter.Encrypt(concatBytes([b, bytes]));
end;

function TCrypter.encryptString(const str: WideStringFramework): TBytes;
begin
  Result := encryptBytes(BytesOf(str));
end;

function TCrypter.getSaltlen: Integer;
begin
  Result := fSaltlen;
end;

function TCrypter.decryptBytes(const bytes: TBytes): TBytes;
begin
  Result := crypter.Decrypt(bytes);
  if(fSaltlen>0) then
    Result := Copy(Result, fSaltlen, MaxInt);
end;

destructor TCrypter.Destroy;
begin
  inherited;
end;

procedure TCrypter.setSaltLen(const value: Integer);
begin
  if(value<0) then
    raise Exception.CreateFmt('TCrypter.setSaltLen: Value [%d] is invalid for Saltlen.', [ value ]);

  fSaltlen := value;

end;

procedure TCrypter.setHexSeed(const hexSeed: WideStringFramework);stdcall;
begin
  setSeed(hexStringToBytes(hexSeed));
end;

procedure TCrypter.setSeed(const seed: TBytes);
  var
    k: TBytes;
begin
  k := sha512OfBytes(seed,2);
  setLength(k, crypter.KeySize div 8);
  crypter.Key := k;
  k := copy(sha512OfBytes(ReverseBitsOfBytes(k)),0,crypter.BlockSize div 8);
  crypter.IV := k;
end;

procedure TCrypter.setSeedString(const seed: WideStringFramework);stdcall;
begin
  setSeed(BytesOf(seed));
end;

function TCrypter.encryptStringToBase64(const str: WideStringFramework; wrapLines: boolean = false; padding: Char = '='): WideStringFramework;
begin
  Result := bytesToBase64String(encryptString(str),wrapLines,padding);
end;

function TCrypter.decryptBase64ToString(const base64: WideStringFramework; padding: Char = '='): WideStringFramework;
begin
  Result := StringOf(decryptBytes(base64StringToBytes(base64,padding)));
end;

{$ifend}

initialization
   {$if defined(__CRYPTO_IMPL__)}
    {$if defined(DEBUG)}
      globalCrypter := createCrypter(bytesOf(CRYPTO_DUMMY_SEED));
    {$ifend}
   {$ifend}


end.
