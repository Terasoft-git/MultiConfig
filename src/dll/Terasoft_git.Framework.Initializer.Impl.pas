unit Terasoft_git.Framework.Initializer.Impl;

interface
  uses
    Terasoft_git.Framework.Types,
    Terasoft_git.Framework.Initializer.Iface;

  function createMutiCfg: IMultiCfgCreator;

  exports createMutiCfg;

implementation
  uses
    Classes, Terasoft_git.Framework.MultiConfig,
    Terasoft_git.Framework.Cryptography, Windows;

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
    end;


function createMutiCfg: IMultiCfgCreator;
begin
  Result := TCreator.Create;
end;

{ TCreator }

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

function TCreator.createMultiConfig: IMultiConfig;
begin
  Result := Terasoft_git.Framework.MultiConfig.createMultiConfig;
end;

function TCreator.defaultMultiConfigIniFile(crypted: boolean; crypter: ICryptografy): IMultiConfig;
begin
  Result := Terasoft_git.Framework.MultiConfig.defaultMultiConfigIniFile(crypted,crypter);
end;

end.
