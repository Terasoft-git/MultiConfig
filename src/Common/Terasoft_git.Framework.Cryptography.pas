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
    ['{AE572F47-B1C4-4725-83B1-34E50211632F}']
      function encryptString(const str: WideStringFramework): TBytes;
      function encryptBytes(const bytes: TBytes): TBytes;
      function decryptBytes(const bytes: TBytes): TBytes;
      procedure setSeed(const seed: TBytes);
      procedure setSaltLen(const value: Integer);
      function getSaltlen: Integer;
      property saltLen: Integer read getSaltlen write setSaltlen;
    end;

  var
    globalCrypter: ICryptografy;

  function createCrypter(const seed: TBytes): ICryptografy;
  function encryptStringToBase64(const str: String; wrapLines: boolean = false; crypter: ICryptografy = nil; padding: Char = '='): String;
  function decryptBase64ToString(const base64: String; decrypter: ICryptografy = nil; padding: Char = '='): String;

implementation
  uses
    Spring.Cryptography, Terasoft_git.Framework.Bytes;


  type
    // Simple Crypter that uses Spring.Cryptography
    TCrypter=class(TInterfacedObject, ICryptografy)
    protected
      fSaltlen: Integer;
      crypter: ISymmetricAlgorithm;
      function encryptString(const str: WideStringFramework): TBytes;
      function encryptBytes(const bytes: TBytes): TBytes;
      function decryptBytes(const bytes: TBytes): TBytes;
      procedure setSeed(const seed: TBytes);
      procedure setSaltLen(const value: Integer);
      function getSaltlen: Integer;
    public
      constructor Create;
      destructor Destroy; override;
    end;

function encryptStringToBase64(const str: String; wrapLines: boolean = false; crypter: ICryptografy = nil; padding: Char = '='): String;
begin
  if(crypter=nil) then
    crypter := globalCrypter;
  if(crypter=nil) then
    raise Exception.Create('encryptStringToBase64: Crypter not specified.');
  Result := bytesToBase64String( crypter.encryptString(str), wrapLines, padding );
end;

function decryptBase64ToString(const base64: String; decrypter: ICryptografy = nil; padding: Char = '='): String;
begin
  if(decrypter=nil) then
    decrypter := globalCrypter;
  if(decrypter=nil) then
    raise Exception.Create('encryptStringToBase64: Decrypter not specified.');
  Result := StringOf(decrypter.decryptBytes(base64StringToBytes(base64,padding)));
end;

function createCrypter(const seed: TBytes): ICryptografy;
begin
  Result := TCrypter.Create;
  Result.setSeed(seed);
end;

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

initialization
  {$if defined(DEBUG)}
    globalCrypter := createCrypter(bytesOf(CRYPTO_DUMMY_SEED));
  {$ifend}


end.
