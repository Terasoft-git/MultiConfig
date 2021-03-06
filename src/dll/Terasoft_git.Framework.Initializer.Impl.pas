unit Terasoft_git.Framework.Initializer.Impl;

interface
  uses
    Terasoft_git.Framework.Types, SysUtils,
    Terasoft_git.Framework.Initializer.Iface;

  function createMutiCfg: IMultiCfgCreator;

  exports createMutiCfg;

implementation
  uses
    Classes, Terasoft_git.Framework.MultiConfig,
    Terasoft_git.Framework.Cryptography, Windows,
    Terasoft_git.Framework.Bytes,
    Terasoft_git.Framework.Timer.LR;

  type
    TCreator = class(TInterfacedObject, IMultiCfgCreator)
    protected
      function defaultMultiConfigIniFile(crypted: boolean = false; crypter: ICryptografy = nil): IMultiConfig; stdcall;
      function createMultiConfig: IMultiConfig; stdcall;
      function createConfigIniFile(const filename: WideStringFramework = MULTICONFIG_DEFAULTINIFILE; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigIniString(const str: WideStringFramework=''; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigRegistry(const path: WideStringFramework = ''; rootkey: HKEY = 0; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigCmdLine(const prefix: WideStringFramework = ''; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigEnvVar(const prefix: WideStringFramework = ''; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function getGlobalCrypter: ICryptografyEx; stdcall;
      procedure setGlobalCrypter(const value: ICryptografyEx); stdcall;

      function createCrypter(const hexSeed: WideStringFramework): ICryptografyEx; stdcall;
    public
      constructor Create;
    end;


function createMutiCfg: IMultiCfgCreator;
begin
  Result := TCreator.Create;
end;

{ TCreator }

constructor TCreator.Create;
begin
  inherited;
  if(globalCrypter=NIL) THEN
    globalCrypter := createCrypter('DUMMY');
  initLRTimer;
end;

function TCreator.createConfigCmdLine(const prefix, hint: WideStringFramework; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.createConfigCmdLine(prefix,hint,crypted,crypter);
end;

function TCreator.createConfigEnvVar(const prefix, hint: WideStringFramework; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.createConfigEnvVar(prefix,hint,crypted,crypter);
end;

function TCreator.createConfigIniFile(const filename, hint: WideStringFramework; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.createConfigIniFile(filename,hint,crypted,crypter);
end;

function TCreator.createConfigIniString(const str, hint: WideStringFramework; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.createConfigIniString(str,hint,crypted,crypter);
end;

function TCreator.createConfigRegistry(const path: WideStringFramework; rootkey: HKEY; const hint: WideStringFramework; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.createConfigRegistry(path,rootkey,hint,crypted,crypter);
end;

function TCreator.createCrypter(const hexSeed: WideStringFramework): ICryptografyEx;
begin
  Supports(Terasoft_git.Framework.Cryptography.createCrypter(hexStringToBytes(hexSeed)),ICryptografyEx,Result);
end;

function TCreator.createMultiConfig: IMultiConfig;
begin
  Result := Terasoft_git.Framework.MultiConfig.createMultiConfig;
end;

function TCreator.defaultMultiConfigIniFile(crypted: boolean; crypter: ICryptografy): IMultiConfig;
begin
  Result := Terasoft_git.Framework.MultiConfig.defaultMultiConfigIniFile(crypted,crypter);
end;

function TCreator.getGlobalCrypter: ICryptografyEx;
begin
  Supports(globalCrypter,ICryptografyEx,Result);
end;

procedure TCreator.setGlobalCrypter(const value: ICryptografyEx);
begin
  globalCrypter := value;
end;

end.
