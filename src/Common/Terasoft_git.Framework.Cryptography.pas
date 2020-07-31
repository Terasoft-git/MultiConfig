unit Terasoft_git.Framework.Cryptography;

interface
  uses
    Terasoft_git.Framework.Types, SysUtils;

  type

    //Simple interface for cryptografy
    ICryptografy = interface
    ['{AE572F47-B1C4-4725-83B1-34E50211632F}']
      function encryptString(const str: WideStringFramework): TBytes;
      function encryptBytes(const bytes: TBytes): TBytes;
      function decryptBytes(const bytes: TBytes): TBytes;
      procedure setSeed(const seed: TBytes);
    end;

  var
    globalCrypter: ICryptografy;

  function createCrypter(const seed: TBytes): ICryptografy;

implementation
  uses
    Spring.Cryptography, Terasoft_git.Framework.Bytes;

  const
    SALTCOUNT = 4;

  {$if defined(DEBUG)}
      DUMMY_SEED = 'DUMMY KEY ALLERT!!! Just For initialization and test!!! Do not use this SEED!!!';
  {$ifend}



  type
    // Simple Crypter that uses Spring.Cryptography
    TCripter=class(TInterfacedObject, ICryptografy)
    protected
      crypter: ITripleDES;
      function encryptString(const str: WideStringFramework): TBytes;
      function encryptBytes(const bytes: TBytes): TBytes;
      function decryptBytes(const bytes: TBytes): TBytes;
      procedure setSeed(const seed: TBytes);
    public
      constructor Create;
      destructor Destroy; override;
    end;


function createCrypter(const seed: TBytes): ICryptografy;
begin
  Result := TCripter.Create;
  Result.setSeed(seed);
end;

{ TCripter }

constructor TCripter.Create;
begin
  inherited;
  crypter := CreateTripleDES;
  crypter.CipherMode := TCipherMode.CBC;
end;

function TCripter.encryptBytes(const bytes: TBytes): TBytes;
  var
    b: TBytes;
begin
  // Always concat 2 bytes ramdonly..
  b := randomBytes(SALTCOUNT);
  Result := crypter.Encrypt(concatBytes([b, bytes]));
end;

function TCripter.encryptString(const str: WideStringFramework): TBytes;
begin
  Result := encryptBytes(BytesOf(str));
end;

function TCripter.decryptBytes(const bytes: TBytes): TBytes;
begin
  Result := crypter.Decrypt(bytes);
  Result := Copy(Result, SALTCOUNT, MaxInt);
end;

destructor TCripter.Destroy;
begin
  inherited;
end;

procedure TCripter.setSeed(const seed: TBytes);
  var
    k: TBytes;
begin
  k := sha512OfBytes(seed,2);
  setLength(k, crypter.KeySize div 8);
  crypter.Key := k;
  k := copy(sha512OfBytes(ReverseBitsOfBytes(k)),1,crypter.BlockSize div 8);
  crypter.IV := k;
end;

initialization
  {$if defined(DEBUG)}
    globalCrypter := createCrypter(bytesOf(DUMMY_SEED));
  {$ifend}


end.
